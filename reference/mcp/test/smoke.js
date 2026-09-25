/*
 * Smoke test for the reference MCP server - no ColdFusion or Oracle needed.
 * Starts a tiny fake murid API (same contract as API.md), launches index.js over stdio
 * exactly like Claude Desktop does, and calls every tool.   Run:  npm test
 */
import http from "node:http";
import { fileURLToPath } from "node:url";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const KEY = "test-key";
let nextId = 3;
const rows = new Map([
  [1, { id: 1, nama: "Ahmad Danish bin Rosli", no_kp: "090312-10-5217", jantina: "Lelaki", tingkatan: 5, kelas: "Bestari", tarikh_lahir: "2009-03-12", bangsa: "Melayu", agama: "Islam", pendapatan_isi_rumah: 3500, bilangan_adik_beradik: 2 }],
  [2, { id: 2, nama: "Nur Aisyah binti Kamal", no_kp: "100725-14-6320", jantina: "Perempuan", tingkatan: 4, kelas: "Cerdik", tarikh_lahir: "2010-07-25", bangsa: "Melayu", agama: "Islam", pendapatan_isi_rumah: 8200, bilangan_adik_beradik: 4 }],
]);

const api = http.createServer(async (req, res) => {
  const send = (s, b) => { res.writeHead(s, { "Content-Type": "application/json" }); res.end(JSON.stringify(b)); };
  if (req.headers["x-api-key"] !== KEY) return send(401, { error: "Missing or wrong API key." });
  const u = new URL(req.url, "http://x");
  const id = u.searchParams.get("id") ? Number(u.searchParams.get("id")) : undefined;
  let body = "";
  for await (const c of req) body += c;
  const b = body ? JSON.parse(body) : {};
  if (req.method === "GET" && id === undefined) {
    let data = [...rows.values()];
    if (u.searchParams.get("tingkatan")) data = data.filter((r) => r.tingkatan === Number(u.searchParams.get("tingkatan")));
    return send(200, { data });
  }
  if (id !== undefined && !rows.has(id)) return send(404, { error: "Not found." });
  if (req.method === "GET") return send(200, { data: rows.get(id) });
  if (req.method === "POST") { const r = { id: nextId++, bangsa: "Melayu", pendapatan_isi_rumah: 0, bilangan_adik_beradik: 0, ...b }; rows.set(r.id, r); return send(201, { data: r }); }
  if (req.method === "PUT") { Object.assign(rows.get(id), b); return send(200, { data: rows.get(id) }); }
  if (req.method === "DELETE") { rows.delete(id); return send(200, { deleted: true, id }); }
  send(405, { error: "Method not supported." });
});
await new Promise((r) => api.listen(0, r));
const baseUrl = `http://127.0.0.1:${api.address().port}/murid.cfm`;

async function connect(key) {
  const client = new Client({ name: "smoke-test", version: "1.0.0" });
  await client.connect(new StdioClientTransport({
    command: process.execPath,
    args: [fileURLToPath(new URL("../index.js", import.meta.url))],
    env: { ...process.env, API_BASE_URL: baseUrl, API_KEY: key },
    stderr: "ignore",
  }));
  return client;
}

let failed = 0;
const check = (label, ok, extra = "") => { console.log(`${ok ? "PASS" : "FAIL"}  ${label}${ok ? "" : "  " + extra}`); if (!ok) failed++; };
const text = (r) => r.content?.[0]?.text ?? "";

const c = await connect(KEY);
const { tools } = await c.listTools();
check("5 tools listed", tools.map((t) => t.name).sort().join() === "create_murid,delete_murid,get_murid,list_murid,update_murid", tools.map((t) => t.name).join());

let r = await c.callTool({ name: "list_murid", arguments: {} });
check("list_murid returns 2 rows", !r.isError && JSON.parse(text(r)).length === 2, text(r));

r = await c.callTool({ name: "list_murid", arguments: { tingkatan: 4 } });
check("list_murid filters by tingkatan", JSON.parse(text(r)).length === 1, text(r));

r = await c.callTool({ name: "get_murid", arguments: { id: 1 } });
check("get_murid returns the record", JSON.parse(text(r)).nama === "Ahmad Danish bin Rosli", text(r));

r = await c.callTool({ name: "create_murid", arguments: { nama: "Chong Ke Xin", no_kp: "120409-10-5566", jantina: "Perempuan", tingkatan: 2, kelas: "Amanah", tarikh_lahir: "2012-04-09", agama: "Buddha" } });
const created = JSON.parse(text(r));
check("create_murid adds a record", !r.isError && created.id === 3, text(r));

r = await c.callTool({ name: "update_murid", arguments: { id: 3, kelas: "Bestari" } });
check("update_murid changes one field", JSON.parse(text(r)).kelas === "Bestari", text(r));

r = await c.callTool({ name: "update_murid", arguments: { id: 3 } });
check("update_murid with no changes is refused", r.isError === true, text(r));

r = await c.callTool({ name: "create_murid", arguments: { nama: "X", no_kp: "123", jantina: "Lelaki", tingkatan: 7, kelas: "A", tarikh_lahir: "2012-01-01", agama: "Islam" } });
check("bad input (tingkatan 7, bad IC) rejected before the API", r.isError === true && /tingkatan|no_kp/.test(text(r)), text(r));

r = await c.callTool({ name: "delete_murid", arguments: { id: 3 } });
check("delete_murid without confirm is refused", r.isError === true, text(r));

r = await c.callTool({ name: "delete_murid", arguments: { id: 3, confirm: true } });
check("delete_murid with confirm works", !r.isError && JSON.parse(text(r)).deleted === true, text(r));

r = await c.callTool({ name: "get_murid", arguments: { id: 3 } });
check("deleted record is gone (404 reported)", r.isError === true && text(r).includes("404"), text(r));
await c.close();

const bad = await connect("wrong-key");
r = await bad.callTool({ name: "list_murid", arguments: {} });
check("wrong key -> 401 reported, key not leaked", r.isError === true && text(r).includes("401") && !text(r).includes("wrong-key"), text(r));
await bad.close();

api.close();
console.log(failed ? `\n${failed} FAILED` : "\nALL PASSED");
process.exit(failed ? 1 : 0);
