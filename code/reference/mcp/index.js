#!/usr/bin/env node
/*
 * REFERENCE MCP SERVER for the murid API - the answer key for Days 2-3.
 *
 * It gives an AI assistant 5 tools (list, get, create, update, delete) that call the
 * ColdFusion REST API from Day 2. The AI never touches the database directly.
 *
 * Settings come from environment variables (set in the MCP client's config, never in code):
 *   API_BASE_URL  e.g. http://localhost:8500/kpm-mcp-coldfusion/code/reference/api/murid.cfm
 *   API_KEY       the key from C:\course-secrets\api-key.txt
 *
 * Transport is stdio: the client starts this file and talks to it over stdin/stdout.
 * So NEVER console.log() here - stdout belongs to the protocol. Use console.error() for notes.
 */
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const API_BASE_URL = process.env.API_BASE_URL;
const API_KEY = process.env.API_KEY;

if (!API_BASE_URL || !API_KEY) {
  console.error("murid-mcp: set API_BASE_URL and API_KEY in the MCP client config.");
  process.exit(1);
}

// ---- the contract (same rules as code/reference/api/API.md) ----------------------------
// Checked here too, so a bad tool call is rejected before it ever reaches the app.
const fields = {
  nama: z.string().min(1).max(100).describe("Full name"),
  no_kp: z.string().regex(/^\d{6}-\d{2}-\d{4}$/).describe("IC number, format 090312-10-5217"),
  jantina: z.enum(["Lelaki", "Perempuan"]).describe("Gender"),
  tingkatan: z.number().int().min(1).max(5).describe("Form, 1-5"),
  kelas: z.string().min(1).max(30).describe("Class name, e.g. Bestari"),
  tarikh_lahir: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).describe("Date of birth, yyyy-mm-dd"),
  bangsa: z.enum(["Melayu", "Cina", "India", "Lain-lain"]).describe("Ethnicity"),
  agama: z.string().min(1).max(30).describe("Religion"),
  pendapatan_isi_rumah: z.number().min(0).describe("Household income, RM per month"),
  bilangan_adik_beradik: z.number().int().min(0).max(30).describe("Number of siblings"),
};
const id = z.number().int().min(1).describe("The student's id");

// ---- one place that talks to the API -------------------------------------------------------
async function callApi(method, { id: recordId, query = {}, body } = {}) {
  const url = new URL(API_BASE_URL);
  if (recordId !== undefined) url.searchParams.set("id", String(recordId));
  for (const [k, v] of Object.entries(query)) if (v !== undefined) url.searchParams.set(k, String(v));

  let res;
  try {
    res = await fetch(url, {
      method,
      headers: { "X-API-Key": API_KEY, "Content-Type": "application/json" },
      body: body === undefined ? undefined : JSON.stringify(body),
      signal: AbortSignal.timeout(10000),
    });
  } catch {
    return fail("Cannot reach the app. Is ColdFusion running and API_BASE_URL right?");
  }

  let json;
  try {
    json = await res.json();
  } catch {
    return fail(`The app answered ${res.status} with something that is not JSON.`);
  }
  if (!res.ok) return fail(`The app said ${res.status}: ${json.error ?? "unknown error"}`);
  return { content: [{ type: "text", text: JSON.stringify(json.data ?? json, null, 2) }] };
}

// A tool error the AI can read and explain - never the key, never a stack trace.
function fail(message) {
  return { isError: true, content: [{ type: "text", text: message }] };
}

// ---- the tools ------------------------------------------------------------------------------
const server = new McpServer({ name: "murid", version: "1.0.0" });

server.registerTool(
  "list_murid",
  {
    title: "List students",
    description: "List students, optionally only one form (tingkatan) or names containing some text.",
    inputSchema: {
      tingkatan: fields.tingkatan.optional(),
      q: z.string().min(1).max(100).optional().describe("Part of a name to search for"),
    },
    annotations: { readOnlyHint: true },
  },
  async ({ tingkatan, q }) => callApi("GET", { query: { tingkatan, q } })
);

server.registerTool(
  "get_murid",
  {
    title: "Get one student",
    description: "Get one student's full record by id.",
    inputSchema: { id },
    annotations: { readOnlyHint: true },
  },
  async ({ id: recordId }) => callApi("GET", { id: recordId })
);

server.registerTool(
  "create_murid",
  {
    title: "Add a student",
    description: "Add a new student. Ask the user for any required field you do not know - never guess an IC number or date of birth.",
    inputSchema: {
      ...fields,
      bangsa: fields.bangsa.optional(),
      pendapatan_isi_rumah: fields.pendapatan_isi_rumah.optional(),
      bilangan_adik_beradik: fields.bilangan_adik_beradik.optional(),
    },
  },
  async (args) => callApi("POST", { body: args })
);

server.registerTool(
  "update_murid",
  {
    title: "Change a student",
    description: "Change some fields of one student. Send only the fields that change.",
    inputSchema: {
      id,
      ...Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, v.optional()])),
    },
    annotations: { destructiveHint: true, idempotentHint: true },
  },
  async ({ id: recordId, ...changes }) => {
    if (Object.keys(changes).length === 0) return fail("Nothing to change - give at least one field.");
    return callApi("PUT", { id: recordId, body: changes });
  }
);

server.registerTool(
  "delete_murid",
  {
    title: "Delete a student",
    description:
      "Permanently delete one student. First show the user which student (get_murid) and ask them to confirm. " +
      "Only then call this with confirm set to true.",
    inputSchema: {
      id,
      confirm: z.literal(true).describe("Must be true, and only after the user has said yes"),
    },
    annotations: { destructiveHint: true },
  },
  async ({ id: recordId }) => callApi("DELETE", { id: recordId })
);

await server.connect(new StdioServerTransport());
console.error(`murid-mcp: ready, talking to ${API_BASE_URL}`);
