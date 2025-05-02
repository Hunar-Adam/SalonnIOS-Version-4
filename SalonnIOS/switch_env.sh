#!/bin/bash

# This script copies the correct GoogleService-Info plist file based on the current build configuration

if [ "$CONFIGURATION" == "Dev" ]; then
    echo "Switching to Dev environment"
    cp "$SRCROOT/Firebase/GoogleService-Info-Dev.plist" "$SRCROOT/GoogleService-Info.plist"
elif [ "$CONFIGURATION" == "Staging" ]; then
    echo "Switching to Staging environment"
    cp "$SRCROOT/Firebase/GoogleService-Info-Staging.plist" "$SRCROOT/GoogleService-Info.plist"
else
    echo "Switching to Production environment"
    cp "$SRCROOT/Firebase/GoogleService-Info-Prod.plist" "$SRCROOT/GoogleService-Info.plist"
fi

# Make sure the file exists now
if [ -f "$SRCROOT/GoogleService-Info.plist" ]; then
    echo "Successfully prepared GoogleService-Info.plist for $CONFIGURATION"
else
    echo "Error: Failed to create GoogleService-Info.plist"
    exit 1
fi 