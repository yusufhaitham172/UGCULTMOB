# UGCULT Mobile — Agent Guidelines & Repository Rules

## 1. Supabase MCP & Database Migrations (STRICT POLICY)

### Mandatory Rule
**ALL database migrations, DDL statements, table schemas, triggers, ENUMs, and Row-Level Security (RLS) policies for UGCULT must ALWAYS be applied and verified using the Supabase MCP.**

- **Target Supabase Project:** `yobkcmhedovixvbqokza`
- **Dashboard URL:** [https://supabase.com/dashboard/project/yobkcmhedovixvbqokza](https://supabase.com/dashboard/project/yobkcmhedovixvbqokza)
- **Supabase Host:** `https://yobkcmhedovixvbqokza.supabase.co`
- **MCP Server Config:** Scoped to `project_ref=yobkcmhedovixvbqokza`

### MCP Execution Protocol
1. **Migrations:** Always use `apply_migration` (or `execute_sql` where appropriate) via the Supabase MCP server.
2. **Schema Verification:** Call `list_tables` or `execute_sql` via Supabase MCP to inspect table schemas, relationships, constraints, and verify RLS enforcement.
3. **Never Manual / Out-of-band:** Do NOT ask the user to manually copy and paste SQL into the Supabase web dashboard SQL Editor. The agent must apply migrations programmatically through the Supabase MCP.
4. **Sequential Execution:** Follow the strict sequential order established in [DB-DESIGN.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/DB-DESIGN.md):
   - `001_create_enums.sql`
   - `002_create_tables.sql`
   - `003_create_triggers.sql`
   - `004_create_rls_policies.sql`
   - `005_create_indexes.sql`

---

## 2. Environment & Tooling Guidelines

- **Primary Development Host:** Windows 10/11 (PowerShell)
- **Primary Mobile Target:** iOS (Cupertino styling, smooth physics, haptics) + Android cross-platform
- **Framework:** Flutter 3.x / Dart 3.x
- **State Management:** Riverpod 2.x with code generation (`riverpod_generator`)
- **Navigation:** `go_router`
- **Cloud CI/CD:** GitHub Actions with `macos-14` Apple Silicon runners for iOS `.ipa` compilation
