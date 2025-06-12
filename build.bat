@echo off
echo Building District Zero UI...

cd ui
call npm install
call npm run build
cd ..

echo Build complete! 