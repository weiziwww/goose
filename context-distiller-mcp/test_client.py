"""Local MCP client to test the Context Distiller stdio server."""

import argparse
from pathlib import Path

import anyio
from mcp.client.session import ClientSession
from mcp.client.stdio import StdioServerParameters, stdio_client


async def run_test(ticket_id: str) -> None:
    server_path = Path(__file__).with_name("server.py")
    python_path = Path(__file__).parent / ".venv" / "bin" / "python"

    server_params = StdioServerParameters(
        command=str(python_path),
        args=[str(server_path)],
    )

    async with stdio_client(server_params) as (read_stream, write_stream):
        async with ClientSession(read_stream, write_stream) as session:
            await session.initialize()

            tools = await session.list_tools()
            tool_names = ", ".join(tool.name for tool in tools.tools)
            print(f"Discovered tools: {tool_names}")

            result = await session.call_tool(
                name="get_distilled_context",
                arguments={"ticket_id": ticket_id},
            )

            if result.isError:
                print("Tool call returned an error result.")

            text_chunks = [block.text for block in result.content if getattr(block, "type", "") == "text"]
            print("\n=== Distilled Context ===\n")
            print("\n".join(text_chunks).strip() or "(no text content)")


def main() -> None:
    parser = argparse.ArgumentParser(description="Test the Context Distiller MCP server locally.")
    parser.add_argument(
        "--ticket-id",
        default="PROJ-405",
        help="Ticket ID to distill (default: PROJ-405)",
    )
    args = parser.parse_args()
    anyio.run(run_test, args.ticket_id)


if __name__ == "__main__":
    main()
