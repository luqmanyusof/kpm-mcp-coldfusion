const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");

async function testAddStudent() {
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
    console.log("\\n--- Testing Valid Student ---");
    const res1 = await client.callTool({
      name: "add_student",
      arguments: {
        nama: "Test Student",
        no_kp: "123456789012",
        jantina: "Lelaki",
        tingkatan: "2",
        kelas: "Test Class",
      },
    });
    console.log(res1.content[0].text);

    console.log("\\n--- Testing Invalid IC (too short) ---");
    const res2 = await client.callTool({
      name: "add_student",
      arguments: {
        nama: "Bad IC",
        no_kp: "123",
        jantina: "Lelaki",
        tingkatan: "2",
        kelas: "Test Class",
      },
    });
    console.log(res2.content[0].text);
    console.log("isError:", res2.isError);

    console.log("\\n--- Testing Invalid Tingkatan (6) ---");
    const res3 = await client.callTool({
      name: "add_student",
      arguments: {
        nama: "Bad Year",
        no_kp: "123456789012",
        jantina: "Lelaki",
        tingkatan: "6",
        kelas: "Test Class",
      },
    });
    console.log(res3.content[0].text);
    console.log("isError:", res3.isError);

  } catch (error) {
    console.error("Tool Call Failed:", error);
  } finally {
    process.exit();
  }
}

testAddStudent();
