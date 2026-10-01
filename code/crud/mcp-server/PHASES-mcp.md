# PHASES-mcp.md

**Pre-flight**
- Verify Node.js is installed.
- Confirm ColdFusion server is running.
- Confirm `http://127.0.0.1:8500/kpm-mcp-coldfusion/crud/api_murid.cfm` is reachable.
- Initialize `mcp-server/` with `npm init -y` and install `@modelcontextprotocol/sdk`.

**Phase 1: Skeleton and Proof of Life**
- **Goal** - Set up the MCP server and implement the `list_students` tool.
- **Build** - 
  - Create `index.js`.
  - Implement MCP server boilerplate.
  - Implement `list_students` tool calling GET /api_murid.cfm.
- **Security check** - none - read-only, no new input this phase.
- **RUN TEST** - Call `list_students` via MCP client; verify it returns a list of students from the API.
- **Expected result** - A JSON array of student records.
- **If it fails** - 1. Check if API is reachable at the provided URL. 2. Check Node.js console for connection errors.
- **Verified:** 

**Phase 2: Read-only Detail**
- **Goal** - Implement the `get_student` tool.
- **Build** - 
  - Implement `get_student` tool calling GET /api_murid.cfm?id=X.
  - Handle 404 Not Found responses from the API.
- **Security check** - none - read-only, no new input this phase.
- **RUN TEST** - Call `get_student` with a known valid ID, then with a non-existent ID.
- **Expected result** - Valid ID returns student details; invalid ID returns "Student not found."
- **If it fails** - 1. Verify query parameter format `?id=X`. 2. Check API 404 response body.
- **Verified:** 

**Phase 3: Creation with Validation**
- **Goal** - Implement the `add_student` tool with pre-API validation.
- **Build** - 
  - Implement `add_student` tool calling POST /api_murid.cfm.
  - Implement MCP-side validation for required fields, IC (12 digits), and Tingkatan (1-5).
- **Security check** - validate that bad input (e.g., 11 digit IC) is rejected before the API call.
- **RUN TEST** - Attempt to add a student with valid data, then with an invalid Tingkatan (6).
- **Expected result** - Valid data returns success; invalid Tingkatan returns a validation error from MCP.
- **If it fails** - 1. Check JSON body formatting for POST. 2. Verify validation logic regex for IC.
- **Verified:** 

**Phase 4: Update with Validation**
- **Goal** - Implement the `update_student` tool.
- **Build** - 
  - Implement `update_student` tool calling PUT /api_murid.cfm?id=X.
  - Apply the same validation rules as Phase 3.
- **Security check** - validate that updates to non-existent IDs return a 404.
- **RUN TEST** - Update a student's name with a valid ID; then attempt to update with invalid data.
- **Expected result** - Valid update returns success; invalid data returns validation error.
- **If it fails** - 1. Verify PUT method is handled correctly by the server. 2. Check ID query parameter.
- **Verified:** 

**Phase 5: Confirmed Deletion**
- **Goal** - Implement the `delete_student` tool with a confirmation guard.
- **Build** - 
  - Implement `delete_student` tool calling DELETE /api_murid.cfm?id=X.
  - Ensure the tool requires the AI to confirm the deletion with the user first.
- **Security check** - verify that no record is deleted without a confirmed request.
- **RUN TEST** - Call `delete_student` for a specific ID and verify the record is gone via `get_student`.
- **Expected result** - Record is deleted and success is returned.
- **If it fails** - 1. Check if DELETE method is enabled. 2. Verify ID is passed correctly.
- **Verified:** 

**Phase 6: Robustness and Fault Injection**
- **Goal** - Ensure the MCP handles all API failures gracefully.
- **Build** - 
  - Map all 4xx and 5xx API responses to plain English messages.
  - Test boundary cases for all validation rules.
- **Security check** - verify that no raw JSON errors or stack traces are shown to the user.
- **RUN TEST** - Trigger a 500 error (e.g., stop database) and a 400 error from the API.
- **Expected result** - User sees "An internal server error occurred" or a plain-English validation message.
- **If it fails** - 1. Check try-catch blocks in `index.js`. 2. Check API response parsing.
- **Verified:** 

**Phase 7: Acceptance**
- **Goal** - Final verification of all requirements.
- **Build** - Run through all checkboxes in REQUIREMENTS-mcp.md.
- **Security check** - verify all validation rules are strictly enforced.
- **RUN TEST** - Perform a full CRUD cycle: Add -> List -> Get -> Update -> Delete.
- **Expected result** - All operations succeed as expected and invalid inputs are blocked.
- **If it fails** - Re-verify the specific phase where the failure occurred.
- **Verified:** 

| Number | Phase | What I asked | What the AI got wrong | My fix |
|--------|-------|--------------|-----------------------|---------|
|        |       |              |                       |         |

**Reusable prompt templates saved from this project**
- (To be filled after build)
