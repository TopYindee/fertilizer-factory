// src/api.js - ชั้นกลางสำหรับสลับฐานข้อมูล (ไม่กระทบตอนนี้)
// ตอนนี้: ใช้ Supabase (Postgres) เดิม 100% ผ่าน src/supabaseConfig.js
// อนาคต: เปลี่ยน USE_MSSQL = true แล้วแก้ฟังก์ชันข้างในให้ยิงไป SQL Server API (https://api.worldfert.co.th)

import { createClient } from "@supabase/supabase-js";
import { SUPABASE_URL, SUPABASE_ANON_KEY } from "./supabaseConfig.js";

const USE_MSSQL = false; // สวิตช์เดียว: false = Supabase Cloud (ตอนนี้), true = SQL Server On-Premise
const MSSQL_API_BASE = "https://api.worldfert.co.th"; // ใช้เมื่อ USE_MSSQL = true (ผ่าน Cloudflare Tunnel)

function getSupabaseClient() {
  const url = SUPABASE_URL || localStorage.getItem("sb_url");
  const key = SUPABASE_ANON_KEY !== "วาง_Anon_Key_ของคุณที่นี่" ? SUPABASE_ANON_KEY : localStorage.getItem("sb_key");
  if (!url || !key) return null;
  return createClient(url, key);
}

// ตัวอย่าง: ห่อการเรียก Supabase ไว้ - ตอนนี้เรียก Supabase ตรง, อนาคตเปลี่ยนข้างในเป็น fetch ไป SQL Server

export async function apiFetchTable(table, opts = {}) {
  if (!USE_MSSQL) {
    const supabase = getSupabaseClient();
    if (!supabase) throw new Error("Supabase not configured");
    let q = supabase.from(table).select("*");
    if (opts.order) q = q.order(opts.order, { ascending: false });
    if (opts.like) q = q.like(opts.like.field, opts.like.value);
    if (opts.limit) q = q.limit(opts.limit);
    const { data, error } = await q;
    if (error) throw error;
    return data;
  } else {
    // อนาคต SQL Server: ยิงไป API
    const res = await fetch(`${MSSQL_API_BASE}/${table}?${new URLSearchParams(opts)}`);
    if (!res.ok) throw new Error("MSSQL API error");
    return res.json();
  }
}

export async function apiInsert(table, rows) {
  if (!USE_MSSQL) {
    const supabase = getSupabaseClient();
    const { error } = await supabase.from(table).insert(rows);
    if (error) throw error;
  } else {
    const res = await fetch(`${MSSQL_API_BASE}/${table}`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(rows) });
    if (!res.ok) throw new Error("MSSQL API insert error");
  }
}

export async function apiUpdate(table, id, payload) {
  if (!USE_MSSQL) {
    const supabase = getSupabaseClient();
    const { error } = await supabase.from(table).update(payload).eq("id", id);
    if (error) throw error;
  } else {
    const res = await fetch(`${MSSQL_API_BASE}/${table}/${id}`, { method: "PUT", headers: { "Content-Type": "application/json" }, body: JSON.stringify(payload) });
    if (!res.ok) throw new Error("MSSQL API update error");
  }
}

export async function apiDelete(table, id) {
  if (!USE_MSSQL) {
    const supabase = getSupabaseClient();
    const { error } = await supabase.from(table).delete().eq("id", id);
    if (error) throw error;
  } else {
    const res = await fetch(`${MSSQL_API_BASE}/${table}/${id}`, { method: "DELETE" });
    if (!res.ok) throw new Error("MSSQL API delete error");
  }
}

export async function apiLogin(username, password) {
  if (!USE_MSSQL) {
    const supabase = getSupabaseClient();
    // ใช้ ilike ให้พิมพ์เล็กใหญ่ก็ได้ (ตามที่แก้ล่าสุด)
    const { data, error } = await supabase.from("employees").select("*").ilike("username", username.trim()).single();
    if (error || !data) throw new Error("ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง");
    if (String(data.password).toLowerCase() !== String(password).trim().toLowerCase()) throw new Error("ชื่อผู้ใช้งานหรือรหัสผ่านไม่ถูกต้อง");
    if (data.status === "ระงับ") throw new Error("บัญชีนี้ถูกระงับการใช้งาน");
    return data;
  } else {
    const res = await fetch(`${MSSQL_API_BASE}/login`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ username, password }) });
    if (!res.ok) throw new Error("Login failed");
    return res.json();
  }
}

// หมายเหตุ: ตอนนี้ src/App.vue ยังเรียก Supabase ตรงๆ อยู่ (ไม่กระทบ)
// อนาคตค่อยเปลี่ยน src/App.vue ให้เรียก apiFetchTable/apiInsert แทน ทีละหน้าได้เลย ไม่ต้องแก้ทีเดียว

export const API_INFO = {
  USE_MSSQL,
  MSSQL_API_BASE,
  note: "โครงนี้ไม่กระทบการใช้งานตอนนี้ - ยังใช้ Supabase Cloud 100%",
};
