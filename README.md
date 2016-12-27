# xplor

The goal of xplor is to ...

## Installation

You can install xplor from github with:

```R
# install.packages("devtools")
devtools::install_github("xplor/rebelrebel04")
```

## Example

This is a basic example which shows you how to solve a common problem:

```R
# One of the coolest things about cpf is that you can pass it flag variables directly
cpf(iq.0, ProductNumber %=~% "\\d{14}")
cpf(iq.0, is.na(ProductNumber), is.na(UPC))
```
