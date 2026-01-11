# Pitch Usage Analysis: Splits

## Overview

This R project analyzes MLB Statcast data to generate **pitch usage tables for pitchers against either right or left handed hitters**. Using `tidyverse` and `gt` packages, it calculates the frequency of each pitch type by count (balls-strikes) and displays the results in a visually appealing table, complete with player headshots and team logos.

The resulting table provides insights into a pitcher's tendencies in different count situations, helping fans understand a pitcher's strategy.

## Features

* Filters Statcast data for a specific pitcher.
* Calculates pitch usage percentages for each pitch type in all ball-strike counts.
* Excludes infrequent pitches (default threshold: 10 pitches).
* Automatically generates an HTML/GT table with:
    * Player Headshot Photo
    * Team Logo
    * Count-by-count pitch usage percentages
    * Heatmap coloring to visualize frequency
* Supports dynamic labeling of pitch types.
* Optional export to PNG for sharing or reporting.

## Dependencies

`tidyverse`

`gt`

`glue`

`here`

## Acknowledgements

* Data: [MLB Statcast](https://baseballsavant.mlb.com)
* Images: MLB, ESPN
* Author: Carson Hallford

## Example Output:
![Pitch Usage vs RHH](pitch_usage_rhh.png?v=2)