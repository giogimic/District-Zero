@echo off
echo Building District Zero UI...

cd ui
if not exist node_modules (
    echo Installing dependencies...
    call npm install --no-package-lock
)
call npm run build
cd ..

echo Build complete! 