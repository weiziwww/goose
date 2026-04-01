"""MCP server that distills business context from messy ticket discussions."""

import os
from pathlib import Path

from dotenv import load_dotenv
from google import genai
from mcp.server.fastmcp import FastMCP

from mock_data import MOCK_TICKET_DATA

load_dotenv(dotenv_path=Path(__file__).with_name(".env"))

mcp = FastMCP("Context Distiller")


@mcp.tool()
def get_distilled_context(ticket_id: str) -> str:
    """Return concise business intent + strict constraints for a ticket."""
    messy_context = MOCK_TICKET_DATA.get(ticket_id)
    if not messy_context:
        available = ", ".join(sorted(MOCK_TICKET_DATA.keys()))
        return (
            f"- Ticket `{ticket_id}` not found.\n"
            f"- Available mock ticket IDs: {available}\n"
            "- Verify the ticket ID and retry."
        )

    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        return (
            "- Missing `GEMINI_API_KEY`.\n"
            "- Add it to your environment or a `.env` file next to `server.py`.\n"
            "- Then retry `get_distilled_context`."
        )

    client = genai.Client(api_key=api_key)
    prompt = f"""
You are a context distiller for engineering merge-conflict recovery.

Given the messy ticket notes below, output ONLY a concise bulleted list.
The list must include:
- Core business intent (what outcome the team needs)
- Strict constraints (security/compliance/behavior/performance boundaries)

Rules:
- No introduction or conclusion text
- No markdown headings
- Max 8 bullets
- Keep each bullet short and concrete

Ticket: {ticket_id}
Messy notes:
{messy_context}
"""
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
    )
    distilled = (response.text or "").strip()
    if not distilled:
        return "- No distilled context returned by model. Retry the request."
    return distilled


if __name__ == "__main__":
    mcp.run(transport="stdio")
