const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");

async function runAcceptanceTests() {
  const transport = new StdioClientTransport({
    command: "C:\\Program Files\\nodejs\\node.exe",
    args: ["C:\\ColdFusion2021\\cfusion\\wwwroot\\kpm-mcp-coldfusion\\crud\\mcp-server\\index.js"],
  });

  const client = new Client(
    { name: "acceptance-client", version: "1.0.0" },
    { capabilities: {} }
  );

  await client.connect(transport);
  console.log("Connected to MCP server\n");

  const tests = [
    {
      name: "list_students",
      action: async () => await client.callTool({ name: "list_students", arguments: {} }),
      expected: "list of students",
    },
    {
      name: "get_student (Valid)",
      action: async () => await client.callTool({ name: "get_student", arguments: { id: "5" } }),
      expected: "student details",
    },
    {
      name: "get_student (Invalid)",
      action: async () => await client.callTool({ name: "get_student", arguments: { id: "9999" } }),
      expected: "Student not found.",
    },
    {
      name: "add_student (Validation - Bad IC)",
      action: async () => await client.callTool({ 
        name: "add_student", 
        arguments: { nama: "Test", no_kp: "123", jantina: "L", tingkatan: "1", kelas: "A" } 
      }),
      expected: "Invalid IC format",
    },
    {
      name: "add_student (Validation - Bad Year)",
      action: async () => await client.callTool({ 
        name: "add_student", 
        arguments: { nama: "Test", no_kp: "123456789012", jantina: "L", tingkatan: "6", kelas: "A" } 
      }),
      expected: "Invalid Tingkatan",
    },
    {
      name: "update_student (Validation - Bad IC)",
      action: async () => await client.callTool({ 
        name: "update_student", 
        arguments: { id: "5", nama: "Test", no_kp: "123", jantina: "L", tingkatan: "1", kelas: "A" } 
      }),
      expected: "Invalid IC format",
    },
    {
      name: "delete_student (Valid)",
      action: async () => await client.callTool({ name: "delete_student", arguments: { id: "5" } }),
      expected: "deleted successfully",
    },
  ];

  for (const test of tests) {
    try {
      console.log(`Testing ${test.name}...`);
      const result = await test.action();
      const text = result.content[0].text;
      console.log(`Result: ${text}`);
      if (text.includes(test.expected) || (test.expected === "list of students" && text.includes("1."))) {
        console.log("PASS");
      } else {
        console.log("FAIL (Unexpected response)");
      }
    } catch (e) {
      console.log(`FAIL: ${e.message}`);
    }
    console.log("-----------------------------------");
  }

  process.exit();
}

runAcceptanceTests();
