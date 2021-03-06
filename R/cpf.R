
#' \strong{C}umulative \strong{P}ercentile \strong{F}requency Table
#'
#' \code{cpf} produces a frequency table by the specified variables, which should be categorical and of relatively low cardinality.
#'
#' \code{has} is a wrapper around \code{cpf} for the common pattern of counting the number of \code{NA} and non-\code{NA} values in each specified variable. It is equivalent to \code{cpf(data, !is.na(x), !is.na(y), ...)}.
#'
#' @param data A dataframe.
#' @param ... Variable names defining table groupings.
#' @param .dots Vector of variable names defining table groupings.
#' @param wt (Optional, character) variable name to use for weighting frequencies.
#' @param sort Logical, whether to sort table in descending frequency. Setting to \code{FALSE} will sort table alphabetically by grouping variables.
#' @param margin Logical, whether to add total row to end of table.
#' @param chi_square Logical, whether to print chi-square test (has no effect on one-dimensional tables).
#' @param kable Logical, whether to format table for Rmarkdown.
#'
#' @return A dataframe or \code{kable}.
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#' data(mtcars)
#' cpf(mtcars, cyl, gear)
cpf_ <- function(data, ..., .dots, wt = NULL, sort = TRUE, margin = TRUE, chi_square = FALSE, kable = FALSE) {

  .dots <- lazyeval::all_dots(.dots, ..., all_named = TRUE)

  if (!is.null(wt)) wt <- as.name(wt)

  tbl.0 <-
    data %>%
    tibble::as_tibble() %>%
    # This handles a character "wt" -- otherwise for bare variable need to pass substitute(wt)
    dplyr::count_(vars = .dots, wt = wt, sort = sort)

  tot <- tibble::tibble(n = sum(tbl.0$n, na.rm = TRUE))
  tot$pct <- tot$n / tot$n

  tbl <-
    tbl.0 %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      cumsum = cumsum(n),
      pct = n / tot$n,
      cumpct = cumsum(pct)
    )

  if (margin)
    tbl <- dplyr::bind_rows(tbl, tot)

  tbl <-
    tbl %>%
    dplyr::mutate(
      n = formattable::comma(n, digits = 0),
      cumsum = formattable::comma(cumsum, digits = 0),
      pct = formattable::percent(pct, digits = 0),
      cumpct = formattable::percent(cumpct, digits = 0)
    )

  if (margin)
    tbl[nrow(tbl), names(.dots)] <- "===="

  # Perform chi-square test
  if (chi_square && length(.dots) > 1) {
    xtbl <- summary(xtabs(n~., data = tbl.0, na.action = na.pass, exclude = NULL))
    cat("Test for independence of all factors:\n")
    ch <- xtbl$statistic
    cat("\tChisq = ", format(round(ch, max(0, 1 - log10(ch)))),
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
cpf <- function(data, ..., wt = NULL, sort = TRUE, margin = TRUE, chi_square = FALSE, kable = FALSE) {
  cpf_(data, .dots = lazyeval::lazy_dots(...), wt = wt, sort = sort, margin = margin, chi_square = chi_square, kable = kable)
}


#' @rdname cpf_
#' @export
has <- function(data, ..., wt = NULL, sort = TRUE, margin = TRUE, chi_square = FALSE, kable = FALSE) {
  has_(data, .dots = lazyeval::lazy_dots(...), wt = wt, sort = sort, margin = margin, chi_square = chi_square, kable = kable)
}


#' @rdname cpf_
#' @export
has_ <- function(data, ..., .dots, wt = NULL, sort = TRUE, margin = TRUE, chi_square = FALSE, kable = FALSE) {

  .dots <- lazyeval::all_dots(.dots, ..., all_named = TRUE)

  new_f <- paste0("!is.na(",names(.dots),")")
  names(new_f) <- paste0("has_", names(.dots))

  cpf_(data, .dots = new_f, wt = wt, sort = sort, margin = margin, chi_square = chi_square, kable = kable)
}
