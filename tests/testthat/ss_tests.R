data(mtcars)
ss(mtcars)
ss(mtcars, plot = TRUE, kable = TRUE)
ss(mtcars, gear, cyl)

ss(mtcars, gear, cyl, kable = TRUE)

mtcars$gear <- paste(mtcars$gear)
ss(mtcars, gear, cyl)

ss(data.table::as.data.table(mtcars), gear, cyl, hp)
