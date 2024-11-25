#!/bin/bash

# Check for jq installation
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq to run this script."
    exit 1
fi

# Check for gh installation
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install gh to run this script."
    exit 1
fi

# Directories and files
IPA_DIR="./ipa"
SOURCE_DIR="./source/v1"
CONFIG_FILE="$SOURCE_DIR/Config.json"
SOURCE_FILE="$SOURCE_DIR/Source.json"

# Check for Config.json
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config.json not found in $SOURCE_DIR"
    exit 1
fi

# Read configuration
USERNAME=$(jq -r '.username' "$CONFIG_FILE")
REPONAME=$(jq -r '.reponame' "$CONFIG_FILE")
SOURCE_NAME=$(jq -r '.name' "$CONFIG_FILE")
SUBTITLE=$(jq -r '.subtitle' "$CONFIG_FILE")
DESCRIPTION=$(jq -r '.description' "$CONFIG_FILE")

# Initialize Source.json content
SOURCE_JSON=$(cat <<EOF
{
    "name": "$SOURCE_NAME",
    "subtitle": "$SUBTITLE",
    "description": "$DESCRIPTION",
    "iconURL": "https://raw.githubusercontent.com/$USERNAME/$REPONAME/main/source/v1/SourceIcon.jpeg",
    "apps": [
EOF
)

APP_COUNT=0
for APP_DIR in "$IPA_DIR"/*/; do
    APP_DETAILS_FILE="${APP_DIR}AppDetails.json"
    if [ ! -f "$APP_DETAILS_FILE" ]; then
        echo "AppDetails.json not found in $APP_DIR"
        continue
    fi

    APP_NAME=$(jq -r '.name' "$APP_DETAILS_FILE")
    BUNDLE_ID=$(jq -r '.bundleIdentifier' "$APP_DETAILS_FILE")
    DEVELOPER_NAME=$(jq -r '.developerName' "$APP_DETAILS_FILE")

    # Process screenshots
    SCREENSHOTS=()
    for IMG in "$APP_DIR"*.png; do
        [ -e "$IMG" ] || continue
        IMG_NAME=$(basename "$IMG")
        # Replace spaces with %20 for URL encoding
        IMG_NAME_ENCODED=$(echo "$IMG_NAME" | sed 's/ /%20/g')
        APP_DIR_NAME=$(basename "$APP_DIR")
        APP_DIR_NAME_ENCODED=$(echo "$APP_DIR_NAME" | sed 's/ /%20/g')
        SCREENSHOTS+=("\"https://raw.githubusercontent.com/$USERNAME/$REPONAME/main/ipa/$APP_DIR_NAME_ENCODED/$IMG_NAME_ENCODED\"")
    done
    SCREENSHOTS_JSON=$(printf ",\n                %s" "${SCREENSHOTS[@]}")
    SCREENSHOTS_JSON=${SCREENSHOTS_JSON:2}

    # Process versions
    VERSIONS_JSON=""
    for VERSION_DIR in "$APP_DIR"*/; do
        VERSION_DETAILS_FILE="${VERSION_DIR}VersionDetails.json"
        IPA_FILE=$(find "$VERSION_DIR" -name "*.ipa" | head -n 1)
        if [ ! -f "$VERSION_DETAILS_FILE" ] || [ ! -f "$IPA_FILE" ]; then
            echo "VersionDetails.json or IPA not found in $VERSION_DIR"
            continue
        fi

        VERSION=$(jq -r '.version' "$VERSION_DETAILS_FILE")
        LOCALIZED_DESCRIPTION=$(jq -r '.localizedDescription' "$VERSION_DETAILS_FILE")
        MIN_OS_VERSION=$(jq -r '.minOSVersion' "$VERSION_DETAILS_FILE")

        IPA_FILENAME=$(basename "$IPA_FILE")
        # Replace spaces with %20 for URL encoding
        IPA_FILENAME_ENCODED=$(echo "$IPA_FILENAME" | sed 's/ /%20/g')
        VERSION_DIR_NAME=$(basename "$VERSION_DIR")
        VERSION_DIR_NAME_ENCODED=$(echo "$VERSION_DIR_NAME" | sed 's/ /%20/g')
        APP_DIR_NAME=$(basename "$APP_DIR")
        APP_DIR_NAME_ENCODED=$(echo "$APP_DIR_NAME" | sed 's/ /%20/g')
        DOWNLOAD_URL="https://github.com/$USERNAME/$REPONAME/releases/download/$APP_DIR_NAME_ENCODED-$VERSION/$IPA_FILENAME_ENCODED"

        # Get the size of the IPA file in bytes
        IPA_SIZE=$(stat -c%s "$IPA_FILE")

        # Get the current date and time in ISO 8601 format
        CURRENT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        VERSION_JSON=$(cat <<EOF
            {
                "version": "$VERSION",
                "minOSVersion": "$MIN_OS_VERSION",
                "localizedDescription": "$LOCALIZED_DESCRIPTION",
                "downloadURL": "$DOWNLOAD_URL",
                "size": $IPA_SIZE,
                "date": "$CURRENT_DATE"
            }
EOF
        )
        if [ -n "$VERSIONS_JSON" ]; then
            VERSIONS_JSON="$VERSIONS_JSON,$VERSION_JSON"
        else
            VERSIONS_JSON="$VERSION_JSON"
        fi

        # Create GitHub release
        TAG_NAME="$APP_DIR_NAME-$VERSION"
        RELEASE_TITLE="$APP_NAME $VERSION"
        RELEASE_BODY="$RELEASE_NOTES"

        # Check if release already exists
        if gh release view "$TAG_NAME" &> /dev/null; then
            echo "Release $TAG_NAME already exists. Skipping."
        else
            # Create a new release
            gh release create "$TAG_NAME" "$IPA_FILE" \
                --title "$RELEASE_TITLE" \
                --notes "$RELEASE_BODY" \
                --target main
            echo "Release $TAG_NAME created and $IPA_FILENAME uploaded."
        fi
    done

    APP_ICON_URL="https://raw.githubusercontent.com/$USERNAME/$REPONAME/main/ipa/$APP_DIR_NAME_ENCODED/AppIcon.png"

    APP_JSON=$(cat <<EOF
        {
            "name": "$APP_NAME",
            "bundleIdentifier": "$BUNDLE_ID",
            "developerName": "$DEVELOPER_NAME",
            "iconURL": "$APP_ICON_URL",
            "localizedDescription": "$LOCALIZED_DESCRIPTION",
            "screenshotURLs": [
                $SCREENSH
::contentReference[oaicite:0]{index=0}
 
