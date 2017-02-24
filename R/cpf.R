
#' \strong{C}umulative \strong{P}ercentile \strong{F}requency Table
#'
#' @param data A dataframe.
#' @param ... Variable names defining table groupings.
#' @param .dots Vector of variable names defining table groupings.
#' @param wt (Optional, character) variable name to use for weighting frequencies.
#' @param sort Logical, whether to sort table in descending frequency.
#' @param kable Logical, whether to format table for Rmarkdown.
#'
#' @return A dataframe or \code{kable}.
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#' data(mtcars)
#' cpf(mtcars, cyl, gear)
cpf_ <- function(data, ..., .dots, wt = NULL, sort = TRUE, chi_square = FALSE, kable = FALSE) {

  .dots <- lazyeval::all_dots(.dots, ..., all_named = TRUE)

  if (!is.null(wt)) wt <- as.name(wt)

  tbl.0 <-
    data %>%
    #//// need to convert data.table here? as.tibble()...
    # This handles a character "wt" -- otherwise for bare variable need to pass substitute(wt)
    dplyr::count_(vars = .dots, wt = wt, sort = sort)

  tot <- tibble::tibble(n = sum(tbl.0$n, na.rm = TRUE))
  tot$pct <- tot$n / tot$n

  tbl <-
    tbl.0 %>%
    mutate(
      cumsum = cumsum(n),
      pct = n / tot$n,
      cumpct = cumsum(pct)
    )
  # tbl$cumsum <- cumsum(tbl$n)
  # tbl$pct <- tbl$n / tot$n
  # tbl$cumpct <- cumsum(tbl$pct)

  tbl <-
    dplyr::bind_rows(tbl, tot) %>%
    dplyr::mutate(
      n = formattable::comma(n, digits = 0),
      cumsum = formattable::comma(cumsum, digits = 0),
      pct = formattable::percent(pct, digits = 0),
      cumpct = formattable::percent(cumpct, digits = 0)
    )
  tbl[nrow(tbl), names(.dots)] <- "===="


  # perform chi-square test
  if (chi_square && length(.dots) > 1) {
    xtbl <- summary(xtabs(n~., data = tbl.0, na.action = na.pass, exclude = NULL))
    cat("Test for independence of all factors:\n")
    ch <- xtbl$statistic
    cat("\tChisq = ", format(round(ch, max(0, digits - log10(ch)))),
        ", df = ", xtbl$parameter, ", p-value = ", format.pval(xtbl$p.value,
                                                            digits = 3, eps = 0), "\n", sep = "")
    if (!xtbl$approx.ok)
      cat("\tNote: Chi-square approximation may be incorrect\n")
  }


  if (kable) knitr::kable(tbl) #///todo: pass ... to kable's col.names parameter
  else as.data.frame(tbl, stringsAsFactor = FALSE)
}



#' @rdname cpf_
#' @export
cpf <- function(data, ..., wt = NULL, sort = TRUE, chi_square = FALSE, kable = FALSE) {
  cpf_(data, .dots = lazyeval::lazy_dots(...), wt = wt, sort = sort, chi_square = chi_square, kable = kable)
}



