EXPORT_NAME=coffintime

rm -rf build/

# export for windows
mkdir -v -p build/windows
godot --headless --verbose --export-release "Windows Desktop" "build/windows/$EXPORT_NAME.exe"

# export for linux
mkdir -v -p build/linux
godot --headless --verbose --export-release "Linux/X11" "build/linux/$EXPORT_NAME.x86_64"

# export for web
mkdir -v -p build/web
godot --headless --verbose --export-release "Web" "build/web/index.html"

# export for mac
mkdir -v -p build/mac
godot --headless --verbose --export-release "macOS" "build/mac/$EXPORT_NAME.dmg"
