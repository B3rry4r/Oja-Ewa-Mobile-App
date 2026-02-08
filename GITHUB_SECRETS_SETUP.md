# 🔐 GitHub Secrets Setup Guide for Android Release Signing

## 📋 Overview
This guide will help you configure GitHub secrets to automatically sign your Android releases using GitHub Actions.

---

## 🚀 Step-by-Step Instructions

### Step 1: Encode Your Keystore to Base64

Run this command in your terminal from the project root:

```bash
base64 android/app/upload-keystore.jks | tr -d '\n'
```

**Copy the entire output** - you'll need it for the `KEYSTORE_BASE64` secret.

---

### Step 2: Add Secrets to GitHub Repository

1. Go to your GitHub repository
2. Click on **Settings** (top right)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**

Add these **4 secrets** one by one:

---

#### Secret 1: `KEYSTORE_BASE64`
- **Name:** `KEYSTORE_BASE64`
- **Value:** Paste the base64 encoded string from Step 1
- Click **Add secret**

---

#### Secret 2: `KEYSTORE_PASSWORD`
- **Name:** `KEYSTORE_PASSWORD`
- **Value:** `08105340452`
- Click **Add secret**

---

#### Secret 3: `KEY_PASSWORD`
- **Name:** `KEY_PASSWORD`
- **Value:** `08105340452`
- Click **Add secret**

---

#### Secret 4: `KEY_ALIAS`
- **Name:** `KEY_ALIAS`
- **Value:** `upload`
- Click **Add secret**

---

## ✅ Verify Your Secrets

After adding all secrets, you should see:
- ✅ KEYSTORE_BASE64
- ✅ KEYSTORE_PASSWORD
- ✅ KEY_PASSWORD
- ✅ KEY_ALIAS

---

## 🏃 Running the Workflow

### Option 1: Manual Trigger (Workflow Dispatch)
1. Go to **Actions** tab in your GitHub repository
2. Click on **Flutter Android CI** workflow
3. Click **Run workflow** button
4. Select branch (usually `main` or `develop`)
5. Click **Run workflow**

### Option 2: Automatic Trigger (Optional)
To enable automatic builds on push, edit `.github/workflows/android.yml`:

```yaml
on:
  workflow_dispatch:
  push:
    branches: [ main, develop ]  # Remove the # to uncomment
```

---

## 📦 What Gets Built

When the workflow runs, it will:

1. ✅ Checkout your code
2. ✅ Setup Java 17 and Flutter
3. ✅ Decode and setup your keystore from secrets
4. ✅ Build a **signed APK** (`ojaewa-release.apk`)
5. ✅ Build a **signed AAB** (`ojaewa-release.aab`) - for Google Play Store
6. ✅ Upload both files as GitHub release assets

---

## 📱 Download Your Builds

After the workflow completes:

1. Go to the **Releases** page in your repository
2. Find the release tagged `v1.0.X` (X = build number)
3. Download:
   - `ojaewa-release.apk` - Install on Android devices
   - `ojaewa-release.aab` - Upload to Google Play Console

---

## 🔒 Security Notes

### ⚠️ IMPORTANT: Update .gitignore

Make sure these files are **NEVER committed** to your repository:

```bash
# Should already be in .gitignore
android/key.properties
android/app/upload-keystore.jks
*.jks
*.keystore
key.properties
```

### After Setting Up GitHub Secrets:

**You can safely delete the local files** (they're already in GitHub secrets):
```bash
# Optional: Remove local keystore files after confirming secrets work
rm android/key.properties
rm android/app/upload-keystore.jks
```

The workflow will recreate them from secrets during each build.

---

## 🐛 Troubleshooting

### Build fails with "keystore not found"
- Check that `KEYSTORE_BASE64` secret is set correctly
- Make sure you copied the entire base64 string (no spaces or line breaks)

### Build fails with "incorrect password"
- Verify `KEYSTORE_PASSWORD` and `KEY_PASSWORD` are correct: `08105340452`

### Build fails with "alias not found"
- Verify `KEY_ALIAS` is set to: `upload`

### Base64 encoding issues
If the base64 command doesn't work, try:
```bash
# For macOS/Linux
base64 -i android/app/upload-keystore.jks | tr -d '\n'

# For Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\upload-keystore.jks"))
```

---

## 🎉 Success!

Once configured, every workflow run will:
- ✅ Build signed release APK
- ✅ Build signed release AAB
- ✅ Automatically upload to GitHub Releases
- ✅ Version incrementally (v1.0.1, v1.0.2, etc.)

No more manual signing needed! 🚀

---

## 📞 Need Help?

If you encounter issues:
1. Check the workflow logs in the Actions tab
2. Verify all 4 secrets are added correctly
3. Ensure your keystore file is valid
