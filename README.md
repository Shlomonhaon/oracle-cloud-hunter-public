# Oracle Cloud ARM Instance Hunter

כלי אוטומטי לתפיסת Instance חינמי מסוג **VM.Standard.A1.Flex** (4 OCPU / 24GB RAM) ב-Oracle Cloud Free Tier.

Oracle מגבילה את הזמינות של Instances חינמיים — הכלי מנסה ליצור Instance כל 60 שניות עד שמצליח, ושולח התראה ב-Telegram כשה-Instance קם.

---

## שיטות הרצה

| | Docker (מקומי) | GitHub Actions (ענן) |
|---|---|---|
| דורש מחשב דלוק | ✅ כן | ❌ לא |
| ניסיון כל | 60 שניות | 60 שניות |
| התראת Telegram | ✅ | ✅ |

---

## דרישות מוקדמות

1. **חשבון Oracle Cloud** עם Free Tier
2. **OCI API Key** — ניתן ליצור ב: `Oracle Console → Identity → API Keys`
3. **בוט Telegram** — ניתן ליצור דרך `@BotFather`
4. הגדרות מתוך Oracle Console:
   - `Tenancy OCID`
   - `User OCID`
   - `API Key Fingerprint`
   - `Subnet OCID` (Public Subnet בתוך ה-VCN שלך)
   - `Region` (לדוגמה: `il-jerusalem-1`)

---

## הגדרת Telegram Bot

1. פתח `@BotFather` ב-Telegram
2. שלח `/newbot` וקבל Token
3. שלח הודעה לבוט, ואז פתח:
   ```
   https://api.telegram.org/bot<TOKEN>/getUpdates
   ```
4. העתק את `"id"` מתוך `"chat"` — זה ה-Chat ID שלך

---

## שיטה א' — Docker (הרצה מקומית)

### 1. בנה את ה-Image

```bash
git clone https://github.com/sam-bee/oracle-cloud-repeater.git
cd oracle-cloud-repeater
docker build -t oracle-cloud-repeater .
```

### 2. צור את תיקיית ה-config

```bash
mkdir ~/oracle_hunter
```

### 3. צור את קובץ המפתח

```bash
# העתק את תוכן ה-Private Key שיצרת ב-Oracle Console
nano ~/oracle_hunter/oci_api_key.pem
chmod 600 ~/oracle_hunter/oci_api_key.pem
```

### 4. צור את קובץ ה-config

```
~/oracle_hunter/config:

[DEFAULT]
user=YOUR_USER_OCID
fingerprint=YOUR_FINGERPRINT
tenancy=YOUR_TENANCY_OCID
region=YOUR_REGION
key_file=/app/config/oci_api_key.pem
```

### 5. צור את main.tf

העתק את `docker/main.tf` מהפרויקט הזה ומלא את הפרטים שלך.

### 6. צור את run.sh

העתק את `docker/run.sh` מהפרויקט הזה ומלא את Telegram Token ו-Chat ID.

### 7. הרץ

```bash
docker run -d \
  --name oracle-cloud-repeater \
  --restart unless-stopped \
  -v "$HOME/oracle_hunter:/app/config" \
  oracle-cloud-repeater \
  /bin/bash /app/config/run.sh
```

### מעקב אחרי הלוגים

```bash
docker logs -f oracle-cloud-repeater
```

---

## שיטה ב' — GitHub Actions (ענן, ללא מחשב)

### 1. Fork את הפרויקט

לחץ **Fork** בפינה הימנית העליונה.

### 2. הגדר Secrets

עבור ל: `Settings → Secrets and variables → Actions → New repository secret`

| Secret | תוכן |
|---|---|
| `OCI_API_KEY` | תוכן קובץ ה-`.pem` (כולל `-----BEGIN PRIVATE KEY-----`) |
| `TELEGRAM_TOKEN` | הטוקן מ-BotFather |
| `TELEGRAM_CHAT_ID` | ה-Chat ID שלך |

### 3. עדכן main.tf

ערוך את `github-actions/main.tf` עם הפרטים שלך (Tenancy, User, Fingerprint, Subnet, Region).

### 4. הפעל

עבור ל: `Actions → Oracle Cloud Hunter → Run workflow`

מרגע ההפעלה — הכלי רץ לבד בענן ומפעיל את עצמו מחדש אוטומטית לאחר כל ריצה.

---

## מבנה הפרויקט

```
oracle-cloud-hunter/
├── README.md
├── docker/
│   ├── main.tf          # הגדרת ה-Instance ב-Terraform
│   └── run.sh           # סקריפט הציד עם Telegram
└── github-actions/
    ├── main.tf          # הגדרת ה-Instance ב-Terraform
    ├── hunt.sh          # סקריפט הציד
    ├── .gitignore
    └── .github/
        └── workflows/
            └── hunt.yml # הגדרת GitHub Actions
```

---

## הודעות Telegram

| הודעה | משמעות |
|---|---|
| 🚀 התחיל לרוץ | הסקריפט עלה |
| ⏳ עדיין מחפש | עדכון כל 5 דקות |
| ✅ הוקם בהצלחה | Instance מוכן + IP |
| ❌ נכשל | שגיאה שאינה capacity |
