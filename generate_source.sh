#!/bin/bash

if ! command -v jq &> /dev/null; then
    echo "jq is not установлен. Установите jq для запуска скрипта."
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) не установлен. Установите gh для запуска скрипта."
    exit 1
fi


IPA_DIR="./ipa"
SOURCE_DIR="./source"
CONFIG_FILE="$SOURCE_DIR/Config.json"
SOURCE_FILE="$SOURCE_DIR/Source.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config.json не найден в $SOURCE_DIR"
    exit 1
fi
    # "name": "Defa1lt's Source",
    # "subtitle": "",
    # "description": ""

USERNAME=$(jq -r '.username' "$CONFIG_FILE")
REPONAME=$(jq -r '.reponame' "$CONFIG_FILE")
SOURCE_NAME=$(jq -r '.name' "$CONFIG_FILE")
SOURCE_SUBTITLE=$(jq -r '.subtitle' "$CONFIG_FILE")
SOURCE_DESCRIPTION=$(jq -r '.description' "$CONFIG_FILE")
SOURCE_JSON=$(cat <<EOF
{
    
    "name": "$SOURCE_NAME",
    "subtitle": "$SOURCE_SUBTITLE",
    "description": "$SOURCE_DESCRIPTION", 
    "iconURL": "https://raw.githubusercontent.com/$USERNAME/$REPONAME/main/source/SourceIcon.jpeg",
    "apps": [
EOF
)

APP_COUNT=0


for APP_DIR in "$IPA_DIR"/*/; do
    APP_DETAILS_FILE="${APP_DIR}AppDetails.json"
    if [ ! -f "$APP_DETAILS_FILE" ]; then
        echo "AppDetails.json не найден в $APP_DIR"
        continue
    fi

    APP_ID=$(jq -r '.bundleIdentifier' "$APP_DETAILS_FILE")
    DEVELOPER_NAME=$(jq -r '.developerName' "$APP_DETAILS_FILE")
    APP_NAME=$(jq -r '.name' "$APP_DETAILS_FILE")
    APP_LOCALIZED_DESCRIPTION=$(jq -r '.localizedDescription' "$APP_DETAILS_FILE")

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

    VERSIONS_JSON=""
    for VERSION_DIR in "$APP_DIR"*/; do
        VERSION_DETAILS_FILE="${VERSION_DIR}VersionDetails.json"
        IPA_FILE=$(find "$VERSION_DIR" -name "*.ipa" | head -n 1)
        if [ ! -f "$VERSION_DETAILS_FILE" ] || [ ! -f "$IPA_FILE" ]; then
            echo "VersionDetails.json или IPA не найдены в $VERSION_DIR"
            continue
        fi

        VERSION=$(jq -r '.version' "$VERSION_DETAILS_FILE")
        MIN_OS_VERSION=$(jq -r '.minOSVersion' "$VERSION_DETAILS_FILE")
        VERSION_LOCALIZED_DESCRIPTION=$(jq -r '.localizedDescription' "$VERSION_DETAILS_FILE")
        IPA_SIZE=$(jq -r '.size' "$VERSION_DETAILS_FILE")

        IPA_FILENAME=$(basename "$IPA_FILE")
        IPA_FILENAME_ENCODED=$(echo "$IPA_FILENAME" | sed 's/ /%20/g')
        APP_ID_ENCODED=$(echo "$APP_ID" | sed 's/ /%20/g')
        VERSION_ENCODED=$(echo "$VERSION" | sed 's/ /%20/g')
        DOWNLOAD_URL="https://github.com/$USERNAME/$REPONAME/releases/download/$APP_ID_ENCODED-$VERSION_ENCODED/$IPA_FILENAME_ENCODED"
        CURRENT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        VERSION_JSON=$(cat <<EOF
            {
                "version": "$VERSION",
                "localizedDescription":"$VERSION_LOCALIZED_DESCRIPTION",
                "minOSVersion": "$MIN_OS_VERSION",
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

        if gh release view "$TAG_NAME" &> /dev/null; then
            echo "Релиз $TAG_NAME уже существует. Пропускаем."
        else
            gh release create "$TAG_NAME" "$IPA_FILE" \
                --title "Release $VERSION" \
                --notes "$RELEASE_NOTES" \
                --target main
            echo "Релиз $TAG_NAME создан и $IPA_FILENAME загружен."
        fi
    done

    APP_ICON_URL="https://raw.githubusercontent.com/$USERNAME/$REPONAME/main/ipa/$APP_DIR_NAME_ENCODED/AppIcon.png"

    APP_JSON=$(cat <<EOF
        {
            "name": "$APP_NAME",
            "localizedDescription": "$APP_LOCALIZED_DESCRIPTION",
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
