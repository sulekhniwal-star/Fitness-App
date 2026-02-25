# Fast Track PocketBase Setup

1. Download PocketBase from [pocketbase.io](https://pocketbase.io/docs/)
2. Unzip and place the executable as `backend/pocketbase.exe` (Windows) or `backend/pocketbase` (macOS/Linux).
3. Start the backend: `./pocketbase serve`
4. Visit `http://127.0.0.1:8090/_/` and create an admin account.
5. In the PocketBase admin UI, go to `Settings > Sync > Import collections`.
6. Paste the contents of `pb_schema.json` (to be generated) or just run the JS migrations in `pb_migrations` (PocketBase auto-runs them on `serve`).

## Collections Schema Strategy
We rely on JS migrations placed in `pb_migrations/` which are executed automatically by PocketBase on startup.
