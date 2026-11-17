-- ==============================================================================
-- Staff auth lockdown, atomic order/payment writes, duplicate cleanup
--
-- Before this migration every table allowed the public `anon` key to read and
-- write everything, and sign-in was a client-side PIN check. After it:
--   * only signed-in users with an active row in public.staff can touch data
--   * each module's writes are gated by the staff member's menu rights
--   * orders, order items and payments are written only through SECURITY
--     DEFINER functions that validate input and run in one transaction
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. STAFF
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.staff (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL DEFAULT '',
    role TEXT NOT NULL DEFAULT 'manager'
        CHECK (role IN ('admin', 'manager', 'productionLead', 'cashier', 'driver')),
    role_title TEXT NOT NULL DEFAULT 'Staff',
    branch TEXT NOT NULL DEFAULT 'Harborridge Main',
    shift_label TEXT NOT NULL DEFAULT 'Assigned Shift • 08:00–17:00',
    is_active BOOLEAN NOT NULL DEFAULT true,
    excepted_modules TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;

-- Role helpers. SECURITY DEFINER so policies can read staff without recursing
-- through staff's own RLS.
CREATE OR REPLACE FUNCTION public.is_active_staff()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM staff WHERE id = auth.uid() AND is_active);
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM staff WHERE id = auth.uid() AND is_active AND role = 'admin');
$$;

-- Module keys match the Dart AppModuleKey enum names.
CREATE OR REPLACE FUNCTION public.staff_can(module TEXT)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM staff
    WHERE id = auth.uid() AND is_active
      AND (role = 'admin' OR NOT (module = ANY (excepted_modules)))
  );
$$;

REVOKE ALL ON FUNCTION public.is_active_staff() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.is_admin() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.staff_can(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_active_staff() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.staff_can(TEXT) TO authenticated;

-- Staff rows are created by the staff-admin Edge Function (service role).
-- Clients can read their own row; admins and Staff-module holders read all;
-- only admins can update (menu rights, active flag). Nobody can self-promote.
REVOKE ALL ON public.staff FROM anon;
REVOKE INSERT, DELETE ON public.staff FROM authenticated;
CREATE POLICY "staff read self or roster" ON public.staff FOR SELECT TO authenticated
    USING (id = auth.uid() OR public.staff_can('staff'));
CREATE POLICY "admins update staff" ON public.staff FOR UPDATE TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ------------------------------------------------------------------------------
-- 2. BACK UP ROWS THE CLEANUP TOUCHES (archive schema is not exposed by the API)
-- ------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS archive;
REVOKE ALL ON SCHEMA archive FROM PUBLIC, anon, authenticated;
CREATE TABLE IF NOT EXISTS archive.order_items_20261111 AS TABLE public.order_items;
CREATE TABLE IF NOT EXISTS archive.order_payments_20261111 AS TABLE public.order_payments;
CREATE TABLE IF NOT EXISTS archive.payment_transactions_20261111 AS TABLE public.payment_transactions;
CREATE TABLE IF NOT EXISTS archive.orders_20261111 AS TABLE public.orders;

-- ------------------------------------------------------------------------------
-- 3. SCHEMA ADDITIONS FOR IDEMPOTENT, CONSISTENT WRITES
-- ------------------------------------------------------------------------------
ALTER TABLE public.orders
    ADD COLUMN IF NOT EXISTS client_ref UUID UNIQUE,
    ADD COLUMN IF NOT EXISTS total_kes NUMERIC(12, 2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.staff(id);

ALTER TABLE public.order_payments
    ADD COLUMN IF NOT EXISTS client_ref UUID UNIQUE,
    ADD COLUMN IF NOT EXISTS recorded_by UUID REFERENCES public.staff(id),
    ADD COLUMN IF NOT EXISTS voided_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS void_reason TEXT;

ALTER TABLE public.payment_transactions
    ADD COLUMN IF NOT EXISTS payment_id UUID REFERENCES public.order_payments(id),
    ADD COLUMN IF NOT EXISTS voided_at TIMESTAMPTZ;

CREATE SEQUENCE IF NOT EXISTS public.order_number_seq;
CREATE SEQUENCE IF NOT EXISTS public.payment_tx_seq START 100000;
CREATE SEQUENCE IF NOT EXISTS public.dispatch_run_seq START 10000;

SELECT setval(
    'public.order_number_seq',
    GREATEST(
        (SELECT COALESCE(MAX(NULLIF(substring(order_id FROM '(\d+)$'), '')::BIGINT), 0) FROM public.orders),
        1
    )
);

-- ------------------------------------------------------------------------------
-- 4. DUPLICATE CLEANUP
-- ------------------------------------------------------------------------------
-- 4a. order_items: updateOrder used to delete + re-insert the full item set, but
--     there was no DELETE policy, so the delete matched nothing and every edit
--     appended another copy. Each edit's batch shares one created_at, and the
--     latest batch is the true item set.
DELETE FROM public.order_items i
USING (SELECT order_id, MAX(created_at) AS latest FROM public.order_items GROUP BY order_id) l
WHERE i.order_id = l.order_id AND i.created_at < l.latest;

ALTER TABLE public.order_items
    DROP CONSTRAINT IF EXISTS order_items_order_id_item_index_key;
ALTER TABLE public.order_items
    ADD CONSTRAINT order_items_order_id_item_index_key UNIQUE (order_id, item_index);

-- 4b. Link existing ledger rows to their payment by order, amount and order of entry.
WITH p AS (
    SELECT id, order_id, amount::INT AS amt,
           row_number() OVER (PARTITION BY order_id, amount::INT ORDER BY created_at, id) AS rn
    FROM public.order_payments
), t AS (
    SELECT id, order_id, amount_paid_kes AS amt,
           row_number() OVER (PARTITION BY order_id, amount_paid_kes ORDER BY created_at, id) AS rn
    FROM public.payment_transactions WHERE payment_id IS NULL
)
UPDATE public.payment_transactions tx SET payment_id = p.id
FROM t JOIN p ON p.order_id = t.order_id AND p.amt = t.amt AND p.rn = t.rn
WHERE tx.id = t.id;

-- 4c. Void (do not delete) repeat payments: same order, amount, method and date.
--     The earliest one is kept. The old sheet only had fixed-amount buttons and
--     no double-tap guard, so these are repeated taps, not real receipts.
WITH ranked AS (
    SELECT id, row_number() OVER (
        PARTITION BY order_id, amount, upper(method), payment_date ORDER BY created_at, id
    ) AS rn
    FROM public.order_payments WHERE voided_at IS NULL
)
UPDATE public.order_payments op
SET voided_at = now(), void_reason = 'Duplicate of an earlier identical payment (cleanup 2026-11-11)'
FROM ranked WHERE op.id = ranked.id AND ranked.rn > 1;

UPDATE public.payment_transactions tx SET voided_at = op.voided_at, status = 'Voided'
FROM public.order_payments op
WHERE tx.payment_id = op.id AND op.voided_at IS NOT NULL AND tx.voided_at IS NULL;

-- 4d. Ledger rows used to say "Walk-in Customer" for every payment.
UPDATE public.payment_transactions tx
SET customer_name = o.customer_name, customer_phone = o.customer_phone
FROM public.orders o
WHERE o.order_id = tx.order_id AND tx.customer_name = 'Walk-in Customer'
  AND o.customer_name <> 'Walk-in Customer';

-- ------------------------------------------------------------------------------
-- 5. TOTALS
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public._recompute_order_totals(p_order_id TEXT)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    v_total NUMERIC(12, 2);
    v_paid NUMERIC(12, 2);
BEGIN
    SELECT COALESCE((SELECT SUM(rate * quantity) FROM order_items WHERE order_id = p_order_id), 0)
         + COALESCE((SELECT SUM(amount) FROM order_addons WHERE order_id = p_order_id), 0)
      INTO v_total;
    SELECT COALESCE(SUM(amount), 0) INTO v_paid
      FROM order_payments WHERE order_id = p_order_id AND voided_at IS NULL;

    UPDATE orders SET
        total_kes = v_total,
        display_amount = 'KES ' || to_char(v_total, 'FM999999990'),
        payment_status_label = CASE
            WHEN v_paid <= 0 THEN 'Unpaid'
            WHEN v_paid + 0.005 < v_total THEN 'Partial'
            ELSE 'Paid'
        END,
        updated_at = now()
    WHERE order_id = p_order_id;
END;
$$;
REVOKE ALL ON FUNCTION public._recompute_order_totals(TEXT) FROM PUBLIC, anon, authenticated;

SELECT public._recompute_order_totals(order_id) FROM public.orders;

-- A live payment with no ledger row (order LG-2026-00125's first payment: its
-- ledger insert failed and the error was swallowed). Backfill so the Payments
-- ledger matches order_payments.
INSERT INTO public.payment_transactions (
    tx_id, order_id, customer_name, customer_phone, channel, reference_code,
    total_billed_kes, amount_paid_kes, balance_due_kes, status, payment_id, created_at
)
SELECT 'TXN-' || nextval('public.payment_tx_seq'), op.order_id, o.customer_name, o.customer_phone,
       btrim(op.method, '[]'), COALESCE(op.reference_code, 'BACKFILL'),
       round(o.total_kes)::INT, round(op.amount)::INT, 0, 'Paid', op.id, op.created_at
FROM public.order_payments op
JOIN public.orders o ON o.order_id = op.order_id
WHERE op.voided_at IS NULL
  AND NOT EXISTS (SELECT 1 FROM public.payment_transactions t WHERE t.payment_id = op.id);

-- ------------------------------------------------------------------------------
-- 6. ATOMIC WRITE FUNCTIONS (the only way clients create orders and payments)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public._current_staff()
RETURNS public.staff LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE s staff;
BEGIN
    SELECT * INTO s FROM staff WHERE id = auth.uid() AND is_active;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Not signed in as active staff' USING ERRCODE = '42501';
    END IF;
    RETURN s;
END;
$$;
REVOKE ALL ON FUNCTION public._current_staff() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public._insert_payment(
    p_order_id TEXT, p_amount NUMERIC, p_method TEXT, p_reference TEXT,
    p_client_ref UUID, p_staff UUID
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    o orders;
    v_paid NUMERIC(12, 2);
    v_balance NUMERIC(12, 2);
    v_payment_id UUID;
    v_tx_id TEXT;
    v_method TEXT := NULLIF(btrim(p_method), '');
    v_reference TEXT := NULLIF(upper(btrim(p_reference)), '');
BEGIN
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION 'Payment amount must be greater than zero' USING ERRCODE = '22023';
    END IF;

    SELECT * INTO o FROM orders WHERE order_id = p_order_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id USING ERRCODE = 'P0002';
    END IF;

    SELECT COALESCE(SUM(amount), 0) INTO v_paid
      FROM order_payments WHERE order_id = p_order_id AND voided_at IS NULL;
    v_balance := o.total_kes - v_paid;
    IF p_amount > v_balance + 0.005 THEN
        RAISE EXCEPTION 'Payment of KES % is more than the KES % balance due on %',
            to_char(p_amount, 'FM999999990.00'), to_char(GREATEST(v_balance, 0), 'FM999999990.00'), p_order_id
            USING ERRCODE = '22023';
    END IF;

    IF v_reference IS NOT NULL AND EXISTS (
        SELECT 1 FROM order_payments WHERE upper(reference_code) = v_reference AND voided_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Reference % has already been recorded', v_reference USING ERRCODE = '23505';
    END IF;

    INSERT INTO order_payments (order_id, amount, payment_date, method, reference_code, client_ref, recorded_by)
    VALUES (p_order_id, p_amount, to_char(now() AT TIME ZONE 'Africa/Nairobi', 'DD/MM/YYYY'),
            '[' || COALESCE(v_method, 'M-Pesa') || ']', v_reference, p_client_ref, p_staff)
    RETURNING id INTO v_payment_id;

    v_tx_id := 'TXN-' || nextval('payment_tx_seq');
    INSERT INTO payment_transactions (
        tx_id, order_id, customer_name, customer_phone, channel, reference_code,
        total_billed_kes, amount_paid_kes, balance_due_kes, status, payment_id
    ) VALUES (
        v_tx_id, p_order_id, o.customer_name, o.customer_phone, COALESCE(v_method, 'M-Pesa'),
        COALESCE(v_reference, v_tx_id), round(o.total_kes)::INT, round(p_amount)::INT,
        GREATEST(round(v_balance - p_amount), 0)::INT,
        CASE WHEN v_balance - p_amount <= 0.005 THEN 'Paid' ELSE 'Partial' END,
        v_payment_id
    );

    PERFORM _recompute_order_totals(p_order_id);

    RETURN jsonb_build_object(
        'payment_id', v_payment_id, 'tx_id', v_tx_id,
        'balance_due', GREATEST(v_balance - p_amount, 0), 'duplicate', false
    );
END;
$$;
REVOKE ALL ON FUNCTION public._insert_payment(TEXT, NUMERIC, TEXT, TEXT, UUID, UUID) FROM PUBLIC, anon, authenticated;

-- Record a payment. Idempotent on p_client_ref: a retried or double-tapped
-- submit returns the first result instead of inserting again.
CREATE OR REPLACE FUNCTION public.record_order_payment(
    p_client_ref UUID, p_order_id TEXT, p_amount NUMERIC, p_method TEXT, p_reference TEXT DEFAULT NULL
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    s staff := _current_staff();
    existing order_payments;
BEGIN
    IF NOT (staff_can('orders') OR staff_can('payments')) THEN
        RAISE EXCEPTION 'Your account cannot record payments' USING ERRCODE = '42501';
    END IF;
    IF p_client_ref IS NULL THEN
        RAISE EXCEPTION 'client_ref is required' USING ERRCODE = '22023';
    END IF;

    SELECT * INTO existing FROM order_payments WHERE client_ref = p_client_ref;
    IF FOUND THEN
        RETURN jsonb_build_object(
            'payment_id', existing.id,
            'tx_id', (SELECT tx_id FROM payment_transactions WHERE payment_id = existing.id LIMIT 1),
            'duplicate', true
        );
    END IF;

    RETURN _insert_payment(p_order_id, p_amount, p_method, p_reference, p_client_ref, s.id);
END;
$$;

-- Create an order with its items, add-ons, optional first payment and dispatch
-- run in one transaction. The order number comes from a sequence, so two
-- tills can never generate the same one. Idempotent on p_client_ref.
CREATE OR REPLACE FUNCTION public.create_order(
    p_client_ref UUID, p_order JSONB, p_items JSONB, p_addons JSONB DEFAULT '[]', p_payment JSONB DEFAULT NULL
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    s staff := _current_staff();
    v_order_id TEXT;
    v_existing TEXT;
    v_rider TEXT := COALESCE(NULLIF(btrim(p_order->>'assigned_rider'), ''), 'Unassigned');
    v_branch TEXT := COALESCE(NULLIF(btrim(p_order->>'vendor_branch'), ''), 'Harbor Ridge • Getathuru Road');
    v_now_label TEXT := to_char(now() AT TIME ZONE 'Africa/Nairobi', 'DD/MM/YYYY');
    v_payment JSONB;
BEGIN
    IF NOT (staff_can('services') OR staff_can('orders')) THEN
        RAISE EXCEPTION 'Your account cannot create orders' USING ERRCODE = '42501';
    END IF;
    IF p_client_ref IS NULL THEN
        RAISE EXCEPTION 'client_ref is required' USING ERRCODE = '22023';
    END IF;

    SELECT order_id INTO v_existing FROM orders WHERE client_ref = p_client_ref;
    IF FOUND THEN
        RETURN jsonb_build_object('order_id', v_existing, 'duplicate', true);
    END IF;

    IF jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'An order needs at least one item' USING ERRCODE = '22023';
    END IF;
    IF EXISTS (
        SELECT 1 FROM jsonb_array_elements(p_items) e
        WHERE COALESCE((e->>'quantity')::INT, 0) <= 0 OR COALESCE((e->>'rate')::NUMERIC, -1) < 0
    ) THEN
        RAISE EXCEPTION 'Item quantities must be positive and rates cannot be negative' USING ERRCODE = '22023';
    END IF;

    v_order_id := 'LG-' || to_char(now() AT TIME ZONE 'Africa/Nairobi', 'YYYY') || '-'
                  || lpad(nextval('order_number_seq')::TEXT, 5, '0');

    INSERT INTO orders (
        order_id, store_name, store_code, store_email, store_address, order_date, delivery_date, status,
        customer_name, customer_phone, assigned_staff, primary_service, vendor_branch,
        display_amount, payment_status_label, processing_stage_label, delivery_status_label,
        delivery_method, assigned_rider, created_date_label, client_ref, created_by
    ) VALUES (
        v_order_id, 'HARBOR RIDGE LAUNDRY', '+254 142 188767', s.email,
        'Getathuru Road • Directly opposite NG-CDF Kabete Plaza',
        v_now_label,
        COALESCE(NULLIF(p_order->>'delivery_date', ''), to_char((now() + interval '2 days') AT TIME ZONE 'Africa/Nairobi', 'DD/MM/YYYY')),
        'processing',
        COALESCE(NULLIF(btrim(p_order->>'customer_name'), ''), 'Walk-in Customer'),
        COALESCE(btrim(p_order->>'customer_phone'), ''),
        s.full_name,
        COALESCE(NULLIF(p_order->>'primary_service', ''), 'Wash & Fold'),
        v_branch,
        'KES 0', 'Unpaid', 'Received',
        COALESCE(NULLIF(p_order->>'delivery_method', ''), 'Pickup assigned'),
        COALESCE(NULLIF(p_order->>'delivery_method', ''), 'Pickup assigned'),
        v_rider, v_now_label, p_client_ref, s.id
    );

    INSERT INTO order_items (order_id, item_index, service_name, service_type, rate, quantity, garment_type)
    SELECT v_order_id, ord::INT, e->>'service_name', COALESCE(e->>'service_type', ''),
           (e->>'rate')::NUMERIC, (e->>'quantity')::INT, COALESCE(e->>'garment_type', 'shirt')
    FROM jsonb_array_elements(p_items) WITH ORDINALITY AS t(e, ord);

    IF jsonb_typeof(p_addons) = 'array' THEN
        INSERT INTO order_addons (order_id, name, amount)
        SELECT v_order_id, e->>'name', GREATEST((e->>'amount')::NUMERIC, 0)
        FROM jsonb_array_elements(p_addons) e;
    END IF;

    PERFORM _recompute_order_totals(v_order_id);

    IF p_payment IS NOT NULL AND COALESCE((p_payment->>'amount')::NUMERIC, 0) > 0 THEN
        v_payment := _insert_payment(
            v_order_id, (p_payment->>'amount')::NUMERIC, p_payment->>'method',
            p_payment->>'reference', NULL, s.id
        );
    END IF;

    IF v_rider <> 'Unassigned' THEN
        INSERT INTO dispatch_runs (run_id, order_id, customer_name, zone, bag_count, branch, rider_name, eta_window, stage)
        SELECT 'DSP-' || nextval('dispatch_run_seq'), v_order_id, o.customer_name, v_branch,
               (SELECT COUNT(*) FROM order_items WHERE order_id = v_order_id) || ' Items • Intake',
               v_branch, v_rider, '16:00 – 17:30', o.delivery_status_label
        FROM orders o WHERE o.order_id = v_order_id;
    END IF;

    RETURN jsonb_build_object('order_id', v_order_id, 'duplicate', false, 'payment', v_payment);
END;
$$;

-- Replace an order's item lines in one transaction (the old client did a
-- delete then insert as two calls, and the delete was silently blocked).
CREATE OR REPLACE FUNCTION public.replace_order_items(p_order_id TEXT, p_items JSONB)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    s staff := _current_staff();
BEGIN
    IF NOT staff_can('orders') THEN
        RAISE EXCEPTION 'Your account cannot edit orders' USING ERRCODE = '42501';
    END IF;
    PERFORM 1 FROM orders WHERE order_id = p_order_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id USING ERRCODE = 'P0002';
    END IF;
    IF jsonb_typeof(p_items) <> 'array' THEN
        RAISE EXCEPTION 'Items must be a list' USING ERRCODE = '22023';
    END IF;
    IF EXISTS (
        SELECT 1 FROM jsonb_array_elements(p_items) e
        WHERE COALESCE((e->>'quantity')::INT, 0) <= 0 OR COALESCE((e->>'rate')::NUMERIC, -1) < 0
    ) THEN
        RAISE EXCEPTION 'Item quantities must be positive and rates cannot be negative' USING ERRCODE = '22023';
    END IF;

    DELETE FROM order_items WHERE order_id = p_order_id;
    INSERT INTO order_items (order_id, item_index, service_name, service_type, rate, quantity, garment_type)
    SELECT p_order_id, ord::INT, e->>'service_name', COALESCE(e->>'service_type', ''),
           (e->>'rate')::NUMERIC, (e->>'quantity')::INT, COALESCE(e->>'garment_type', 'shirt')
    FROM jsonb_array_elements(p_items) WITH ORDINALITY AS t(e, ord);

    PERFORM _recompute_order_totals(p_order_id);
    RETURN (SELECT jsonb_build_object('order_id', order_id, 'total_kes', total_kes, 'payment_status_label', payment_status_label)
            FROM orders WHERE order_id = p_order_id);
END;
$$;

REVOKE ALL ON FUNCTION public.record_order_payment(UUID, TEXT, NUMERIC, TEXT, TEXT) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.create_order(UUID, JSONB, JSONB, JSONB, JSONB) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.replace_order_items(TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.record_order_payment(UUID, TEXT, NUMERIC, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_order(UUID, JSONB, JSONB, JSONB, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.replace_order_items(TEXT, JSONB) TO authenticated;

-- ------------------------------------------------------------------------------
-- 7. REPLACE THE OPEN POLICIES
-- ------------------------------------------------------------------------------
DO $$
DECLARE pol RECORD;
BEGIN
    FOR pol IN
        SELECT tablename, policyname FROM pg_policies
        WHERE schemaname = 'public' AND tablename IN (
            'orders', 'order_items', 'order_addons', 'order_payments', 'inventory_items',
            'dispatch_runs', 'partner_vendors', 'payment_transactions', 'settlement_batches'
        )
    LOOP
        EXECUTE format('DROP POLICY %I ON public.%I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

REVOKE ALL ON public.orders, public.order_items, public.order_addons, public.order_payments,
              public.inventory_items, public.dispatch_runs, public.partner_vendors,
              public.payment_transactions, public.settlement_batches
    FROM anon;
-- TRUNCATE ignores row level security, so no client role may hold it.
REVOKE TRUNCATE, TRIGGER, REFERENCES ON public.orders, public.order_items, public.order_addons,
              public.order_payments, public.inventory_items, public.dispatch_runs,
              public.partner_vendors, public.payment_transactions, public.settlement_batches,
              public.staff
    FROM authenticated;
REVOKE ALL ON SEQUENCE public.order_number_seq, public.payment_tx_seq, public.dispatch_run_seq
    FROM PUBLIC, anon, authenticated;

-- Orders and their children: read for any active staff (dashboard, reports and
-- production all read them). Writes go through the functions above, except the
-- production board's status / stage / staff / rider updates.
REVOKE INSERT, UPDATE, DELETE ON public.orders, public.order_items, public.order_addons,
                                public.order_payments, public.payment_transactions
    FROM authenticated;
GRANT UPDATE (status, processing_stage_label, assigned_staff, assigned_rider,
              delivery_status_label, updated_at)
    ON public.orders TO authenticated;

CREATE POLICY "staff read orders" ON public.orders FOR SELECT TO authenticated USING (public.is_active_staff());
CREATE POLICY "staff update order progress" ON public.orders FOR UPDATE TO authenticated
    USING (public.staff_can('orders') OR public.staff_can('orderStatus'))
    WITH CHECK (public.staff_can('orders') OR public.staff_can('orderStatus'));
CREATE POLICY "staff read order_items" ON public.order_items FOR SELECT TO authenticated USING (public.is_active_staff());
CREATE POLICY "staff read order_addons" ON public.order_addons FOR SELECT TO authenticated USING (public.is_active_staff());
CREATE POLICY "staff read order_payments" ON public.order_payments FOR SELECT TO authenticated USING (public.is_active_staff());
CREATE POLICY "payments module reads ledger" ON public.payment_transactions FOR SELECT TO authenticated
    USING (public.staff_can('payments') OR public.staff_can('reports') OR public.staff_can('dashboard'));

-- Module-owned tables: read for active staff, write for holders of that menu.
CREATE POLICY "staff read inventory" ON public.inventory_items FOR SELECT TO authenticated USING (public.is_active_staff());
CREATE POLICY "inventory module inserts" ON public.inventory_items FOR INSERT TO authenticated WITH CHECK (public.staff_can('inventory'));
CREATE POLICY "inventory module updates" ON public.inventory_items FOR UPDATE TO authenticated
    USING (public.staff_can('inventory')) WITH CHECK (public.staff_can('inventory'));
CREATE POLICY "admins delete inventory" ON public.inventory_items FOR DELETE TO authenticated USING (public.is_admin());

CREATE POLICY "staff read dispatch" ON public.dispatch_runs FOR SELECT TO authenticated USING (public.is_active_staff());
CREATE POLICY "dispatch module inserts" ON public.dispatch_runs FOR INSERT TO authenticated WITH CHECK (public.staff_can('dispatch'));
CREATE POLICY "dispatch module updates" ON public.dispatch_runs FOR UPDATE TO authenticated
    USING (public.staff_can('dispatch')) WITH CHECK (public.staff_can('dispatch'));
CREATE POLICY "admins delete dispatch" ON public.dispatch_runs FOR DELETE TO authenticated USING (public.is_admin());

CREATE POLICY "staff read vendors" ON public.partner_vendors FOR SELECT TO authenticated USING (public.is_active_staff());
CREATE POLICY "vendors module inserts" ON public.partner_vendors FOR INSERT TO authenticated WITH CHECK (public.staff_can('vendors'));
CREATE POLICY "vendors module updates" ON public.partner_vendors FOR UPDATE TO authenticated
    USING (public.staff_can('vendors')) WITH CHECK (public.staff_can('vendors'));
CREATE POLICY "admins delete vendors" ON public.partner_vendors FOR DELETE TO authenticated USING (public.is_admin());

CREATE POLICY "settlements module reads" ON public.settlement_batches FOR SELECT TO authenticated
    USING (public.staff_can('settlements') OR public.staff_can('reports'));
CREATE POLICY "settlements module inserts" ON public.settlement_batches FOR INSERT TO authenticated WITH CHECK (public.staff_can('settlements'));
CREATE POLICY "settlements module updates" ON public.settlement_batches FOR UPDATE TO authenticated
    USING (public.staff_can('settlements')) WITH CHECK (public.staff_can('settlements'));
CREATE POLICY "admins delete settlements" ON public.settlement_batches FOR DELETE TO authenticated USING (public.is_admin());

-- Indexes for the new lookups and the created_at ordering every list uses.
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_addons_order ON public.order_addons(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_tx_payment ON public.payment_transactions(payment_id);
CREATE INDEX IF NOT EXISTS idx_payment_tx_created_at ON public.payment_transactions(created_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_order_payments_reference_live
    ON public.order_payments (upper(reference_code))
    WHERE reference_code IS NOT NULL AND voided_at IS NULL;
