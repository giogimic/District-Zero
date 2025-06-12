# District Zero

A dynamic mission and district control system for FiveM, built on QBX Core.

## Features

- Dynamic mission system with difficulty levels and rewards
- District control system with influence tracking
- Faction-based gameplay with ranks and salaries
- Modern UI using DaisyUI and TailwindCSS
- Full QBX Core integration
- Database-driven with migrations
- Type-safe with shared type definitions

## Project Structure

```
district-zero/
├── client/             # Client-side scripts
├── config/            # Configuration files
├── docs/              # Documentation and references
├── server/            # Server-side scripts
│   ├── database/      # Database initialization and migrations
│   └── main/          # Main server logic
├── shared/            # Shared code and types
├── ui/                # UI files (DaisyUI + TailwindCSS)
└── fxmanifest.lua     # Resource manifest
```

## Installation

1. Ensure you have QBX Core installed and configured
2. Clone this repository into your resources folder
3. Import the SQL files from `server/database/migrations`
4. Add `ensure district-zero` to your server.cfg
5. Restart your server

## Configuration

All configuration is done through `config/config.lua`:

- Districts: Define control zones and influence areas
- Missions: Configure available missions and rewards
- Factions: Set up faction ranks and salaries
- UI: Customize UI appearance and keybinds

## Usage

- Press F5 to open the mission menu
- Accept missions from the available list
- Complete objectives to earn rewards
- Gain influence in districts for your faction
- Progress through faction ranks

## Development

### Prerequisites

- FiveM Server
- QBX Core
- MySQL/MariaDB

### Building

No build step required - the UI uses CDN-hosted DaisyUI and TailwindCSS.

### Testing

1. Start your FiveM server
2. Join the server
3. Use the mission menu (F5)
4. Test mission acceptance and completion
5. Verify district influence changes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- QBX Core team for the framework
- DaisyUI for the UI components
- TailwindCSS for the styling
