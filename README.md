# Hak5 Pineapple Pager - Wigle Uploader

This payload allows the **Hak5 WiFi Pineapple Pager** to upload collected wardriving loot (CSV files) directly to [Wigle.net](https://wigle.net) using an active internet connection.

It automatically handles the upload process and archives successfully uploaded files to prevent duplicates.

## Features
- **Smart Connectivity:** Checks for an active internet connection (ping) before running.
- **Auto Retry:** Reconnects to Client AP and retries connectivity (10s then 20s by default).
- **Dependency Management:** Automatically installs `curl` via opkg if it is missing.
- **Batch Processing:** Iterates through the default `/mmc/root/loot/wigle/` directory.
- **Deduplication:** Moves successfully uploaded files to an `/uploaded` subdirectory.
- **Error Handling:** Skips files that Wigle reports as "already uploaded" but still archives them to clear the queue.

## Prerequisites
1. A **Hak5 WiFi Pineapple Pager**.
2. A **Wigle.net** account.
3. Your Wigle API credentials (found at [Wigle.net Account Settings](https://wigle.net/account)).

## Installation

Choose one of the methods below.

### Option 1: SCP
If you have the `payload.sh` file saved on your computer, you can push it directly to the Pager.

1. Open your terminal where the `payload.sh` file is located.
2. Run the following command (replace `172.16.52.1` with your Pager's IP if different):
   ```bash
   # Create the directory first
   ssh root@172.16.52.1 "mkdir -p /mmc/root/payloads/user/general/WigleUpload"

   # Copy the file
   scp payload.sh root@172.16.52.1:/mmc/root/payloads/user/general/WigleUpload/
### Option 2: SSH and Copy/Paste
Login to the pager and create the file there.

1. Connect your pager to your computer via USB 
2. SSH root@172.16.52.1
3. mkdir -p /mmc/root/payloads/user/general/WigleUpload
4. vi /mmc/root/payloads/user/general/WigleUpload/payload.sh
5. Paste the payload.sh contents

## Configuration

You must edit the script before use!

Open payload.sh (on your computer or on the device).

Locate the Configuration section at the top:

API_NAME="YOUR_API_NAME_HERE"

API_TOKEN="YOUR_API_TOKEN_HERE"

Replace the placeholders with your actual Encoded for use API Name and Token from Wigle.net.

Optional connectivity settings (defaults are reasonable for most setups):
- `CLIENT_RECONNECT_CMD` controls how the Pager reconnects to Client AP.
- `RETRY_LIMIT`, `RETRY_WAIT_1`, `RETRY_WAIT_2` control retry behavior.
- `PROMPT_ON_FAIL=true` enables a manual down-arrow retry prompt after auto retries.
Usage

On the Pager, navigate to Payloads -> User -> General -> WigleUpload.

Ensure you have an active internet connection (WiFi Client Mode, Ethernet, etc.).

Select and run the payload.

Watch the Pager screen for logs indicating upload progress ("Up: filename...") and success status.

Disclaimer
This script is provided as-is. I am not responsible for data loss or API bans. Please respect Wigle.net's API limits.
