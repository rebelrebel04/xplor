
#' \strong{C}umulative \strong{P}ercentile \strong{F}requency Table
#'
#' @param data A dataframe.
#' @param ... Bare variable names defining table groupings.
#' @param .dots Quoted variable names defining table groupings.
#' @param wt (Optional) quoted variable name to use for weighting frequencies.
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
cpf_ <- function(data, ..., .dots, wt = NULL, sort = TRUE, kable = FALSE) {

  #if ("n" %in% names(data)) stop("Dataset cannot contain a variable named 'n'")

  .dots <- lazyeval::all_dots(.dots, ..., all_named = TRUE)

  tbl <-
    data %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    dplyr::mutate(
      one = 1
    )

  if (is.null(wt)) wt <- "one"

  tbl <-
    tbl %>%
    dplyr::group_by_(.dots = .dots) %>%
    dplyr::summarize_(
      .dots = setNames(
        lazyeval::interp("sum(wt, na.rm = TRUE)", wt = as.name(wt)),
        "n"
      )
    )

  # tbl <-
  #   data %>%
  #   #//// need to convert data.table here? as.tibble()...
  #   # This version handles a character "wt" -- otherwise for bare variable need to pass substitute(wt)
  #   dplyr::count_(vars = .dots, wt = as.name(wt), sort = sort)

  if (sort) tbl <- dplyr::arrange(tbl, dplyr::desc(n))

  tot <- tibble::tibble(n = sum(tbl$n, na.rm = TRUE))
  tot$pct <- tot$n / tot$n

  tbl$cumsum <- cumsum(tbl$n)
  tbl$pct <- tbl$n / tot$n
  tbl$cumpct <- cumsum(tbl$pct)

  tbl <-
    dplyr::bind_rows(tbl, tot) %>%
    dplyr::mutate(
      n = formattable::comma(n, digits = 0),
      cumsum = formattable::comma(cumsum, digits = 0),
      pct = formattable::percent(pct, digits = 0),
      cumpct = formattable::percent(cumpct, digits = 0)
    )
  tbl[nrow(tbl), names(.dots)] <- "===="

  if (kable) knitr::kable(tbl) #///todo: pass ... to kable's col.names parameter
  else as.data.frame(tbl, stringsAsFactor = FALSE)
}



#' @rdname cpf_
#' @export
cpf <- function(data, ..., wt = NULL, sort = TRUE, kable = FALSE) {
  cpf_(data, .dots = lazyeval::lazy_dots(...), wt = wt, sort = sort, kable = kable)
}



