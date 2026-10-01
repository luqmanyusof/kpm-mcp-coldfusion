const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");

async function testFaultInjection() {
  const transport = new StdioClientTransport({
    command: "C:\\Program Files\\nodejs\\node.exe",
    args: ["C:\\ColdFusion2021\\cfusion\\wwwroot\\kpm-mcp-coldfusion\\crud\\mcp-server\\index.js"],
  });

  const client = new Client(
    { name: "test-client", version: "1.0.0" },
    { capabilities: {} }
  );

  await client.connect(transport);
  console.log("Connected to MCP server");

  try {
    console.log("\\n--- Testing 500 Error Handling (Invalid ID) ---");
    const res1 = await client.callTool({
      name: "get_student",
      arguments: { id: "9999" },
    });
    console.log("Result:", res1.content[0].text);
    console.log("isError:", res1.isError);

    console.log("\\n--- Testing MCP-side Validation (Bad IC) ---");
    const res2 = await client.callTool({
      name: "add_student",
      arguments: {
        nama: "Bad IC",
        no_kp: "123",
        jantina: "Lelaki",
        tingkatan: "2",
        kelas: "Test",
      },
    });
    console.log("Result:", res2.content[0].text);
    console.log("isError:", res2.isError);

  } catch (error) {
    console.error("Tool Call Failed:", error);
  } finally {
    process.exit();
  }
}

testFaultInjection();
