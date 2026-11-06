-- ==============================================================================
-- HARBORRIDGE LAUNDRY MANAGEMENT SYSTEM - PRODUCTION SCHEMA
-- Generated for Supabase Project: https://cyjigxszbseqbchqfmuf.supabase.co
-- ==============================================================================

-- 1. ORDERS TABLE
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT UNIQUE NOT NULL,
    store_name TEXT NOT NULL DEFAULT 'HARBORRIDGE LAUNDRY',
    store_code TEXT NOT NULL DEFAULT '123456',
    store_email TEXT NOT NULL DEFAULT 'operations@harborridge.co.ke',
    store_address TEXT NOT NULL DEFAULT 'Central Industrial Plant, Nairobi - 00100',
    tax_identifier TEXT NOT NULL DEFAULT 'KRA-PIN-P05123984A',
    order_date TEXT NOT NULL,
    delivery_date TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'washing',
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    assigned_staff TEXT NOT NULL DEFAULT 'Attendant',
    primary_service TEXT NOT NULL DEFAULT 'Wash & Fold',
    vendor_branch TEXT NOT NULL DEFAULT 'Harborridge Central Plant',
    display_amount TEXT NOT NULL,
    payment_status_label TEXT NOT NULL DEFAULT 'Unpaid',
    processing_stage_label TEXT NOT NULL DEFAULT 'Received',
    delivery_status_label TEXT NOT NULL DEFAULT 'Pickup assigned',
    delivery_method TEXT NOT NULL DEFAULT 'Pickup assigned',
    assigned_rider TEXT NOT NULL DEFAULT 'Unassigned',
    created_date_label TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. ORDER ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES public.orders(order_id) ON DELETE CASCADE,
    item_index INT NOT NULL DEFAULT 1,
    service_name TEXT NOT NULL,
    service_type TEXT NOT NULL,
    rate NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    quantity INT NOT NULL DEFAULT 1,
    garment_type TEXT NOT NULL DEFAULT 'shirt',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. ORDER ADDONS TABLE
CREATE TABLE IF NOT EXISTS public.order_addons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES public.orders(order_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. ORDER PAYMENTS TABLE
CREATE TABLE IF NOT EXISTS public.order_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES public.orders(order_id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    payment_date TEXT NOT NULL,
    method TEXT NOT NULL DEFAULT '[M-PESA]',
    reference_code TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. INVENTORY ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    unit TEXT NOT NULL DEFAULT 'Liters',
    min_threshold INT NOT NULL DEFAULT 10,
    unit_cost_kes INT NOT NULL DEFAULT 0,
    supplier TEXT NOT NULL,
    linked_service TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. DISPATCH RUNS TABLE
CREATE TABLE IF NOT EXISTS public.dispatch_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id TEXT UNIQUE NOT NULL,
    order_id TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    zone TEXT NOT NULL,
    bag_count TEXT NOT NULL,
    branch TEXT NOT NULL,
    rider_name TEXT NOT NULL,
    eta_window TEXT NOT NULL,
    stage TEXT NOT NULL DEFAULT 'Pickup Scheduled',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. PARTNER VENDORS TABLE
CREATE TABLE IF NOT EXISTS public.partner_vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_code TEXT UNIQUE NOT NULL,
    branch_name TEXT NOT NULL,
    location TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    manager_name TEXT NOT NULL,
    intake_status TEXT NOT NULL DEFAULT 'Active Intake',
    revenue_kes INT NOT NULL DEFAULT 0,
    orders_count INT NOT NULL DEFAULT 0,
    commission_rate NUMERIC(4, 2) NOT NULL DEFAULT 0.15,
    is_franchise BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. PAYMENT TRANSACTIONS LEDGER TABLE
CREATE TABLE IF NOT EXISTS public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tx_id TEXT UNIQUE NOT NULL,
    order_id TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    channel TEXT NOT NULL DEFAULT 'M-Pesa Express',
    reference_code TEXT NOT NULL,
    total_billed_kes INT NOT NULL DEFAULT 0,
    amount_paid_kes INT NOT NULL DEFAULT 0,
    balance_due_kes INT NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'Paid',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 9. SETTLEMENT BATCHES TABLE
CREATE TABLE IF NOT EXISTS public.settlement_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_code TEXT UNIQUE NOT NULL,
    vendor_name TEXT NOT NULL,
    period_label TEXT NOT NULL,
    orders_count INT NOT NULL DEFAULT 0,
    gross_volume_kes INT NOT NULL DEFAULT 0,
    commission_split_kes INT NOT NULL DEFAULT 0,
    net_payout_kes INT NOT NULL DEFAULT 0,
    disbursal_method TEXT NOT NULL DEFAULT 'M-Pesa B2B',
    account_number TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_orders_customer ON public.orders(customer_phone);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_payments_order ON public.order_payments(order_id);
CREATE INDEX IF NOT EXISTS idx_inventory_category ON public.inventory_items(category);
CREATE INDEX IF NOT EXISTS idx_dispatch_stage ON public.dispatch_runs(stage);
CREATE INDEX IF NOT EXISTS idx_vendors_branch ON public.partner_vendors(branch_name);

-- ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispatch_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settlement_batches ENABLE ROW LEVEL SECURITY;

-- Allow anon & authenticated roles full access for client app operations
CREATE POLICY "Allow public read orders" ON public.orders FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public insert orders" ON public.orders FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Allow public update orders" ON public.orders FOR UPDATE TO anon, authenticated USING (true);

CREATE POLICY "Allow public read order_items" ON public.order_items FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public insert order_items" ON public.order_items FOR INSERT TO anon, authenticated WITH CHECK (true);

CREATE POLICY "Allow public read order_addons" ON public.order_addons FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public insert order_addons" ON public.order_addons FOR INSERT TO anon, authenticated WITH CHECK (true);

CREATE POLICY "Allow public read order_payments" ON public.order_payments FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public insert order_payments" ON public.order_payments FOR INSERT TO anon, authenticated WITH CHECK (true);

CREATE POLICY "Allow public read inventory" ON public.inventory_items FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public write inventory" ON public.inventory_items FOR ALL TO anon, authenticated USING (true);

CREATE POLICY "Allow public read dispatch" ON public.dispatch_runs FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public write dispatch" ON public.dispatch_runs FOR ALL TO anon, authenticated USING (true);

CREATE POLICY "Allow public read vendors" ON public.partner_vendors FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public write vendors" ON public.partner_vendors FOR ALL TO anon, authenticated USING (true);

CREATE POLICY "Allow public read payments" ON public.payment_transactions FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public write payments" ON public.payment_transactions FOR ALL TO anon, authenticated USING (true);

CREATE POLICY "Allow public read settlements" ON public.settlement_batches FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Allow public write settlements" ON public.settlement_batches FOR ALL TO anon, authenticated USING (true);
