@echo off
REM District Zero UI Deployment Script (Windows)
REM This script ensures the UI is properly built for server deployment

echo 🚀 Starting District Zero UI deployment...

REM Check if we're in the correct directory
if not exist "package.json" (
    echo ❌ Error: package.json not found. Please run this script from the ui/ directory.
    pause
    exit /b 1
)

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    npm install
)

REM Clean previous build
echo 🧹 Cleaning previous build...
if exist "dist" rmdir /s /q dist

REM Build the UI
echo 🔨 Building UI...
npm run build

REM Check if build was successful
if %errorlevel% equ 0 (
    echo ✅ Build successful!
    echo 📊 Build output created in ui/dist/
    echo 🔗 FiveM manifest points to: ui/dist/index.html
    echo.
    echo 🎯 UI is ready for server deployment!
) else (
    echo ❌ Build failed!
    pause
    exit /b 1
)

pause 