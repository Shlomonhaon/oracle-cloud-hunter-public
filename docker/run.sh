#!/bin/bash

TELEGRAM_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="YOUR_TELEGRAM_CHAT_ID"
ATTEMPT=0
START_TIME=$(date +%s)
LAST_UPDATE_TIME=$(date +%s)
UPDATE_INTERVAL=300  # Send Telegram update every 5 minutes

send_telegram() {
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="$1" > /dev/null
}

cd /app/config
terraform init

send_telegram "🚀 Oracle Cloud Hunter started. Trying to create VM.Standard.A1.Flex..."

while true; do
  ATTEMPT=$((ATTEMPT + 1))
  NOW=$(date +%s)
  ELAPSED=$(( NOW - START_TIME ))

  echo "[$(date '+%T')] Attempt #$ATTEMPT..."

  terraform apply -auto-approve 2>&1 | tee /tmp/tf_output.txt
  EXIT_CODE=${PIPESTATUS[0]}

  if [ $EXIT_CODE -eq 0 ]; then
    IP=$(terraform output -raw instance_public_ip 2>/dev/null || echo "unknown")
    MSG="✅ Oracle Instance created successfully!
🖥️ VM.Standard.A1.Flex — 4 OCPU / 24GB RAM
🌐 IP: ${IP}
⏱️ Attempt: ${ATTEMPT} | Time elapsed: $(( ELAPSED / 60 )) minutes"
    echo "$MSG"
    send_telegram "$MSG"
    exit 0
  fi

  if ! grep -q "Out of host capacity\|The operation was canceled" /tmp/tf_output.txt; then
    ERROR=$(tail -5 /tmp/tf_output.txt)
    send_telegram "❌ Failed due to unexpected error:
${ERROR}"
    exit 1
  fi

  NOW=$(date +%s)
  if [ $(( NOW - LAST_UPDATE_TIME )) -ge $UPDATE_INTERVAL ]; then
    ELAPSED_MIN=$(( (NOW - START_TIME) / 60 ))
    send_telegram "⏳ Still searching for capacity...
🔁 Attempts: ${ATTEMPT}
⏱️ Time elapsed: ${ELAPSED_MIN} minutes"
    LAST_UPDATE_TIME=$NOW
  fi

  echo "[$(date '+%T')] Out of host capacity. Waiting 60 seconds..."
  sleep 60
done
