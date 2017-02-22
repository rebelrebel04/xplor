

#' \strong{S}ummary \strong{S}tatistics Table
#'
#' Produce a compact table of summary statistics for all or specified numeric variables in a dataframe.
#'
#' @param data A dataframe.
#' @param ... Bare names of numeric variables to summarize (NSE); if empty will summarize all numeric columns in \code{data}.
#' @param .dots Quoted names of numeric variables to summarize (SE).
#' @param funs List of summary functions (each must have a signature with first argument being a numeric vector and including a named \code{na.rm} argument).
#' @param kable Logical, whether to return a \code{kable} for rendering in Rmarkdown.
#' @param digits Number of digits to print after decimal.
#' @param plot Logical, whether to plot (as a side-effect) a facet-wrapped set of histograms for all summarized variables.
#'
#' @return A data.frame or kable object containing the table of summary statistics.
#' @export
#' @importFrom magrittr %>%
ss_ <- function(
  data,
  ...,
  .dots,
  funs = summary_funs(),
  kable = FALSE,
  digits = 2,
  plot = FALSE
) {

  .dots <- lazyeval::all_dots(.dots, ..., all_named = TRUE)

  # convert data.tables
  data <- as.data.frame(data, stringsAsFactors = FALSE)

  # Select requested columns if specified -- otherwise will use all numeric columns in data
  if (length(.dots) > 0) {
    data <- as.data.frame(data[, names(.dots)])
    names(data) <- names(.dots)
  }

  # Get indices of numeric columns - only type funs apply to
  numerics <- which(vapply(data, is.numeric, logical(1)))

  tbl <- tibble::tibble()
  for(i in seq_along(numerics)) {
    summaries <- tibble::as_tibble(lapply(funs, function(f) f(data[, numerics[i]], na.rm = TRUE)))
    names(summaries) <- names(funs)
    tbl <- dplyr::bind_rows(tbl, summaries)
  }

  # Apply rounding
  tbl <- round(tbl, digits)

  # Add variable column at left of summary table
  tbl$Variable <- names(data)[numerics]
  tbl <- dplyr::bind_cols(tbl[, ncol(tbl)], tbl[, -ncol(tbl)])

  if (plot) {
    p <-
      data[, numerics] %>%
      reshape2::melt(id.vars = NULL) %>%
      ggplot2::ggplot(ggplot2::aes(x = value)) +
      ggplot2::geom_histogram(bins = 30) +
      ggplot2::xlab("") + ggplot2::ylab("") +
      ggplot2::facet_wrap(~variable, scales = "free")
    plot(p)
  }

  if (kable) knitr::kable(tbl, digits = digits)
  else as.data.frame(tbl, stringsAsFactors = FALSE)

}



#' @rdname ss_
#' @export
ss <- function(
  data,
  ...,
  funs = summary_funs(),
  kable = FALSE,
  digits = 2,
  plot = FALSE
) {
  ss_(data, .dots = lazyeval::lazy_dots(...), funs = funs, kable = kable, digits = digits, plot = plot)
}



summary_funs <- function() {
  list(
    "Min" = min,
    "P10" = function(x, ...) deciles(x, na.rm = TRUE)[2],
    "Mean" = mean,
    "Median" = median,
    "P90" = function(x, ...) deciles(x, na.rm = TRUE)[10],
    "Max" = max,
    "SD" = sd,
    "CV" = function(x, ...) sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE),
    "NAs" = function(x, ...) sum(is.na(x))
  )
}
