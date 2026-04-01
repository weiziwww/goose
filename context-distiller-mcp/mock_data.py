"""Mock Jira/PR discussion data for context distillation."""

MOCK_TICKET_DATA = {
    "PROJ-405": """
    Jira thread dump + PR comments + Slack excerpts:
    - "Hotfix branch keeps failing E2E in staging because QA bot users are treated like normal cardholders."
    - "We cannot hit the real PSP for internal synthetic users anymore. Costs are exploding + triggers fraud filters."
    - "Do NOT disable payments globally. Only bypass authorization for accounts tagged qa_bot=true and env in {staging,qa}."
    - "Risk said no path to production. If this leaks to prod, we violate PCI controls and audit trail requirements."
    - "Need traceability: every bypass must emit event code PAY_BYPASS_QA with actor, ticket, timestamp."
    - "Legacy service `checkout-v2` still calls gateway directly; fork introduced `payments_proxy` but merge conflict broke flag wiring."
    - "Keep invoice generation intact even when gateway call is skipped, finance still reconciles synthetic runs weekly."
    - "Temporary policy until Q3 migration done. Keep feature flag kill-switch: payment.qa_bypass_enabled."
    - "Customer support asked that user-facing wording never mentions bypass/testing."
    - "Acceptance: QA bot checkout should return success in < 2s and never create settlement records."
    """,
    "PROJ-512": """
    Notes from migration epic:
    - "Need dual-write for entitlement records while we move from monolith DB to service DB."
    - "Strict ordering: write primary, then async mirror. No rollback coupling."
    - "Cannot change external API payloads; enterprise clients hard-parse keys."
    - "If mirror write fails, retry for 24h then alert #entitlements-oncall."
    - "Legal requires retention tags preserved exactly for all enterprise tenants."
    """,
}
