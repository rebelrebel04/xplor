# xplor

A package of utility functions for assisting with interactive data exploration, particularly geared toward understanding record layouts of relational data (e.g., the grain of a table, mappings between primary and affiliate dimensions, extent of normalization/denormalization, etc.). NSE and SE versions of core functions are provided to facilitate interactive and programming use.

## Installation

Install **xplor** from github with:

```R
# install.packages("devtools")
devtools::install_github("xplor/rebelrebel04")
```

## Examples

### cpf

This function is useful for interactive crosstabs (although the output frequency table is always in long format). 

```R
data(mtcars)
cpf(mtcars, gear)
```

One of the coolest things about `cpf` is that you can pass it flag variables directly, using bare variable names:

```R
cpf(mtcars, carb >= 4)
cpf(mtcars, is.na(cyl))
```

The SE version of `cpf_` is provided in the event you have variable names built up through some other means:

```R
vars <- names(mtcars)[grepl("^w", names(mtcars))]
cpf_(mtcars, .dots = vars)
```
