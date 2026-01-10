# Load libraries --------------------------------------------------------------
library(tidyverse)
library(gt)

# Configuration and Metadata --------------------------------------------------

# Mapping Statcast abbreviations to full pitch names for table labels
pitch_type_labels <- c(
  CH = "Changeup", CU = "Curveball", FF = "4-Seam Fastball",
  SI = "Sinker", SL = "Slider", FC = "Cutter", FS = "Splitter",
  KC = "Knuckle Curve", ST = "Sweeper", SV = "Slurve",
  FO = "Forkball", SC = "Screwball", CS = "Slow Curve",
  KN = "Knuckleball", EP = "Eephus"
)

# Load Statcast data
data <- read_rds(here::here("data_large/statcast_rds/statcast_2025_v2.rds"))

# Filter for specific pitcher
sc_pitcher <- data |>
  filter(pitcher_name == "Nathan Eovaldi")

# Threshold to exclude pitches thrown too infrequently
min_pitches <- 10  # Adjust as needed

# Data Processing -------------------------------------------------------------

pitch_mix <- sc_pitcher |>
  # Filtering for pitches thrown against Right-Handed Hitters (RHH)
  filter(stand == "R") |>
  # Count occurrences of each pitch type per ball/strike count
  group_by(balls, strikes, pitch_type) |>
  summarize(N = n(), .groups = "drop") |>
  # Remove pitch types that don't meet the minimum volume threshold
  group_by(pitch_type) |>
  filter(sum(N) >= min_pitches) |>
  ungroup() |>
  # Reshape data: one column per pitch type
  pivot_wider(
    names_from = pitch_type,
    values_from = N,
    values_fill = 0
  ) |>
  # Calculate frequency (percentage) across rows
  mutate(
    num_pitches = rowSums(pick(-balls, -strikes)),
    across(c(-balls, -strikes, -num_pitches), ~ .x / num_pitches)
  ) |>
  # Cleanup: Create "Count" label and remove helper columns
  select(-num_pitches) |>
  mutate(count = paste0(balls, "-", strikes)) |>
  select(count, everything(), -balls, -strikes)

# Identify which pitch columns actually exist in final dataset 
pitch_cols <- names(pitch_mix)[names(pitch_mix) %in% names(pitch_type_labels)]

# Visual Assets ---------------------------------------------------------------

# Extract player info for header
p_id <- sc_pitcher$pitcher[1]
p_name <- sc_pitcher$pitcher_name[1]
p_team <- sc_pitcher$pitcher_team[1]

# Dynamic URLs for MLB Headshot photos and ESPN Team Logos
headshot_url <- glue::glue(
  "https://img.mlbstatic.com/mlb-photos/image/upload/",
  "d_people:generic:headshot:67:current.png/w_640,q_auto:best/",
  "v1/people/{p_id}/headshot/silo/current.png"
)

team_url <- glue::glue(
  "https://a.espncdn.com/combiner/i?img=/i/teamlogos/mlb/500/scoreboard/{p_team}.png&h=500&w=500"
)

# Create HTML Header for the GT Table
header_html <- glue::glue("
  <div style='position: relative; width: 100%; text-align: center; padding-top: 10px;'>
    <img src='{headshot_url}' style='position: absolute; left: 0; top: -10px; height: 70px;'>
    <img src='{team_url}' style='position: absolute; right: 0; top: -4px; height: 70px;'>
    <div style='font-weight: bold; font-size: 32px; transform: translateY(-8px);'>{p_name}</div>
    <div style='font-size: 16px; color: #666; transform: translateY(-6px);'>
      Pitch Usage by Count vs. Right-Handed Hitters
    </div>
  </div>
")

# Table Generation ------------------------------------------------------------

pitch_mix_gt <-
  pitch_mix |>
  gt() |>
  # Add Header & Formatting
  tab_header(title = html(header_html)) |>
  opt_align_table_header(align = "center") |>
  fmt_percent(columns = all_of(pitch_cols), decimals = 1) |>
  # Heatmap coloring based on frequency (darker = higher percentage)
  data_color(
    columns = all_of(pitch_cols),
    direction = "row",
    palette = "Blues"
  ) |>
  # Relabel columns using pitch dictionary
  cols_label(count = "Count", !!!pitch_type_labels[pitch_cols]) |>
  cols_align(align = "center", columns = everything()) |>
  # Source Notes / Footer
  tab_source_note(
    source_note = html(
      "<div style='display: flex; justify-content: space-between;'>",
      "<div>Data: MLB<br> Images: MLB, ESPN</div>",
      "<div>By: Carson Hallford</div>",
      "</div>"
    )) |>
  # Styling Options
  opt_table_font(font = google_font("Roboto")) |>
  tab_options(
    column_labels.font.weight = "bold",
    source_notes.font.size = 10,
    table.width = px(650),
    table.border.top.style = "none",
    table.border.bottom.style = "none",
    heading.border.bottom.style = "none",
    column_labels.border.top.style = "none"
  )

# Display Table
pitch_mix_gt

# Export/Save Graphic Section -------------------------------------------------

# Sys.setenv(CHROMOTE_CHROME = "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser")

# gtsave(
#   pitch_mix_gt,
#   filename = "~/Desktop/pitch_usage_rhh.png",
#   zoom = 4,
#   vwidth = 700,
#   vheight = 1000
# )
