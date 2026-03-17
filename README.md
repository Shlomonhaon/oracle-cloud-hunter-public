# Oracle Cloud ARM Instance Hunter

> **Keywords:** oracle cloud free tier | oracle arm instance | VM.Standard.A1.Flex | oracle always free | oci arm hunter | oracle cloud capacity | out of host capacity fix | oracle free vps | oracle cloud bot | terraform oci | oracle instance claimer | oracle arm repeater | oracle cloud automation | free arm server | oci free tier script

---

An automated tool to claim a free **VM.Standard.A1.Flex** instance (4 OCPU / 24GB RAM) on Oracle Cloud Free Tier.

Oracle limits the availability of free ARM instances — this tool retries every 60 seconds until it succeeds, then sends a Telegram notification when the instance is up.

---

## עברית | Hebrew

כלי אוטומטי לתפיסת Instance חינמי מסוג **VM.Standard.A1.Flex** (4 OCPU / 24GB RAM) ב-Oracle Cloud Free Tier.

Oracle מגבילה את הזמינות של Instances חינמיים — הכלי מנסה ליצור Instance כל 60 שניות עד שמצליח, ושולח התראה ב-Telegram כשה-Instance קם.

### שיטות הרצה

| | Docker (מקומי) | GitHub Actions (ענן) |
|---|---|---|
| דורש מחשב דלוק | ✅ כן | ❌ לא |
| ניסיון כל | 60 שניות | 60 שניות |
| התראת Telegram | ✅ | ✅ |

### דרישות מוקדמות

1. **חשבון Oracle Cloud** עם Free Tier
2. **OCI API Key** — ניתן ליצור ב: `Oracle Console → Identity → API Keys`
3. **בוט Telegram** — ניתן ליצור דרך `@BotFather`
4. הגדרות מתוך Oracle Console:
   - `Tenancy OCID`
   - `User OCID`
   - `API Key Fingerprint`
   - `Subnet OCID` (Public Subnet בתוך ה-VCN שלך)
   - `Region`

### הגדרת Telegram Bot

1. פתח `@BotFather` ב-Telegram ושלח `/newbot`
2. קבל Token
3. שלח הודעה לבוט ואז פתח:
   ```
   https://api.telegram.org/bot<TOKEN>/getUpdates
   ```
4. העתק את `"id"` מתוך `"chat"` — זה ה-Chat ID שלך

### שיטה א' — Docker (מקומי)

```bash
# 1. בנה את ה-Image
git clone https://github.com/sam-bee/oracle-cloud-repeater.git
cd oracle-cloud-repeater
docker build -t oracle-cloud-repeater .

# 2. צור תיקיית config
mkdir ~/oracle_hunter

# 3. העתק והגדר main.tf ו-run.sh מהפרויקט הזה
# 4. הרץ
docker run -d \
  --name oracle-cloud-repeater \
  --restart unless-stopped \
  -v "$HOME/oracle_hunter:/app/config" \
  oracle-cloud-repeater \
  /bin/bash /app/config/run.sh

# 5. עקוב אחרי הלוגים
docker logs -f oracle-cloud-repeater
```

### שיטה ב' — GitHub Actions (ענן, ללא מחשב)

1. לחץ **Fork** על הפרויקט
2. הגדר Secrets תחת `Settings → Secrets and variables → Actions`:
   - `OCI_API_KEY` — תוכן קובץ ה-`.pem`
   - `TELEGRAM_TOKEN` — הטוקן מ-BotFather
   - `TELEGRAM_CHAT_ID` — ה-Chat ID שלך
   - `PAT_TOKEN` — GitHub Personal Access Token עם הרשאת `workflow`
3. ערוך `github-actions/main.tf` עם הפרטים שלך
4. עבור ל: `Actions → Oracle Cloud Hunter → Run workflow`

מרגע ההפעלה — הכלי רץ לבד ומפעיל את עצמו מחדש אוטומטית.

### הודעות Telegram

| הודעה | משמעות |
|---|---|
| 🚀 התחיל לרוץ | הסקריפט עלה |
| ⏳ עדיין מחפש | עדכון כל 5 דקות |
| ✅ הוקם בהצלחה | Instance מוכן + IP |
| ❌ נכשל | שגיאה שאינה capacity |

---

## Methods

| | Docker (Local) | GitHub Actions (Cloud) |
|---|---|---|
| Requires PC to be on | ✅ Yes | ❌ No |
| Retry interval | Every 60 seconds | Every 60 seconds |
| Telegram notification | ✅ | ✅ |

---

## Prerequisites

1. **Oracle Cloud account** with Free Tier
2. **OCI API Key** — create at: `Oracle Console → Identity → API Keys`
3. **Telegram Bot** — create via `@BotFather`
4. The following from Oracle Console:
   - `Tenancy OCID`
   - `User OCID`
   - `API Key Fingerprint`
   - `Subnet OCID` (Public Subnet inside your VCN)
   - `Region` (e.g. `il-jerusalem-1`, `eu-frankfurt-1`)

---

## Telegram Bot Setup

1. Open `@BotFather` on Telegram
2. Send `/newbot` and get your Token
3. Send any message to your bot, then open:
   ```
   https://api.telegram.org/bot<TOKEN>/getUpdates
   ```
4. Copy the `"id"` value inside `"chat"` — this is your Chat ID

---

## Method A — Docker (Local Machine)

### 1. Build the Image

```bash
git clone https://github.com/sam-bee/oracle-cloud-repeater.git
cd oracle-cloud-repeater
docker build -t oracle-cloud-repeater .
```

### 2. Create the config directory

```bash
mkdir ~/oracle_hunter
```

### 3. Create the private key file

```bash
# Paste the content of the Private Key you created in Oracle Console
nano ~/oracle_hunter/oci_api_key.pem
chmod 600 ~/oracle_hunter/oci_api_key.pem
```

### 4. Create the OCI config file

Create `~/oracle_hunter/config`:
```ini
[DEFAULT]
user=YOUR_USER_OCID
fingerprint=YOUR_FINGERPRINT
tenancy=YOUR_TENANCY_OCID
region=YOUR_REGION
key_file=/app/config/oci_api_key.pem
```

### 5. Set up main.tf

Copy `docker/main.tf` from this repo and fill in your details.

### 6. Set up run.sh

Copy `docker/run.sh` from this repo and fill in your Telegram Token and Chat ID.

### 7. Run

```bash
docker run -d \
  --name oracle-cloud-repeater \
  --restart unless-stopped \
  -v "$HOME/oracle_hunter:/app/config" \
  oracle-cloud-repeater \
  /bin/bash /app/config/run.sh
```

### Follow logs

```bash
docker logs -f oracle-cloud-repeater
```

### Stop

```bash
docker rm -f oracle-cloud-repeater
```

---

## Method B — GitHub Actions (Cloud, no PC needed)

### 1. Fork this repository

Click **Fork** in the top right corner.

### 2. Configure Secrets

Go to: `Settings → Secrets and variables → Actions → New repository secret`

| Secret | Value |
|---|---|
| `OCI_API_KEY` | Full content of your `.pem` file (including `-----BEGIN PRIVATE KEY-----`) |
| `TELEGRAM_TOKEN` | Token from BotFather |
| `TELEGRAM_CHAT_ID` | Your Chat ID |
| `PAT_TOKEN` | GitHub Personal Access Token with `workflow` scope — create at [github.com/settings/tokens](https://github.com/settings/tokens/new) |

### 3. Update main.tf

Edit `github-actions/main.tf` with your Tenancy OCID, User OCID, Fingerprint, Subnet OCID, and Region.

### 4. Trigger the first run

Go to: `Actions → Oracle Cloud Hunter → Run workflow`

From that point on, the workflow triggers itself automatically after every run — no manual intervention needed.

---

## How it works

```
Run starts
  └── terraform apply
       ├── Success → Telegram ✅ + exit
       ├── Out of host capacity → wait 60s → retry
       └── Other error → Telegram ❌ + exit

Every 5 minutes → Telegram status update ⏳
When run ends → triggers next run automatically 🔄
```

---

## Project Structure

```
oracle-cloud-hunter/
├── README.md
├── docker/
│   ├── main.tf          # Terraform instance definition
│   └── run.sh           # Hunt loop with Telegram notifications
└── github-actions/
    ├── main.tf          # Terraform instance definition
    ├── hunt.sh          # Hunt loop with Telegram notifications
    ├── .gitignore
    └── .github/
        └── workflows/
            └── hunt.yml # GitHub Actions workflow definition
```

---

## Telegram Notifications

| Message | Meaning |
|---|---|
| 🚀 Started | Script is running |
| ⏳ Still searching | Status update every 5 minutes |
| ✅ Instance created | Success + public IP |
| ❌ Failed | Non-capacity error occurred |

---

## Notes

- The tool targets `VM.Standard.A1.Flex` with **4 OCPU and 24GB RAM** — Oracle's maximum free allocation
- Oracle availability varies by region — it may take hours or days
- The script stops automatically once the instance is successfully created
- All sensitive data (API keys, tokens, OCIDs) must be kept private — never commit them to a public repo

---

## Credits

Built on top of [sam-bee/oracle-cloud-repeater](https://github.com/sam-bee/oracle-cloud-repeater) using Terraform and GitHub Actions.
