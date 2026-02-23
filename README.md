
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{nsseShinyPublic}`

<!-- badges: start -->

<!-- badges: end -->

## Installation

You can install the development version of `{nsseShinyPublic}` like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Run

You can launch the application by running:

``` r
nsseShinyPublic::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2026-02-23 13:02:20 EST"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ══ Documenting ═════════════════════════════════════════════════════════════════
#> ℹ Installed roxygen2 version (7.3.3) doesn't match required (7.1.1)
#> ✖ `check()` will not re-document this package
#> ── R CMD check results ───────────────────────── nsseShinyPublic 0.0.0.9000 ────
#> Duration: 1m 20.7s
#> 
#> ❯ checking for future file timestamps ... NOTE
#>   unable to verify current time
#> 
#> 0 errors ✔ | 0 warnings ✔ | 1 note ✖
```

``` r
covr::package_coverage()
#> nsseShinyPublic Coverage: 0.00%
#> R/app_config.R: 0.00%
#> R/app_ui.R: 0.00%
#> R/run_app.R: 0.00%
```
