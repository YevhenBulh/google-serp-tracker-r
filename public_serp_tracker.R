#!/usr/bin/env Rscript
# Script to collect Google Search positions via Serper API
# Reads keywords from Google Sheets and writes results back to a new tab

# Install necessary libraries (run once in Console if not installed)
# install.packages(c("googlesheets4", "httr", "jsonlite", "dplyr"))

library(googlesheets4)
library(httr)
library(jsonlite)
library(dplyr)

# --- CONFIGURATION -----------------------------------------------------------
# 1. Google Sheet ID (found in the URL of your spreadsheet: /d/YOUR_ID_HERE/edit)
SHEET_ID <- "PASTE_YOUR_GOOGLE_SHEET_ID_HERE" 

# 2. Name of the tab/sheet containing your keywords (must have a header "keyword")
SHEET_NAME <- "keywords"

# 3. Serper.dev API Key (Get it from https://serper.dev)
SERPER_API_KEY <- "PASTE_YOUR_SERPER_API_KEY_HERE"

# 4. Search Settings
SERPER_API_URL <- "https://google.serper.dev/search"
COUNTRY <- "us"           # "us", "uk", "ca", etc.
RESULTS_PER_KEYWORD <- 30 # How many top results to fetch (10, 20, 30...)
# -----------------------------------------------------------------------------

# Function to get search results via Serper API
get_serper_results <- function(keyword, page = 1, num = 10) {
  headers <- c(
    'X-API-KEY' = SERPER_API_KEY,
    'Content-Type' = 'application/json'
  )
  
  body <- list(
    q = keyword,
    gl = COUNTRY,
    num = num,
    page = page
  )
  
  response <- POST(
    url = SERPER_API_URL,
    add_headers(.headers = headers),
    body = toJSON(body, auto_unbox = TRUE),
    encode = "json"
  )
  
  if (status_code(response) == 200) {
    content <- content(response, "parsed")
    return(content$organic)
  } else {
    warning(paste("Error for keyword:", keyword, "- Status:", status_code(response)))
    return(NULL)
  }
}

# Function to collect top 30 positions for a keyword
collect_all_positions <- function(keyword) {
  all_results <- list()
  
  # Helper for safe value extraction
  safe_get <- function(x, default = "") {
    if (is.null(x) || is.na(x)) return(default)
    return(as.character(x))
  }
  
  # Page 1 (Positions 1-10)
  cat("    Requesting page 1...")
  page1 <- get_serper_results(keyword, page = 1, num = 10)
  if (!is.null(page1) && length(page1) > 0) {
    cat(paste(" got", length(page1), "results\n"))
    for (i in seq_along(page1)) {
      result <- page1[[i]]
      all_results[[length(all_results) + 1]] <- list(
        position = ifelse(is.null(result$position), i, result$position),
        title = safe_get(result$title),
        link = safe_get(result$link),
        snippet = safe_get(result$snippet),
        date = safe_get(result$date)
      )
    }
  } else {
    cat(" no results\n")
  }
  
  # Page 2 (Positions 11-20)
  cat("    Requesting page 2...")
  page2 <- get_serper_results(keyword, page = 2, num = 10)
  if (!is.null(page2) && length(page2) > 0) {
    cat(paste(" got", length(page2), "results\n"))
    for (i in seq_along(page2)) {
      result <- page2[[i]]
      all_results[[length(all_results) + 1]] <- list(
        position = ifelse(is.null(result$position), i + 10, result$position + 10),
        title = safe_get(result$title),
        link = safe_get(result$link),
        snippet = safe_get(result$snippet),
        date = safe_get(result$date)
      )
    }
  } else {
    cat(" no results\n")
  }
  
  # Page 3 (Positions 21-30)
  cat("    Requesting page 3...")
  page3 <- get_serper_results(keyword, page = 3, num = 10)
  if (!is.null(page3) && length(page3) > 0) {
    cat(paste(" got", length(page3), "results\n"))
    for (i in seq_along(page3)) {
      result <- page3[[i]]
      all_results[[length(all_results) + 1]] <- list(
        position = ifelse(is.null(result$position), i + 20, result$position + 20),
        title = safe_get(result$title),
        link = safe_get(result$link),
        snippet = safe_get(result$snippet),
        date = safe_get(result$date)
      )
    }
  } else {
    cat(" no results\n")
  }
  
  return(all_results)
}

# Main execution function
main <- function() {
  cat("========================================\n")
  cat("STARTING SCRIPT\n")
  cat("========================================\n")
  cat(paste("Time:", Sys.time(), "\n"))
  cat(paste("Sheet ID:", SHEET_ID, "\n"))
  cat(paste("Sheet Name:", SHEET_NAME, "\n"))
  cat("========================================\n\n")
  
  # Step 1: Google Sheets Authentication
  cat("Step 1: Authenticating with Google Sheets...\n")
  tryCatch({
    gs4_auth() # Opens browser for first-time auth
    cat("✓ Authentication successful\n\n")
  }, error = function(e) {
    cat(paste("✗ Auth error:", e$message, "\n"))
    stop("Failed to authenticate with Google Sheets")
  })
  
  # Step 2: Read keywords
  cat("Step 2: Reading keywords from Google Sheets...\n")
  cat(paste("  Reading tab:", SHEET_NAME, "\n"))
  tryCatch({
    keywords_df <- read_sheet(SHEET_ID, sheet = SHEET_NAME)
    cat(paste("✓ Tab read successfully, rows:", nrow(keywords_df), "\n\n"))
  }, error = function(e) {
    cat(paste("✗ Error reading sheet:", e$message, "\n"))
    stop("Failed to read keywords from Google Sheet")
  })
  
  # Step 3: Identify keyword column
  cat("Step 3: Identifying keyword column...\n")
  cat(paste("  Available columns:", paste(names(keywords_df), collapse = ", "), "\n"))
  
  if ("keyword" %in% names(keywords_df)) {
    keywords <- keywords_df$keyword
    cat("  Using column 'keyword'\n")
  } else {
    keywords <- keywords_df[[1]] # Fallback to first column
    cat(paste("  Using first column:", names(keywords_df)[1], "\n"))
  }
  
  # Remove empty values
  keywords <- keywords[!is.na(keywords) & keywords != ""]
  
  cat(paste("✓ Found", length(keywords), "keywords to process\n\n"))
  
  if (length(keywords) == 0) {
    stop("No keywords found!")
  }
  
  # Step 4: Collect data
  cat("Step 4: Collecting data via Serper API...\n")
  cat("========================================\n")
  all_data <- data.frame()
  today_date <- Sys.Date()
  
  for (i in seq_along(keywords)) {
    keyword <- keywords[i]
    cat(paste("\n[", i, "/", length(keywords), "] Processing:", keyword, "\n"))
    
    results <- collect_all_positions(keyword)
    
    cat(paste("  Total results collected:", length(results), "\n"))
    
    if (length(results) > 0) {
      for (result in results) {
        all_data <- rbind(all_data, data.frame(
          date = as.character(today_date),
          keyword = keyword,
          position = as.integer(result$position),
          link = as.character(result$link),
          title = as.character(result$title),
          snippet = as.character(result$snippet),
          date_result = as.character(result$date),
          stringsAsFactors = FALSE
        ))
      }
    }
    
    # Small delay to respect API rate limits
    Sys.sleep(1)
  }
  
  # Check if we have data
  if (nrow(all_data) == 0) {
    cat("Warning: No data collected for any keyword!\n")
    return(invisible(NULL))
  }
  
  # Create new sheet name (e.g., "2023-10-27_positions")
  new_sheet_name <- paste0(format(today_date, "%Y-%m-%d"), "_positions")
  
  cat(paste("Preparing to write to new tab:", new_sheet_name, "\n"))
  
  # Rename columns for final output
  colnames(all_data)[colnames(all_data) == "date"] <- "today's date"
  colnames(all_data)[colnames(all_data) == "date_result"] <- "date"
  
  # Reorder columns
  all_data <- all_data[, c("today's date", "keyword", "position", "link", "title", "snippet", "date")]
  
  # Step 5: Write to Google Sheets
  cat("\n")
  cat("Step 5: Writing data to Google Sheets...\n")
  tryCatch({
    write_sheet(all_data, ss = SHEET_ID, sheet = new_sheet_name)
    cat(paste("✓ Success! Wrote", nrow(all_data), "rows to tab", new_sheet_name, "\n"))
  }, error = function(e) {
    cat(paste("✗ Error writing to Sheets:", e$message, "\n"))
    # Local backup
    backup_file <- paste0("backup_", new_sheet_name, ".csv")
    write.csv(all_data, backup_file, row.names = FALSE)
    cat(paste("Data saved locally to:", backup_file, "\n"))
  })
  
  cat("\n")
  cat("========================================\n")
  cat("JOB COMPLETED\n")
  cat(paste("Finished at:", Sys.time(), "\n"))
  cat("========================================\n")
}

# Run main function
main()

