
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

Core Functions
--------------

### cpf

`cpf` provides a quick frequency/percentile summary table for a dataset by one or more grouping variables. The most common use case is interactive crosstabs (though note that the output frequency table is always in long format).

``` r
data(mtcars)
cpf(mtcars, gear)
##   gear  n cumsum  pct cumpct
## 1    3 15     15  47%    47%
## 2    4 12     27  38%    84%
## 3    5  5     32  16%   100%
## 4 ==== 32     NA 100%     NA
```

You can also request a lightly-formatted `kable` when running `cpf` within an Rmarkdown file:

``` r
cpf(mtcars, gear, kable = TRUE)
```

| gear |    n|  cumsum|   pct|  cumpct|
|:-----|----:|-------:|-----:|-------:|
| 3    |   15|      15|   47%|     47%|
| 4    |   12|      27|   38%|     84%|
| 5    |    5|      32|   16%|    100%|
| ==== |   32|      NA|  100%|      NA|

A nice feature is that you can pass `cpf` computed variables using bare variable names:

``` r
cpf(mtcars, carb >= 4)
##   carb >= 4  n cumsum  pct cumpct
## 1     FALSE 20     20  62%    62%
## 2      TRUE 12     32  38%   100%
## 3      ==== 32     NA 100%     NA

cpf(mtcars, is.na(cyl))
##   is.na(cyl)  n cumsum  pct cumpct
## 1      FALSE 32     32 100%   100%
## 2       ==== 32     NA 100%     NA
```

The SE version of `cpf_` is provided in the event you have variable names built up through some other means:

``` r
vars <- names(mtcars)[grepl("^c", names(mtcars))]
cpf_(mtcars, .dots = vars)
##     cyl carb  n cumsum  pct cumpct
## 1     4    2  6      6  19%    19%
## 2     8    4  6     12  19%    38%
## 3     4    1  5     17  16%    53%
## 4     6    4  4     21  12%    66%
## 5     8    2  4     25  12%    78%
## 6     8    3  3     28   9%    88%
## 7     6    1  2     30   6%    94%
## 8     6    6  1     31   3%    97%
## 9     8    8  1     32   3%   100%
## 10 ==== ==== 32     NA 100%     NA
```

### mapping

For dimensions `x` and `y` in a dataset, there may be only one unique value of `y` associated with each unique value of `x`, or there may be multiple unique values of `y` associated with each unique value of `x`. `mapping` summarizes the association between `x` and `y` in a dataset, specified as a formula (`x ~ y`):

``` r
mapping(cyl ~ gear, mtcars)
##   unique_ys n_xs pct_xs
## 1         1    1    33%
## 2         2    2    67%
```

In this example, there is one value of the "x" variable `cyl` that has a single unique "y" value `gear` associated with it, and two values of `cyl` that each have two unique `gear` values associated with them.

### findGrain

Often with a new dataset, you may not know the grain of the table (i.e., the combination of dimensions at which cases are unique). This function searches through candidate dimensions and ranks the top combinations in descending amount of de-duplication (aka denormalization). Ideally, the true grain of a table would be defined by the smallest combination of dimensions that yields 0 duplicates.

``` r
data(sleep)
findGrain(sleep, group, ID)
##   n_keys       keys duplicates
## 1      2 group * ID          0
## 2      1         ID         10
## 3      1      group         18
```
