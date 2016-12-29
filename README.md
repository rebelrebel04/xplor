
<!-- README.md is generated from README.Rmd. Please edit that file -->
xplor
=====

A package of utility functions for assisting with interactive data exploration, particularly geared toward understanding record layouts of relational data (e.g., the grain of a table, mappings between primary and affiliate dimensions, extent of normalization/denormalization, etc.). NSE and SE versions of core functions are provided to facilitate interactive and programming use.

Installation
------------

Install **xplor** from github with:

``` r
# install.packages("devtools")
devtools::install_github("xplor/rebelrebel04")
```

Examples
--------

### cpf

This function is useful for interactive crosstabs (although the output frequency table is always in long format).

``` r
data(mtcars)
cpf(mtcars, gear)
#> # A tibble: 4 x 5
#>    gear                 n            cumsum               pct
#>   <chr> <S3: formattable> <S3: formattable> <S3: formattable>
#> 1     3                15                15               47%
#> 2     4                12                27               38%
#> 3     5                 5                32               16%
#> 4  ====                32                NA              100%
#> # ... with 1 more variables: cumpct <S3: formattable>
```

One of the coolest things about `cpf` is that you can pass it flag variables directly, using bare variable names:

``` r
cpf(mtcars, carb >= 4)
#> # A tibble: 3 x 5
#>   carb >= 4                 n            cumsum               pct
#>       <chr> <S3: formattable> <S3: formattable> <S3: formattable>
#> 1     FALSE                20                20               62%
#> 2      TRUE                12                32               38%
#> 3      ====                32                NA              100%
#> # ... with 1 more variables: cumpct <S3: formattable>
cpf(mtcars, is.na(cyl))
#> # A tibble: 2 x 5
#>   is.na(cyl)                 n            cumsum               pct
#>        <chr> <S3: formattable> <S3: formattable> <S3: formattable>
#> 1      FALSE                32                32              100%
#> 2       ====                32                NA              100%
#> # ... with 1 more variables: cumpct <S3: formattable>
```

The SE version of `cpf_` is provided in the event you have variable names built up through some other means:

``` r
vars <- names(mtcars)[grepl("^c", names(mtcars))]
cpf_(mtcars, .dots = vars)
#> Source: local data frame [10 x 6]
#> Groups: cyl [4]
#> 
#>      cyl  carb                 n            cumsum               pct
#>    <chr> <chr> <S3: formattable> <S3: formattable> <S3: formattable>
#> 1      4     2                 6                 6               19%
#> 2      8     4                 6                12               19%
#> 3      4     1                 5                17               16%
#> 4      6     4                 4                21               12%
#> 5      8     2                 4                25               12%
#> 6      8     3                 3                28                9%
#> 7      6     1                 2                30                6%
#> 8      6     6                 1                31                3%
#> 9      8     8                 1                32                3%
#> 10  ====  ====                32                NA              100%
#> # ... with 1 more variables: cumpct <S3: formattable>
```
