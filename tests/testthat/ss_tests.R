data(mtcars)
ss(mtcars)
ss(mtcars, plot = TRUE, kable = TRUE)
ss(mtcars, gear, cyl)

ss(mtcars, gear, cyl, kable = TRUE)

mtcars$gear <- paste(mtcars$gear)
ss(mtcars, gear, cyl)

ss(data.table::as.data.table(mtcars), gear, cyl, hp)



data("ChickWeight")
head(ChickWeight)
ss(ChickWeight)


data("Theoph")
ss(Theoph)
ss(Theoph, Dose)
ss_(Theoph, .dots = "Dose")


C.0 <- data.table::fread("./tests/testthat/firstTxProducts_RepeatVsOneOffCustomers_v2.tsv", sep = "\t", na.strings = c("NA","NULL",""))
View(ss(C.0))
ss(C.0, tx1_NetSalesAmount)
