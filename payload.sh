#!/bin/bash
# Title: Wigle Upload
# Author: Big Birb
# Description: Uploads CSVs to Wigle.net & archives them
# Version: 1.0

# --- CONFIGURATION ---
# Enter your Wigle API Name and Token below
# Do NOT use the "Encoded for use" string; use the separate Name and Token.
API_NAME="YOUR_API_NAME_HERE"
API_TOKEN="YOUR_API_TOKEN_HERE"

# Directories
LOOT_DIR="/mmc/root/loot/wigle"
ARCHIVE_DIR="$LOOT_DIR/uploaded"

# --- FUNCTIONS ---

install_curl() {
    if ! command -v curl >/dev/null 2>&1; then
        LOG "Installing curl..."
        opkg update && opkg install curl
        if [ $? -ne 0 ]; then
            LOG "FAIL: Could not install curl"
            exit 1
        fi
    fi
}

check_internet() {
    LOG "Checking Network..."
    # Ping Google DNS to verify upstream connection
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        LOG "FAIL: No Internet"
        LOG "Check Gateway/WiFi"
        exit 1
    fi
}

# --- MAIN EXECUTION ---

# 1. Setup Environment
mkdir -p "$ARCHIVE_DIR"
install_curl
check_internet

# 2. Check if there are CSV files
count=$(ls -1 "$LOOT_DIR"/*.csv 2>/dev/null | wc -l)

if [ "$count" -eq 0 ]; then
    LOG "No CSVs found."
    sleep 2
    exit 0
fi

LOG "Found $count files."
sleep 1

# 3. Loop through files and upload
for file in "$LOOT_DIR"/*.csv; do
    # Verify file exists (handles edge cases in loops)
    [ -e "$file" ] || continue

    filename=$(basename "$file")
    LOG "Up: $filename"

    # Upload to Wigle V2 API
    # -u handles Basic Auth
    # -F "file=@..." handles the multipart file upload
    # -F "donate=on" makes the data public (remove or set off if you want to keep it private)
    response=$(curl -s -u "$API_NAME:$API_TOKEN" \
        -F "file=@$file" \
        -F "donate=on" \
        "https://api.wigle.net/api/v2/file/upload")

    # 4. Process Response
    # We grep the JSON response for success:true
    if echo "$response" | grep -q '"success":true'; then
        LOG "Success! Moving..."
        mv "$file" "$ARCHIVE_DIR/"
    elif echo "$response" | grep -q '"success":false'; then
        # Check for "already uploaded" error, which allows us to archive it anyway
        if echo "$response" | grep -q 'already uploaded'; then
            LOG "Dup detected. Moving."
            mv "$file" "$ARCHIVE_DIR/"
        else
            LOG "Error uploading."
            # We assume we should keep the file to try again later
        fi
    else
        LOG "Unknown API Error"
    fi
    
    # Small pause to let the screen update and not spam the API too fast
    sleep 1
done

LOG "Batch Complete."
