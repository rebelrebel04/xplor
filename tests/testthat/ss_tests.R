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
C.0 <- C.0[, -c(12, 57)]
C.0 %>%
  select(MailStatusTypeCode, starts_with("tx1_")) %>%
  ss(plot = TRUE) %>%
  View()
ss(C.0, tx1_NetSalesAmount)
C.0 %>%
  group_by(MailStatusTypeCode, EmailStatusTypeCode) %>%
  ss(tx1_NetSalesAmount)


ss(Theoph)
ss(Theoph, Dose, Wt)
Theoph %>%
  group_by(Subject) %>%
  ss(Dose)
Theoph %>%
  group_by(Subject) %>%
  ss()






