
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

  .dots <- lazyeval::all_dots(.dots, ..., all_named = TRUE)

  tbl <-
    data %>%
    as.data.frame() %>%              #/// this is a hack right now to make cpf work with a data.table; should rewrite cpf to use data.table by default (converting data to data.table)
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

  tot <- data.frame(n = sum(tbl$n, na.rm = TRUE))
  tot$pct <- tot$n / tot$n

  if (sort) tbl <- dplyr::arrange(tbl, dplyr::desc(n))

  tbl$cumsum <- cumsum(tbl$n)
  tbl$pct <- tbl$n / sum(tbl$n, na.rm = TRUE)
  tbl$cumpct <- cumsum(tbl$pct)

  tbl <-
    dplyr::bind_rows(tbl, tot) %>%
    dplyr::mutate(
      n = formattable::comma(n, digits = 0),
      cumsum = formattable::comma(cumsum, digits = 0),
      pct = formattable::percent(pct, digits = 0),
      cumpct = formattable::percent(cumpct, digits = 0)
    )
  tbl[nrow(tbl), names(tbl)[!(names(tbl) %in% c("n","pct","cumsum","cumpct"))]] <- "===="
  if (kable) knitr::kable(tbl) #///todo: pass ... to kable's col.names parameter
  else as.data.frame(tbl, stringsAsFactor = FALSE)
}



#' @rdname cpf_
#' @export
cpf <- function(data, ..., wt = NULL, sort = TRUE, kable = FALSE) {
  cpf_(data, .dots = lazyeval::lazy_dots(...), wt = wt, sort = sort, kable = kable)
}



