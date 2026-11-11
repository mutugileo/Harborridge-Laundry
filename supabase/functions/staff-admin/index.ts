// staff-admin: create worker accounts and reset their passwords.
//
// Creating a Supabase Auth user needs the secret key, so it cannot run in the
// browser. This function checks that the caller is an active admin in
// public.staff before doing anything.
//
// Deployed with verify_jwt = false: the project uses the new publishable /
// secret keys, which the gateway's JWT check does not understand. The caller's
// session token is verified below with auth.getUser instead.
import { createClient } from "npm:@supabase/supabase-js@2.49.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const MODULE_KEYS = new Set([
  "dashboard", "orders", "orderStatus", "dispatch", "customers", "vendors",
  "services", "payments", "settlements", "inventory", "staff", "reports",
  "settings",
]);
const ROLES = new Set(["admin", "manager", "productionLead", "cashier", "driver"]);
const MIN_PASSWORD_LENGTH = 8;

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function secretKey(): string {
  const keys = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (keys) {
    const parsed = JSON.parse(keys) as Record<string, string>;
    if (parsed["default"]) return parsed["default"];
  }
  const legacy = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!legacy) throw new Error("No secret key available to the function");
  return legacy;
}

function cleanString(value: unknown, max = 200): string {
  return typeof value === "string" ? value.trim().slice(0, max) : "";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json(405, { error: "Method not allowed" });

  const admin = createClient(Deno.env.get("SUPABASE_URL")!, secretKey(), {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  // 1. Who is calling?
  const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!token) return json(401, { error: "Sign in first." });
  const { data: userData, error: userError } = await admin.auth.getUser(token);
  if (userError || !userData?.user) return json(401, { error: "Your session has expired. Sign in again." });

  const { data: caller, error: callerError } = await admin
    .from("staff")
    .select("id, role, is_active")
    .eq("id", userData.user.id)
    .maybeSingle();
  if (callerError) return json(500, { error: "Could not check your permissions." });
  if (!caller || !caller.is_active || caller.role !== "admin") {
    return json(403, { error: "Only an active admin can manage worker accounts." });
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json(400, { error: "Request body must be JSON." });
  }

  const action = cleanString(body.action, 40);

  // 2a. Create a worker: auth user + staff row, rolled back together.
  if (action === "create") {
    const email = cleanString(body.email, 254).toLowerCase();
    const fullName = cleanString(body.fullName, 120);
    const password = typeof body.password === "string" ? body.password : "";
    const role = cleanString(body.role, 40) || "manager";
    const excepted = Array.isArray(body.exceptedModules)
      ? (body.exceptedModules as unknown[]).filter(
          (m): m is string => typeof m === "string" && MODULE_KEYS.has(m) && m !== "dashboard",
        )
      : [];

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return json(400, { error: "Enter a valid work email." });
    if (!fullName) return json(400, { error: "Enter the worker's full name." });
    if (password.length < MIN_PASSWORD_LENGTH) {
      return json(400, { error: `Initial password must be at least ${MIN_PASSWORD_LENGTH} characters.` });
    }
    if (!ROLES.has(role)) return json(400, { error: "Unknown role." });

    const { data: created, error: createError } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: fullName },
    });
    if (createError || !created?.user) {
      const exists = createError?.message?.toLowerCase().includes("already");
      return json(exists ? 409 : 400, {
        error: exists ? `An account for ${email} already exists.` : (createError?.message ?? "Could not create the account."),
      });
    }

    const row = {
      id: created.user.id,
      email,
      full_name: fullName,
      phone: cleanString(body.phone, 40),
      role,
      role_title: cleanString(body.roleTitle, 80) || "Staff",
      branch: cleanString(body.branch, 120) || "Harborridge Main",
      excepted_modules: excepted,
    };
    const { data: staffRow, error: staffError } = await admin
      .from("staff")
      .insert(row)
      .select()
      .single();
    if (staffError) {
      await admin.auth.admin.deleteUser(created.user.id);
      return json(500, { error: "Could not save the worker profile. Nothing was created." });
    }
    return json(200, { worker: staffRow });
  }

  // 2b. Reset a worker's password.
  if (action === "set_password") {
    const workerId = cleanString(body.workerId, 64);
    const password = typeof body.password === "string" ? body.password : "";
    if (password.length < MIN_PASSWORD_LENGTH) {
      return json(400, { error: `Password must be at least ${MIN_PASSWORD_LENGTH} characters.` });
    }
    const { data: target } = await admin.from("staff").select("id").eq("id", workerId).maybeSingle();
    if (!target) return json(404, { error: "Worker not found." });

    const { error } = await admin.auth.admin.updateUserById(workerId, { password });
    if (error) return json(400, { error: error.message });
    return json(200, { ok: true });
  }

  return json(400, { error: "Unknown action." });
});
