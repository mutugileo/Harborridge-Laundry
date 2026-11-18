-- Add image_url to order_items to support custom item pictures and photos
ALTER TABLE public.order_items ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Update create_order to persist image_url
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
        order_id, customer_name, customer_phone, order_status,
        pickup_address, delivery_address, total_pieces,
        primary_service, store_name, store_code, store_address,
        vendor_branch, total_amount_kes, payment_status_label,
        workflow_stage_label, delivery_method, handover_label,
        assigned_rider, delivery_date, client_ref, created_by
    ) VALUES (
        v_order_id,
        COALESCE(NULLIF(btrim(p_order->>'customer_name'), ''), 'Walk-in Customer'),
        COALESCE(NULLIF(btrim(p_order->>'customer_phone'), ''), '+254 700 000 000'),
        'Received',
        COALESCE(NULLIF(p_order->>'pickup_address', ''), 'Counter drop-off'),
        COALESCE(NULLIF(p_order->>'delivery_address', ''), 'Counter collection'),
        0,
        COALESCE(NULLIF(p_order->>'primary_service', ''), 'Dry Cleaning'),
        'HARBOR RIDGE LAUNDRY',
        '+254 142 188767',
        'Getathuru Road • Directly opposite NG-CDF Kabete Plaza',
        v_branch,
        'KES 0', 'Unpaid', 'Received',
        COALESCE(NULLIF(p_order->>'delivery_method', ''), 'Pickup assigned'),
        COALESCE(NULLIF(p_order->>'delivery_method', ''), 'Pickup assigned'),
        v_rider, v_now_label, p_client_ref, s.id
    );

    INSERT INTO order_items (order_id, item_index, service_name, service_type, rate, quantity, garment_type, image_url)
    SELECT v_order_id, ord::INT, e->>'service_name', COALESCE(e->>'service_type', ''),
           (e->>'rate')::NUMERIC, (e->>'quantity')::INT, COALESCE(e->>'garment_type', 'shirt'),
           NULLIF(e->>'image_url', '')
    FROM jsonb_array_elements(p_items) WITH ORDINALITY AS t(e, ord);

    IF jsonb_typeof(p_addons) = 'array' THEN
        INSERT INTO order_addons (order_id, name, amount)
        SELECT v_order_id, e->>'name', GREATEST((e->>'amount')::NUMERIC, 0)
        FROM jsonb_array_elements(p_addons) e;
    END IF;

    PERFORM _recompute_order_totals(v_order_id);

    IF p_payment IS NOT NULL AND jsonb_typeof(p_payment) = 'object'
       AND COALESCE((p_payment->>'amount')::NUMERIC, 0) > 0 THEN
        v_payment := record_order_payment(
            gen_random_uuid(),
            v_order_id,
            (p_payment->>'amount')::NUMERIC,
            COALESCE(p_payment->>'method', 'Cash'),
            p_payment->>'reference'
        );
    END IF;

    INSERT INTO audit_logs (actor_staff_id, actor_email, action, entity_type, entity_id, payload)
    VALUES (
        s.id, s.email, 'orders.create', 'order', v_order_id,
        jsonb_build_object(
            'client_ref', p_client_ref,
            'summary', 'Order ' || v_order_id || ' • ' ||
                       (SELECT COUNT(*) FROM order_items WHERE order_id = v_order_id) || ' Items • Intake',
            'initial_payment', v_payment
        )
    );

    RETURN (SELECT jsonb_build_object(
                'order_id', order_id,
                'total_kes', total_kes,
                'total_pieces', total_pieces,
                'payment_status_label', payment_status_label
            ) FROM orders WHERE order_id = v_order_id);
END;
$$;

-- Update replace_order_items to persist image_url
CREATE OR REPLACE FUNCTION public.replace_order_items(p_order_id TEXT, p_items JSONB)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
    s staff := _current_staff();
BEGIN
    IF NOT (staff_can('services') OR staff_can('orders')) THEN
        RAISE EXCEPTION 'Your account cannot edit order items' USING ERRCODE = '42501';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = p_order_id) THEN
        RAISE EXCEPTION 'Order % not found', p_order_id USING ERRCODE = 'P0002';
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

    DELETE FROM order_items WHERE order_id = p_order_id;
    INSERT INTO order_items (order_id, item_index, service_name, service_type, rate, quantity, garment_type, image_url)
    SELECT p_order_id, ord::INT, e->>'service_name', COALESCE(e->>'service_type', ''),
           (e->>'rate')::NUMERIC, (e->>'quantity')::INT, COALESCE(e->>'garment_type', 'shirt'),
           NULLIF(e->>'image_url', '')
    FROM jsonb_array_elements(p_items) WITH ORDINALITY AS t(e, ord);

    PERFORM _recompute_order_totals(p_order_id);
    RETURN (SELECT jsonb_build_object('order_id', order_id, 'total_kes', total_kes, 'payment_status_label', payment_status_label)
            FROM orders WHERE order_id = p_order_id);
END;
$$;
