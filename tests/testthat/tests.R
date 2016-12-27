library(dplyr)
library(xplor)

data(mtcars)
head(mtcars)


# mapping ####
mapping(cyl ~ gear, mtcars)





# cpf ####
cpf(mtcars, cyl)
cpf(mtcars, cyl, sort = FALSE)
cpf(mtcars, cyl, wt = "vs")
cpf_(mtcars, .dots = c("cyl","gear"))
cpf_(mtcars, .dots = "cyl", wt = "vs")
