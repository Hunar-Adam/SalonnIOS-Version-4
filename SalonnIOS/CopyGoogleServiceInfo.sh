#!/bin/bash

# This script copies GoogleService-Info.plist from project root to app bundle
# This is the script you should add to your Run Script Phase in Xcode

echo "Copying GoogleService-Info.plist to app bundle"
cp "${SRCROOT}/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [ $? -eq 0 ]; then
    echo "Successfully copied GoogleService-Info.plist to app bundle"
else
    echo "Error: Failed to copy GoogleService-Info.plist to app bundle"
    exit 1
fi 