## Task
Review the API endpoints that have been developed in this project and produce complete API documentation as a single JSON file.

## Purpose
This JSON will be used by another AI agent to build an MCP server that consumes this API. That agent will not have access to the source code, so the documentation must be complete, accurate, and self-explanatory on its own.

## Rules
- Document only what exists in the code. Do not invent endpoints, fields, or behaviours.
- If something is unclear or cannot be confirmed from the code, add it to a "notes" field instead of guessing.
- Use the same structure for every endpoint.
- Provide realistic example values for every request and response.
- Output valid JSON only, with no comments.

## Required content
At the top level:
- API name, version, and description
- Base URL (clearly marked as a separate field)
- Authentication method (e.g. API key, Bearer token, session) and where it is sent
- Common headers used by all endpoints
- Common error response format

For each endpoint:
- Name and short description of what it does
- HTTP method
- Path (relative to the base URL) and full URL
- Request headers
- Path parameters, query parameters, and request body — for each field include: name, data type, required/optional, allowed values or format, default value, and description
- Responses, grouped as:
  - Success
  - Failed (client-side issues such as validation errors, missing fields, not found, unauthorised)
  - Error (server-side issues such as exceptions or database errors)
- For each response: HTTP status code, description, and example response body

## Output structure
Follow this structure:

{
  "api_name": "",
  "version": "",
  "description": "",
  "base_url": "",
  "authentication": {
    "type": "",
    "location": "",
    "header_name": "",
    "description": ""
  },
  "common_headers": [
    { "name": "", "value": "", "required": true, "description": "" }
  ],
  "common_error_format": {},
  "endpoints": [
    {
      "name": "",
      "description": "",
      "method": "",
      "path": "",
      "full_url": "",
      "headers": [],
      "path_parameters": [],
      "query_parameters": [],
      "request_body": {
        "content_type": "",
        "fields": [
          {
            "name": "",
            "type": "",
            "required": true,
            "format": "",
            "default": null,
            "description": ""
          }
        ],
        "example": {}
      },
      "responses": {
        "success": [
          { "status_code": 200, "description": "", "example": {} }
        ],
        "failed": [
          { "status_code": 400, "description": "", "example": {} }
        ],
        "error": [
          { "status_code": 500, "description": "", "example": {} }
        ]
      },
      "notes": ""
    }
  ]
}

Save the output as `api-documentation.json`.
