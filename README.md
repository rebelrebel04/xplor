
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

### ss

Produce a quick table of **s**ummary **s**tatistics with `ss`. The function accepts a named list of functions (specified as formulas) via the `funs` argument, with the default list covering the basics. If no variables are specified the table will summarize all numeric columns in the dataset. If `plot = TRUE` a facet-wrapped plot of histograms will be produced as a side-effect.

``` r
ss(mtcars, plot = TRUE, kable = TRUE)
```

![](README-unnamed-chunk-7-1.png)

| Variable |    N|  NAs|    Min|    P10|    Mean|  Median|     P90|     Max|      SD|    CV|
|:---------|----:|----:|------:|------:|-------:|-------:|-------:|-------:|-------:|-----:|
| mpg      |   32|    0|  10.40|  14.34|   20.09|   19.20|   30.09|   33.90|    6.03|  0.30|
| cyl      |   32|    0|   4.00|   4.00|    6.19|    6.00|    8.00|    8.00|    1.79|  0.29|
| disp     |   32|    0|  71.10|  80.61|  230.72|  196.30|  396.00|  472.00|  123.94|  0.54|
| hp       |   32|    0|  52.00|  66.00|  146.69|  123.00|  243.50|  335.00|   68.56|  0.47|
| drat     |   32|    0|   2.76|   3.01|    3.60|    3.70|    4.21|    4.93|    0.53|  0.15|
| wt       |   32|    0|   1.51|   1.96|    3.22|    3.33|    4.05|    5.42|    0.98|  0.30|
| qsec     |   32|    0|  14.50|  15.53|   17.85|   17.71|   19.99|   22.90|    1.79|  0.10|
| vs       |   32|    0|   0.00|   0.00|    0.44|    0.00|    1.00|    1.00|    0.50|  1.15|
| am       |   32|    0|   0.00|   0.00|    0.41|    0.00|    1.00|    1.00|    0.50|  1.23|
| gear     |   32|    0|   3.00|   3.00|    3.69|    4.00|    5.00|    5.00|    0.74|  0.20|
| carb     |   32|    0|   1.00|   1.00|    2.81|    2.00|    4.00|    8.00|    1.62|  0.57|

A `dplyr`-grouped dataframe can be passed to produce a dimensional summary table:

``` r
library(dplyr)
mtcars %>% 
  group_by(cyl) %>% 
  ss(kable = TRUE)
```

|  cyl| Variable |    N|  NAs|     Min|     P10|    Mean|  Median|     P90|     Max|     SD|    CV|
|----:|:---------|----:|----:|-------:|-------:|-------:|-------:|-------:|-------:|------:|-----:|
|    4| mpg      |   11|    0|   21.40|   21.50|   26.66|   26.00|   32.40|   33.90|   4.51|  0.17|
|    4| drat     |   11|    0|   71.10|   75.70|  105.14|  108.00|  140.80|  146.70|  26.87|  0.26|
|    4| vs       |   11|    0|   52.00|   62.00|   82.64|   91.00|  109.00|  113.00|  20.93|  0.25|
|    4| carb     |   11|    0|    3.69|    3.70|    4.07|    4.08|    4.43|    4.93|   0.37|  0.09|
|    4| hp       |   11|    0|    1.51|    1.62|    2.29|    2.20|    3.15|    3.19|   0.57|  0.25|
|    4| qsec     |   11|    0|   16.70|   16.90|   19.14|   18.90|   20.01|   22.90|   1.68|  0.09|
|    4| gear     |   11|    0|    0.00|    1.00|    0.91|    1.00|    1.00|    1.00|   0.30|  0.33|
|    4| disp     |   11|    0|    0.00|    0.00|    0.73|    1.00|    1.00|    1.00|   0.47|  0.64|
|    4| wt       |   11|    0|    3.00|    4.00|    4.09|    4.00|    5.00|    5.00|   0.54|  0.13|
|    4| am       |   11|    0|    1.00|    1.00|    1.55|    2.00|    2.00|    2.00|   0.52|  0.34|
|    6| disp     |    7|    0|   17.80|   17.98|   19.74|   19.70|   21.16|   21.40|   1.45|  0.07|
|    6| wt       |    7|    0|  145.00|  154.00|  183.31|  167.60|  238.20|  258.00|  41.56|  0.23|
|    6| am       |    7|    0|  105.00|  108.00|  122.29|  110.00|  143.80|  175.00|  24.26|  0.20|
|    6| mpg      |    7|    0|    2.76|    2.95|    3.59|    3.90|    3.92|    3.92|   0.48|  0.13|
|    6| drat     |    7|    0|    2.62|    2.71|    3.12|    3.21|    3.45|    3.46|   0.36|  0.11|
|    6| vs       |    7|    0|   15.50|   16.08|   17.98|   18.30|   19.75|   20.22|   1.71|  0.09|
|    6| carb     |    7|    0|    0.00|    0.00|    0.57|    1.00|    1.00|    1.00|   0.53|  0.94|
|    6| hp       |    7|    0|    0.00|    0.00|    0.43|    0.00|    1.00|    1.00|   0.53|  1.25|
|    6| qsec     |    7|    0|    3.00|    3.00|    3.86|    4.00|    4.40|    5.00|   0.69|  0.18|
|    6| gear     |    7|    0|    1.00|    1.00|    3.43|    4.00|    4.80|    6.00|   1.81|  0.53|
|    8| hp       |   14|    0|   10.40|   11.27|   15.10|   15.20|   18.28|   19.20|   2.56|  0.17|
|    8| qsec     |   14|    0|  275.80|  275.80|  353.10|  350.50|  454.00|  472.00|  67.77|  0.19|
|    8| gear     |   14|    0|  150.00|  157.50|  209.21|  192.50|  258.30|  335.00|  50.98|  0.24|
|    8| disp     |   14|    0|    2.76|    2.95|    3.23|    3.12|    3.67|    4.22|   0.37|  0.12|
|    8| wt       |   14|    0|    3.17|    3.44|    4.00|    3.75|    5.32|    5.42|   0.76|  0.19|
|    8| am       |   14|    0|   14.50|   14.84|   16.77|   17.18|   17.93|   18.00|   1.20|  0.07|
|    8| mpg      |   14|    0|    0.00|    0.00|    0.00|    0.00|    0.00|    0.00|   0.00|   NaN|
|    8| drat     |   14|    0|    0.00|    0.00|    0.14|    0.00|    0.70|    1.00|   0.36|  2.54|
|    8| vs       |   14|    0|    3.00|    3.00|    3.29|    3.00|    4.40|    5.00|   0.73|  0.22|
|    8| carb     |   14|    0|    2.00|    2.00|    3.50|    3.50|    4.00|    8.00|   1.56|  0.44|

Pass a custom list of summary functions as formulas on `x`:

``` r
mtcars %>% 
  ss(
    funs = list(
      "variance" = ~var(x, na.rm = TRUE), 
      "skewness" = ~moments::skewness(x, na.rm = TRUE), 
      "kurtosis" = ~moments::kurtosis(x, na.rm = TRUE)
    ), 
    kable = TRUE
  )
```

| Variable |  variance|  skewness|  kurtosis|
|:---------|---------:|---------:|---------:|
| mpg      |     36.32|      0.64|      2.80|
| cyl      |      3.19|     -0.18|      1.32|
| disp     |  15360.80|      0.40|      1.91|
| hp       |   4700.87|      0.76|      3.05|
| drat     |      0.29|      0.28|      2.44|
| wt       |      0.96|      0.44|      3.17|
| qsec     |      3.19|      0.39|      3.55|
| vs       |      0.25|      0.25|      1.06|
| am       |      0.25|      0.38|      1.15|
| gear     |      0.54|      0.55|      2.06|
| carb     |      2.61|      1.10|      4.54|

### mapping

For dimensions `x` and `y` in a dataset, there may be only one unique value of `y` associated with each unique value of `x`, or there may be multiple unique values of `y` associated with each unique value of `x`. `mapping` summarizes the association between `x` and `y` in a dataset, specified as a formula `x ~ y`:

``` r
mapping(cyl ~ gear, mtcars)
##   unique_ys n_xs pct_xs
## 1         1    1    33%
## 2         2    2    67%
```

In this example, there is one value of the "x" variable `cyl` that has a single unique "y" (`gear`) value associated with it, and two values of `cyl` that each have two unique `gear` values associated with them.

### findGrain

Often with a new dataset, you may not know the grain of the table (i.e., the combination of dimensions at which cases are unique). This function searches through candidate dimensions and ranks the top combinations in descending degree of de-duplication (aka normalization). In theory, the true grain of a table would be defined by the smallest combination of dimensions that yields 0 duplicates.

``` r
data(sleep)
findGrain(sleep, group, ID)
##   n_keys       keys duplicates
## 1      2 group * ID          0
## 2      1         ID         10
## 3      1      group         18
```
