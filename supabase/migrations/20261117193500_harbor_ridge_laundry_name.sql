-- Update store business name to HARBOR RIDGE LAUNDRY

ALTER TABLE public.orders ALTER COLUMN store_name SET DEFAULT 'HARBOR RIDGE LAUNDRY';

UPDATE public.orders
SET store_name = 'HARBOR RIDGE LAUNDRY';

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
