---
description: Mandatory rule to always use Supabase MCP for all database migrations and schema changes on project yobkcmhedovixvbqokza
always_on: true
---

# Supabase MCP Migration Rule

1. **Target Project:** `yobkcmhedovixvbqokza` (`https://yobkcmhedovixvbqokza.supabase.co`).
2. **Exclusive Tooling:** Always use the **Supabase MCP** (`apply_migration`, `execute_sql`, `list_tables`, `get_advisors`) for all database operations, migrations, DDL statements, and RLS policy configurations.
3. **No Dashboard Pasting:** Never request or require manual SQL pasting in the Supabase web dashboard. Apply migrations programmatically through the MCP tools.
4. **Verification:** Always verify database structure, constraints, and RLS policies using `list_tables` and `execute_sql` via Supabase MCP after migrations.
