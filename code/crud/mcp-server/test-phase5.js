const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");

async function testDeleteStudent() {
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
    console.log("\\n--- Testing Valid Delete (ID 5) ---");
    // In a real scenario, the AI would ask the user for confirmation here.
    const res1 = await client.callTool({
      name: "delete_student",
      arguments: { id: "5" },
    });
    console.log(res1.content[0].text);

    console.log("\\n--- Testing Invalid ID (9999) ---");
    const res2 = await client.callTool({
      name: "delete_student",
      arguments: { id: "9999" },
    });
    console.log(res2.content[0].text);
    console.log("isError:", res2.isError);

  } catch (error) {
    console.error("Tool Call Failed:", error);
  } finally {
    process.exit();
  }
}

testDeleteStudent();
