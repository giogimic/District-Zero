#!/bin/bash

# District Zero UI Deployment Script
# This script ensures the UI is properly built for server deployment

echo "🚀 Starting District Zero UI deployment..."

# Check if we're in the correct directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the ui/ directory."
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf dist

# Build the UI
echo "🔨 Building UI..."
npm run build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📊 Build statistics:"
    echo "   - HTML: $(ls -lh dist/index.html | awk '{print $5}')"
    echo "   - CSS: $(ls -lh dist/assets/*.css | awk '{print $5}')"
    echo "   - JS: $(ls -lh dist/assets/*.js | awk '{print $5}' | tr '\n' ' ')"
    echo ""
    echo "🎯 UI is ready for server deployment!"
    echo "📁 Build output: ui/dist/"
    echo "🔗 FiveM manifest points to: ui/dist/index.html"
else
    echo "❌ Build failed!"
    exit 1
fi 