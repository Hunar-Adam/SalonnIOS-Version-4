#!/bin/bash

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Check if the GoogleService-Info.plist exists
if [ ! -f "GoogleService-Info.plist" ]; then
  echo "❌ Error: GoogleService-Info.plist not found in current directory"
  exit 1
fi

# Make sure it's also in the main app directory
cp -f GoogleService-Info.plist SalonnIOS/GoogleService-Info.plist

echo "✅ GoogleService-Info.plist copied to app directory"
echo "⚠️ Important: You must manually add GoogleService-Info.plist to your Xcode project by:"
echo "1. Open Xcode project"
echo "2. Right-click on SalonnIOS group in the Project Navigator"
echo "3. Select 'Add Files to SalonnIOS...'"
echo "4. Navigate to and select GoogleService-Info.plist"
echo "5. In the dialog that appears, make sure 'Copy items if needed' is checked"
echo "6. Make sure 'SalonnIOS' target is selected in the 'Add to targets' section"
echo "7. Click 'Add'"
echo ""
echo "Then clean and rebuild your project (Cmd+Shift+K followed by Cmd+B)" 