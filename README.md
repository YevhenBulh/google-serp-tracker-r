# 🚀 Google SERP Position Tracker (R Script)

This simple R script allows you to track your website's Google rankings for free using the Serper.dev API and Google Sheets.

It's designed for SEO specialists, marketers, and data enthusiasts who want a lightweight, automated solution without paying for expensive tools.

## ✨ Features
*   **Inputs:** Reads keywords directly from your Google Sheet.
*   **Processing:** Checks the top 30 Google results (US location by default) for each keyword.
*   **Output:** Creates a NEW tab in your Google Sheet with today's date (e.g., `2024-05-20_positions`) containing all rankings.
*   **Cost:** **Free** for the first ~2,500 searches (Serper.dev offers free credits on sign-up).

---

## 🛠 Prerequisites

Before you start, you need to have R installed on your computer.

1.  **Install R:** [Download here](https://cloud.r-project.org/)
2.  **Install RStudio (Optional but recommended):** [Download here](https://posit.co/download/rstudio-desktop/)

---

## 📝 Step-by-Step Guide

### 1. Get Your API Key
1.  Go to [serper.dev](https://serper.dev/).
2.  Sign up (it's quick and free).
3.  On the dashboard, copy your **API Key**.

### 2. Prepare Your Google Sheet
1.  Create a new Google Sheet (or use an existing one).
2.  Create a tab named **`keywords`**.
3.  In the first row (A1), type `keyword`.
4.  List your keywords in column A (A2, A3, etc.).
    *   *Example:*
        | | A |
        |---|---|
        | 1 | **keyword** |
        | 2 | coffee machine |
        | 3 | best espresso |

5.  **Important:** Copy the **Sheet ID** from the URL.
    *   URL format: `https://docs.google.com/spreadsheets/d/`**`1LuxygBoRkUlnZ6mO8gLcm6WS3j64h0CWliasCmXh1Tk`**`/edit`
    *   Your ID is the long string of random characters between `/d/` and `/edit`.

### 3. Setup the Script
1.  Download the `public_serp_tracker.R` file attached to this repository.
2.  Open the file in RStudio.
3.  Look at the **CONFIGURATION** section at the top of the script:

```r
# --- CONFIGURATION ---
SHEET_ID <- "PASTE_YOUR_GOOGLE_SHEET_ID_HERE" 
SHEET_NAME <- "keywords"
SERPER_API_KEY <- "PASTE_YOUR_SERPER_API_KEY_HERE"
```

4.  Replace `PASTE_YOUR_GOOGLE_SHEET_ID_HERE` with your copied **Sheet ID**.
5.  Replace `PASTE_YOUR_SERPER_API_KEY_HERE` with your **Serper API Key**.

### 4. Run the Script
1.  In RStudio, select all code (Cmd+A or Ctrl+A) and click **Run**, or just click the **Source** button.
2.  **First time only:** The console will ask for permission to access your Google Sheets.
    *   Look at the "Console" window in RStudio.
    *   It will ask `Is it ok to cache OAuth credentials between R sessions?`. Type `1` for Yes and press Enter.
    *   A browser window will open. Login with your Google account and allow access.
3.  The script will start running and printing progress in the console.

### 5. Check Results
Go back to your Google Sheet. You will see a new tab named with today's date containing:
*   `today's date`
*   `keyword`
*   `position` (Rank)
*   `link`
*   `title`
*   `snippet` (Description)

---

## ❓ FAQ

**Q: I get an error `there is no package called 'googlesheets4'`?**
A: You need to install the packages first. Copy and paste this line into the RStudio Console and press Enter:
```r
install.packages(c("googlesheets4", "httr", "jsonlite", "dplyr"))
```

**Q: Can I change the country?**
A: Yes! In the configuration section, change `COUNTRY <- "us"` to `"uk"`, `"ca"`, `"de"`, etc.

**Q: Is my data safe?**
A: Yes. The script runs locally on your computer. The data only moves between your Google Sheet and your computer.

---
*Happy Tracking!*

