# AGENT.md - District Zero Development Guide

## Build/Test Commands
- `build.bat` - Build UI (installs npm deps if needed, runs npm run build)
- `cd ui && npm run build` - Build UI only
- **Testing**: No automated tests - manual testing via FiveM server join and F5 menu
- **Lint**: ESLint configured for TypeScript/React in UI layer
- **Format**: Prettier with 2 spaces, single quotes, 100 char width

## Architecture
- **Framework**: FiveM Lua resource on QBX Core + ox_lib + oxmysql
- **Structure**: client/, server/, shared/, config/, ui/, sql/
- **Database**: MySQL with migrations in sql/migrations/
- **UI**: Vite 6.x + TailwindCSS 3.x + DaisyUI 4.x, builds to ui/dist/
- **Types**: Comprehensive @class annotations in shared/types.lua
- **Events**: Shared events system via shared/events.lua

## Code Style (2021+ Modern Standards)
- **Lua**: Use CreateThread/Wait (not Citizen.*), pcall for error handling
- **FiveM**: Modern fx_version 'cerulean', lua54 'yes', QBX patterns only
- **Database**: oxmysql with .await patterns, parameterized queries for security
- **Performance**: Avoid Wait(0) loops, use appropriate intervals (500ms+)
- **Config**: All configs in config/ folder, return statement required
- **Naming**: Snake_case for events/database, camelCase for JS, PascalCase for classes
- **Types**: Strong typing with @class annotations for all data structures  
- **Error Handling**: Use shared/error.lua utilities, validate all inputs, pcall wrapping
- **File Structure**: Modular by feature (missions/, districts/, teams/)
- **Dependencies**: ox_lib, oxmysql, qbx_core - check existing before adding new ones
- **Security**: No SQL injection (parameterized queries), input validation, no secrets in code
