# REQUIREMENTS-mcp.md

## 1 One-line goal
Build a Node.js MCP server that allows an AI assistant to manage students via the murid API.

## 2 Context
The AI assistant will interact with a ColdFusion REST API to perform CRUD operations on student records, allowing users to manage student data using plain English.

## 3 Data
- API Endpoint: http://127.0.0.1:8500/kpm-mcp-coldfusion/crud/api_murid.cfm
- Table: murid
- Columns (from api_murid.cfm):
  - id (Integer, Primary Key)
  - nama (Varchar, Required)
  - no_kp (Varchar, Required, 12 digits)
  - jantina (Varchar, Required)
  - tingkatan (Integer, Required, 1-5)
  - kelas (Varchar, Required)
  - tarikh_lahir (Date, Optional)
  - bangsa (Varchar, Optional)
  - agama (Varchar, Optional)
  - pendapatan_isi_rumah (Numeric, Optional)
  - bilangan_adik_beradik (Integer, Optional)
- Datasource: cf_test_crud

## 4 Hard constraints
- The MCP server must be implemented in Node.js.
- The MCP server must reside in the `mcp-server/` directory.
- All tool inputs must be validated against the murid API rules before the API is called.
- Deletion must require explicit user confirmation.

## 5 SECURITY requirements
- Access Key: None (local testing only).
- Input Validation:
  - All required fields (nama, no_kp, jantina, tingkatan, kelas) must be present.
  - no_kp must be exactly 12 digits.
  - tingkatan must be an integer between 1 and 5.
- Error Handling:
  - Translate API error responses (JSON) into plain English.
  - Never expose internal API keys or stack traces.
- Least Privilege: Tools only expose operations defined in the scope.

## 6 Functional requirements
1. tool `list_students`: Calls GET /api_murid.cfm and returns the list of students.
2. tool `get_student`: Calls GET /api_murid.cfm?id=X and returns specific student details.
3. tool `add_student`: Validates input and calls POST /api_murid.cfm to create a record.
4. tool `update_student`: Validates input and calls PUT /api_murid.cfm?id=X to update a record.
5. tool `delete_student`: Requires confirmation, then calls DELETE /api_murid.cfm?id=X to remove a record.

## 7 Non-functional requirements
- Response time for tools should be minimal.
- Tool descriptions must be clear so the AI knows when to use them.

## 8 Interfaces / data contract
- Input: JSON objects as defined by the tool schemas.
- Output: Plain text summaries of the API's JSON responses.
- API Response Mapping:
  - 200/201 -> Success message with data.
  - 400 -> "Invalid input: [API Error Message]"
  - 404 -> "Student not found."
  - 500 -> "An internal server error occurred."

## 9 Explicitly OUT of scope
- Modifying the ColdFusion API code.
- Implementing authentication/API keys.
- Managing the database directly (all access via API).

## 10 Acceptance criteria
- [ ] `list_students` returns student list from API.
- [ ] `get_student` returns student data for a valid ID.
- [ ] `add_student` creates a student and returns success.
- [ ] `update_student` updates student data and returns success.
- [ ] `delete_student` removes a student after confirmation.
- [ ] Input with invalid IC (no_kp) is rejected by MCP before API call.
- [ ] Input with invalid Tingkatan is rejected by MCP before API call.
- [ ] Request for a missing ID returns a plain-English 404 error.

## 11 Known traps / where the AI is likely to be wrong
- The API uses query parameters for IDs (`?id=X`) but a JSON body for POST/PUT.
- IC (no_kp) validation must be strictly 12 digits.
- Tingkatan must be checked as a number between 1 and 5.
- The API endpoint is a .cfm file, which might confuse some standard REST assumptions.
