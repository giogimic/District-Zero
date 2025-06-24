# District Zero UI

Modern React-based UI for the District Zero FiveM resource.

## 🚀 Quick Start

### Development
```bash
npm install
npm run dev
```

### Production Build
```bash
npm install
npm run build
```

## 📁 Project Structure

```
ui/
├── src/
│   ├── components/          # React components
│   │   ├── tabs/           # Tab components (Dashboard, Districts, etc.)
│   │   └── ...             # Shared components
│   ├── store/              # Zustand state management
│   ├── types/              # TypeScript type definitions
│   ├── utils/              # Utility functions (NUI communication)
│   └── styles/             # Global styles
├── dist/                   # Production build output
├── package.json           # Dependencies and scripts
└── vite.config.ts         # Vite configuration
```

## 🛠️ Build Process

1. **TypeScript Compilation**: `tsc` compiles TypeScript to JavaScript
2. **Vite Build**: Bundles and optimizes for production
3. **Output**: Creates `dist/` folder with optimized assets

## 📦 Deployment

### For Server Deployment

1. **Build the UI**:
   ```bash
   cd ui
   npm install
   npm run build
   ```

2. **Verify Build Output**:
   - `dist/index.html` - Main HTML file
   - `dist/assets/` - Optimized CSS and JS files

3. **FiveM Integration**:
   - The `fxmanifest.lua` already points to `ui/dist/index.html`
   - All assets are automatically included

### Build Output

The build creates optimized files:
- **HTML**: `dist/index.html` (1KB)
- **CSS**: `dist/assets/index-*.css` (17KB)
- **JavaScript**: Multiple chunks for optimal loading
  - Main app: `dist/assets/index-*.js` (33KB)
  - Vendor libraries: `dist/assets/vendor-*.js` (140KB)
  - Animations: `dist/assets/animations-*.js` (102KB)

## 🔧 Configuration

### Environment Variables
- `VITE_APP_TITLE`: Application title
- `DEV`: Development mode flag
- `PROD`: Production mode flag

### FiveM NUI Integration
The UI communicates with FiveM through the NUI system:
- **Client → UI**: `fetch()` calls to game events
- **UI → Client**: `window.invokeNative()` for game functions
- **Development**: Mock data when not in FiveM environment

## 🎨 Styling

- **Tailwind CSS**: Utility-first CSS framework
- **DaisyUI**: Component library built on Tailwind
- **Custom Theme**: Dark cyberpunk aesthetic with neon accents
- **Responsive**: Mobile-first design approach

## 📱 Features

- **Dashboard**: Overview of districts, missions, and player stats
- **Districts**: Real-time district control and influence tracking
- **Missions**: Dynamic mission system with objectives
- **Teams**: Team selection and balance overview
- **Settings**: User preferences and configuration

## 🚨 Troubleshooting

### Build Issues
1. **TypeScript Errors**: Ensure all dependencies are installed
2. **Missing Types**: Run `npm install @types/react @types/react-dom`
3. **Terser Error**: Run `npm install --save-dev terser`

### FiveM Integration Issues
1. **NUI Not Loading**: Check `fxmanifest.lua` paths
2. **Communication Errors**: Verify event names match server/client
3. **Styling Issues**: Ensure CSS is properly loaded

## 📄 License

Part of the District Zero FiveM resource. 