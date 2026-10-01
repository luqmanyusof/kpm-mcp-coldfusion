const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");

async function testUpdateStudent() {
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
    console.log("\\n--- Testing Valid Update (ID 5) ---");
    const res1 = await client.callTool({
      name: "update_student",
      arguments: {
        id: "5",
        nama: "Lim Mei Ling Updated",
        no_kp: "130930086144",
        jantina: "Perempuan",
        tingkatan: "1",
        kelas: "Cerdik Updated",
      },
    });
    console.log(res1.content[0].text);

    console.log("\\n--- Testing Invalid Tingkatan (6) ---");
    const res2 = await client.callTool({
      name: "update_student",
      arguments: {
        id: "5",
        nama: "Invalid Year",
        no_kp: "130930086144",
        jantina: "Perempuan",
        tingkatan: "6",
        kelas: "Cerdik",
      },
    });
    console.log(res2.content[0].text);
    console.log("isError:", res2.isError);

    console.log("\\n--- Testing Invalid ID (9999) ---");
    const res3 = await client.callTool({
      name: "update_student",
      arguments: {
        id: "9999",
        nama: "Missing Student",
        no_kp: "130930086144",
        jantina: "Perempuan",
        tingkatan: "1",
        kelas: "Cerdik",
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

testUpdateStudent();
