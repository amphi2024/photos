echo "Creating dmg..."

cd ..
create-dmg \
  --volname "Photos" \
  --window-size 500 300 \
  --icon Photos.app 130 110 \
  --app-drop-link 360 110 \
  Photos.dmg \
  build/macos/Build/Products/Release/Photos.app
echo "Let's go!!!!!!"