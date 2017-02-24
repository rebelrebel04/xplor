data(mtcars)
cpf(mtcars, gear, cyl)
cpf(mtcars, gear, cyl, kable = TRUE)
cpf(mtcars, gear, cyl, drop = FALSE, kable = TRUE)
cpf(mtcars, gear, cyl, chi_square = TRUE, kable = TRUE)
cpf(mtcars, gear, cyl, carb, chi_square = TRUE, kable = TRUE)

cpf(mtcars, gear, cyl, chi_square = TRUE)
cpf(mtcars, gear, cyl, wt = "carb", chi_square = TRUE)

cpf_(mtcars, "gear", .dots = c("cyl","carb"))

cpf(mtcars, foo = gear > 4, cyl)


data("Theoph")
cpf_(Theoph, "Dose")


C.0 <- data.table::fread("./tests/testthat/firstTxProducts_RepeatVsOneOffCustomers_v2.tsv", sep = "\t", na.strings = c("NA","NULL",""))
C.0 <- C.0[, -c(12, 57)]
C.0[
  ,
  `:=`(
    # Bounce vs. Returned
    user_type = ifelse(is.na(tx2_TransactionKey), "Bounced", "Returned"),
    # tx1/2 Profit as NetSalesAmount - ic_CostAmount
    tx1_profit = tx1_NetSalesAmount - tx1_ic_CostAmount,
    tx2_profit = tx2_NetSalesAmount - tx2_ic_CostAmount,
    # tx1 total Sale QTY
    tx1_QTY_S = C.0 %>% rowwise() %>% select(matches("^tx1_QTY_S_")) %>% rowSums(na.rm = TRUE),
    # tx1 total Return QTY (negative number)
    tx1_QTY_R = C.0 %>% rowwise() %>% select(matches("^tx1_QTY_R_")) %>% rowSums(na.rm = TRUE),
    # tx2 total Sale QTY
    tx2_QTY_S = C.0 %>% rowwise() %>% select(matches("^tx2_QTY_S_")) %>% rowSums(na.rm = TRUE),
    # tx2 total Return QTY (negative number)
    tx2_QTY_R = C.0 %>% rowwise() %>% select(matches("^tx2_QTY_R_")) %>% rowSums(na.rm = TRUE),
    # Tx2 - Tx1 NetSalesAmount difference
    tx2_tx1_NetSalesAmount_diff = tx2_NetSalesAmount - tx1_NetSalesAmount,
    # Channel Status (Single vs. Cross-channel)
    channel_status =
      case_when(
        !is.na(tx2_TransactionKey) & tx1_channelType == tx2_channelType ~ "Single-Channel",
        !is.na(tx2_TransactionKey) & tx1_channelType != tx2_channelType ~ "Cross-Channel"
      )
  )
  ]


C.0[
  ,
  `:=`(
    # tx1 Type (Sale, Return, Mixed)
    tx1_type =
      case_when(
        tx1_QTY_S > 0 & tx1_QTY_R == 0 ~ "S",
        tx1_QTY_S == 0 & tx1_QTY_R < 0 ~ "R",
        tx1_QTY_S > 0 & tx1_QTY_R < 0 ~ "M"
      ),
    # tx2 Type (Sale, Return, Mixed)
    tx2_type =
      case_when(
        tx2_QTY_S > 0 & tx2_QTY_R == 0 ~ "S",
        tx2_QTY_S == 0 & tx2_QTY_R < 0 ~ "R",
        tx2_QTY_S > 0 & tx2_QTY_R < 0 ~ "M"
      )
  )
  ]

cpf(C.0, MailStatusTypeCode, EmailStatusTypeCode)

cpf(C.0, tx1_type, tx2_type)
table(C.0$tx2_type, useNA = "ifany")

cpf(C.0, inUS > 0)


