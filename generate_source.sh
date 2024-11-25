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
    APP_ID=$(jq -r '.bundleIdentifier' "$APP_DETAILS_FILE")
    DEVELOPER_NAME=$(jq -r '.developerName' "$APP_DETAILS_FILE")

    # Process screenshots
    SCREENSHOTS=()
    for IMG in "$APP_DIR"*.png; do
        [ -e "$IMG" ] || continue
        IMG_NAME=$(basename "$IMG")
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
        RELEASE_NOTES=$(jq -r '.releaseNotes' "$VERSION_DETAILS_FILE")

        IPA_FILENAME=$(basename "$IPA_FILE")
        IPA_FILENAME_ENCODED=$(echo "$IPA_FILENAME" | sed 's/ /%20/g')
        APP_ID_ENCODED=$(echo "$APP_ID" | sed 's/ /%20/g')
        VERSION_ENCODED=$(echo "$VERSION" | sed 's/ /%20/g')
        DOWNLOAD_URL="https://github.com/$USERNAME/$REPONAME/releases/download/$APP_ID_ENCODED-$VERSION_ENCODED/$IPA_FILENAME_ENCODED"
        IPA_SIZE=$(stat -c%s "$IPA_FILE")
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

        TAG_NAME="$APP_ID-$VERSION"
        RELEASE_TITLE="$APP_NAME $VERSION"

        if gh release view "$TAG_NAME" &> /dev/null; then
            echo "Release $TAG_NAME already exists. Skipping."
        else
            gh release create "$TAG_NAME" "$IPA_FILE" \
                --title "$RELEASE_TITLE" \
                --notes "$RELEASE_NOTES" \
                --target main
            echo "Release $TAG_NAME created and $IPA_FILENAME uploaded."
        fi
    done

    APP_ICON_URL="https://raw.githubusercontent.com/$USERNAME/$REPONAME/main/ipa/$APP_DIR_NAME_ENCODED/AppIcon.png"

    APP_JSON=$(cat <<EOF
        {
            "name": "$APP_NAME",
            "bundleIdentifier": "$APP_ID",
            "developerName": "$DEVELOPER_NAME",
            "iconURL": "$APP_ICON_URL",
            "screenshotURLs": [
                $SCREENSHOTS_JSON
            ],
            "versions": [
                $VERSIONS_JSON
            ]
        }
EOF
    )
    if [ $APP_COUNT -ne 0 ]; then
        SOURCE_JSON="$SOURCE_JSON,"
    fi
    SOURCE_JSON="$SOURCE_JSON$APP_JSON"
    APP_COUNT=$((APP_COUNT + 1))
done

SOURCE_JSON="$SOURCE_JSON
    ]
}
"

echo "$SOURCE_JSON" > "$SOURCE_FILE"
git add "$SOURCE_FILE"
git commit -m "Update Source.json"
git push origin main
