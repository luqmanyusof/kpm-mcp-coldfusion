const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { CallToolRequestSchema, ListToolsRequestSchema } = require("@modelcontextprotocol/sdk/types.js");
const axios = require("axios");

const API_BASE_URL = "http://127.0.0.1:8500/kpm-mcp-coldfusion/crud/api_murid.cfm";

function translateError(error) {
  if (error.response) {
    const status = error.response.status;
    const data = error.response.data;

    if (status === 404) return "Student not found.";
    if (status === 400 && data && data.error) return `Invalid input: ${data.error}`;
    
    if (data && typeof data === 'object' && data.error) {
      return `API Error (${status}): ${data.error}`;
    }
    
    if (typeof data === 'string' && data.length > 0) {
      return `API Response (${status}): ${data}`;
    }

    if (status >= 500) return `Internal Server Error (${status}). Please check API logs.`;
  }
  return `Connection error: ${error.message}`;
}

const server = new Server(
  {
    name: "murid-manager",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "list_students",
        description: "List all students from the murid database",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "get_student",
        description: "Get detailed information for a specific student by their ID",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "string",
              description: "The student ID",
            },
          },
          required: ["id"],
        },
      },
      {
        name: "add_student",
        description: "Add a new student to the murid database",
        inputSchema: {
          type: "object",
          properties: {
            nama: { type: "string", description: "Full name" },
            no_kp: { type: "string", description: "IC number (12 digits)" },
            jantina: { type: "string", description: "Gender" },
            tingkatan: { type: "integer", description: "Year (1-5)" },
            kelas: { type: "string", description: "Class name" },
            tarikh_lahir: { type: "string", description: "DOB (YYYY-MM-DD)" },
            bangsa: { type: "string", description: "Race" },
            agama: { type: "string", description: "Religion" },
            pendapatan_isi_rumah: { type: "number", description: "Household income" },
            bilangan_adik_beradik: { type: "integer", description: "Number of siblings" },
          },
          required: ["nama", "no_kp", "jantina", "tingkatan", "kelas"],
        },
      },
      {
        name: "update_student",
        description: "Update an existing student's information",
        inputSchema: {
          type: "object",
          properties: {
            id: { type: "string", description: "The student ID to update" },
            nama: { type: "string", description: "Full name" },
            no_kp: { type: "string", description: "IC number (12 digits)" },
            jantina: { type: "string", description: "Gender" },
            tingkatan: { type: "integer", description: "Year (1-5)" },
            kelas: { type: "string", description: "Class name" },
            tarikh_lahir: { type: "string", description: "DOB (YYYY-MM-DD)" },
            bangsa: { type: "string", description: "Race" },
            agama: { type: "string", description: "Religion" },
            pendapatan_isi_rumah: { type: "number", description: "Household income" },
            bilangan_adik_beradik: { type: "integer", description: "Number of siblings" },
          },
          required: ["id", "nama", "no_kp", "jantina", "tingkatan", "kelas"],
        },
      },
      {
        name: "delete_student",
        description: "Remove a student from the database. REQUIRES user confirmation.",
        inputSchema: {
          type: "object",
          properties: {
            id: { type: "string", description: "The student ID to delete" },
          },
          required: ["id"],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "list_students") {
    try {
      const response = await axios.get(API_BASE_URL);
      const data = response.data;

      if (!data || !data.data) {
        return {
          content: [{ type: "text", text: "No students found or invalid API response." }],
          isError: true,
        };
      }

      const studentList = data.data.map((s, i) => 
        `${i + 1}. ${s.nama} (ID: ${s.id}, Class: ${s.kelas})`
      ).join("\n");

      return {
        content: [{ type: "text", text: studentList || "The student list is currently empty." }],
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: translateError(error) }],
        isError: true,
      };
    }
  }

  if (request.params.name === "get_student") {
    const studentId = request.params.arguments.id;
    try {
      const response = await axios.get(`${API_BASE_URL}?id=${studentId}`);
      const data = response.data;

      if (!data || !data.data) {
        return {
          content: [{ type: "text", text: "Student not found." }],
          isError: true,
        };
      }

      const s = data.data;
      const details = [
        `Name: ${s.nama}`,
        `ID: ${s.id}`,
        `IC (no_kp): ${s.no_kp}`,
        `Gender: ${s.jantina}`,
        `Year (tingkatan): ${s.tingkatan}`,
        `Class: ${s.kelas}`,
        `DOB: ${s.tarikh_lahir || "N/A"}`,
        `Race: ${s.bangsa || "N/A"}`,
        `Religion: ${s.agama || "N/A"}`,
        `Household Income: ${s.pendapatan_isi_rumah || "N/A"}`,
        `Siblings: ${s.bilangan_adik_beradik || "N/A"}`,
      ].join("\n");

      return {
        content: [{ type: "text", text: details }],
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: translateError(error) }],
        isError: true,
      };
    }
  }

  if (request.params.name === "add_student") {
    const args = request.params.arguments;

    if (!/^\d{12}$/.test(args.no_kp)) {
      return {
        content: [{ type: "text", text: "Invalid IC format: no_kp must be exactly 12 digits." }],
        isError: true,
      };
    }

    const tingkatan = parseInt(args.tingkatan, 10);
    if (isNaN(tingkatan) || tingkatan < 1 || tingkatan > 5) {
      return {
        content: [{ type: "text", text: "Invalid Tingkatan: must be a number between 1 and 5." }],
        isError: true,
      };
    }

    const body = {
      ...args,
      tingkatan: tingkatan,
      pendapatan_isi_rumah: args.pendapatan_isi_rumah ? parseFloat(args.pendapatan_isi_rumah) : null,
      bilangan_adik_beradik: args.bilangan_adik_beradik ? parseInt(args.bilangan_adik_beradik, 10) : null,
    };

    try {
      const response = await axios.post(API_BASE_URL, body);
      return {
        content: [{ type: "text", text: response.data.message || "Student created successfully." }],
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: translateError(error) }],
        isError: true,
      };
    }
  }

  if (request.params.name === "update_student") {
    const args = request.params.arguments;
    const studentId = args.id;

    const { id, ...bodyArgs } = args;

    if (!/^\d{12}$/.test(bodyArgs.no_kp)) {
      return {
        content: [{ type: "text", text: "Invalid IC format: no_kp must be exactly 12 digits." }],
        isError: true,
      };
    }

    const tingkatan = parseInt(bodyArgs.tingkatan, 10);
    if (isNaN(tingkatan) || tingkatan < 1 || tingkatan > 5) {
      return {
        content: [{ type: "text", text: "Invalid Tingkatan: must be a number between 1 and 5." }],
        isError: true,
      };
    }

    const body = {
      ...bodyArgs,
      tingkatan: tingkatan,
      pendapatan_isi_rumah: bodyArgs.pendapatan_isi_rumah ? parseFloat(bodyArgs.pendapatan_isi_rumah) : null,
      bilangan_adik_beradik: bodyArgs.bilangan_adik_beradik ? parseInt(bodyArgs.bilangan_adik_beradik, 10) : null,
    };

    try {
      const response = await axios.put(`${API_BASE_URL}?id=${studentId}`, body);
      return {
        content: [{ type: "text", text: response.data.message || "Student updated successfully." }],
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: translateError(error) }],
        isError: true,
      };
    }
  }

  if (request.params.name === "delete_student") {
    const studentId = request.params.arguments.id;
    try {
      const response = await axios.delete(`${API_BASE_URL}?id=${studentId}`);
      return {
        content: [{ type: "text", text: response.data.message || "Student deleted successfully." }],
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: translateError(error) }],
        isError: true,
      };
    }
  }

  throw new Error(`Tool not found: ${request.params.name}`);
});
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Murid MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error in main():", error);
  process.exit(1);
});
