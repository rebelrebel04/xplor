a <- mtcars[1:10, ]
b <- mtcars[6:15, ]
vjoin(a, b, "cyl")

vjoin(a, b, by = c("cyl", "gear"))
vjoin(a, b, by = c(cyl = "cyl", gear = "gear"))

temp <- vjoin(a, b, by = c("cyl", "gear"), join = "anti", flag_source = TRUE)
temp

temp <- vjoin(a, b, by = "disp", join = "full", wt = "mpg.x", flag_source = TRUE)
temp

temp <- vjoin(a, b, by = "disp", join = "full", flag_source = TRUE, suffix = c(".a", ".b"))
temp
