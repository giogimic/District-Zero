# District Zero

A FiveM resource for managing districts, factions, and events in your server.

## Features

- **Districts**: Define and manage different areas of your map
- **Factions**: Create and manage player factions with roles and permissions
- **Events**: Schedule and run district events with rewards
- **Modern UI**: Built with Vue.js and Vite for a smooth user experience
- **Localization**: Support for multiple languages
- **Database Migrations**: Automatic database schema updates

## Requirements

- FiveM Server
- QBCore Framework
- MySQL Database
- Node.js 18+ (for development)

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/district-zero.git
   cd district-zero
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Build the UI:

   ```bash
   npm run build
   ```

4. Copy the resource to your FiveM server's resources directory.

5. Add the following to your server.cfg:

   ```cfg
   ensure district-zero
   ```

6. Configure the database connection in `config/database.lua`.

## Development

1. Start the development server:

   ```bash
   npm run dev
   ```

2. The UI will be available at `http://localhost:3000`.

3. Make changes to the Vue components in `ui/src/`.

4. Build for production:
   ```bash
   npm run build
   ```

## Database

The resource uses MySQL for data storage. The database schema is managed through migrations in `server/database/migrations/`.

To initialize the database:

1. Create a new database named `district_zero`.
2. The resource will automatically run migrations on startup.

## Commands

- `/dz` - Open the District Zero UI (default keybind: F6)

## API

### Server Exports

```lua
-- Get faction information
exports['district-zero']:GetFaction(factionId)

-- Get district information
exports['district-zero']:GetDistrict(districtId)

-- Get event information
exports['district-zero']:GetEvent(eventId)

-- Get district control information
exports['district-zero']:GetDistrictControl(districtId)
```

### Events

#### Client Events

```lua
-- Open UI
TriggerEvent('district-zero:client:openUI')

-- Close UI
TriggerEvent('district-zero:client:closeUI')
```

#### Server Events

```lua
-- Create faction
TriggerServerEvent('district-zero:server:createFaction', data)

-- Update faction
TriggerServerEvent('district-zero:server:updateFaction', data)

-- Delete faction
TriggerServerEvent('district-zero:server:deleteFaction', factionId)

-- Create event
TriggerServerEvent('district-zero:server:createEvent', data)

-- Update event
TriggerServerEvent('district-zero:server:updateEvent', data)

-- Delete event
TriggerServerEvent('district-zero:server:deleteEvent', eventId)

-- Start event
TriggerServerEvent('district-zero:server:startEvent', eventId)
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [QBCore Framework](https://github.com/qbcore-framework)
- [Vue.js](https://vuejs.org/)
- [Vite](https://vitejs.dev/)
