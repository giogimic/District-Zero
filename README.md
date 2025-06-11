# District Zero

A dynamic territory control system for FiveM servers using Qbox framework.

## Features

- Dynamic district control system
- Faction management
- Mission system
- Event system
- Territory control mechanics
- Modern UI framework
- Database integration

## Dependencies

- [qbx_core](https://github.com/qbox-project/qbx_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation

1. Ensure you have all dependencies installed
2. Place the `dz` folder in your server's resources directory
3. Add `ensure dz` to your server.cfg
4. Import the SQL file from the `sql` directory
5. Configure the resource in `shared/config.lua`

## Configuration

All configuration options are available in `shared/config.lua`:

- District settings
- Faction settings
- Mission settings
- Event settings
- UI settings
- Debug settings

## Usage

### Commands

- `/dz:event:start [districtId] [eventType]` - Start a district event (Admin)
- `/dz:event:end [districtId] [success]` - End a district event (Admin)
- `/dz:district:info` - View district information
- `/dz:faction:info` - View faction information

### Events

All events are namespaced with `dz:` prefix:

- `dz:district:event:start`
- `dz:district:event:end`
- `dz:district:event:progress`
- `dz:district:event:update`

## Development

### Project Structure

```
dz/
├── client/
│   └── main/
├── server/
│   └── main/
├── shared/
│   ├── config.lua
│   └── utils.lua
├── ui/
│   └── src/
├── locales/
├── sql/
├── fxmanifest.lua
├── README.md
├── CHANGELOG.md
└── LICENSE
```

### Building

1. Install dependencies:

   ```bash
   cd ui
   npm install
   ```

2. Build UI:
   ```bash
   npm run build
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

For support, please open an issue in the GitHub repository.
