

#' \strong{S}ummary \strong{S}tatistics Table
#'
#' Produce a compact table of summary statistics for all or specified numeric variables in a dataframe.
#'
#' @param data A dataframe.
#' @param ... Bare names of numeric variables to summarize (NSE); if empty will summarize all numeric columns in \code{data}.
#' @param .dots Quoted names of numeric variables to summarize (SE).
#' @param funs List of summary functions (each must have a signature with first argument being a numeric vector and including a named \code{na.rm} argument).
#' @param na.rm Logical, whether to omit \code{NA} values from vectors when computing summary functions.
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
  funs = list(
    "Min" = min,
    "Ptile10" = function(x, na.rm = FALSE) deciles(x)[2],
    "Mean" = mean,
    "Median" = median,
    "Ptile90" = function(x, na.rm = FALSE) deciles(x)[10],
    "Max" = max,
    "SD" = sd,
    "CV" = function(x, na.rm = FALSE) sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
  ),
  na.rm = TRUE,
  kable = FALSE,
  digits = 2,
  plot = FALSE
) {

  .dots <- lazyeval::all_dots(.dots, ..., all_named = TRUE)

  #///handle data.tables?
  #data <- as.data.frame(data, stringsAsFactors = FALSE)

  # Select requested columns if specified -- otherwise will use all numeric columns in data
  if (length(.dots) > 0) data <- data[, names(.dots)]

  # Get indices of numeric columns - only type funs apply to
  numerics <- which(vapply(data, is.numeric, logical(1)))

  tbl <- tibble::tibble()
  for(i in seq_along(numerics)) {
    summaries <- tibble::as_tibble(lapply(funs, function(f) f(data[, numerics[i]], na.rm = na.rm)))
    names(summaries) <- names(funs)
    tbl <- dplyr::bind_rows(tbl, summaries)
  }

  # Apply rounding
  tbl <- round(tbl, digits)

  # Add variable column at left of summary table
  tbl$Var <- names(data)[numerics]
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
  funs = list(
    "Min" = min,
    "Ptile10" = function(x, na.rm = FALSE) deciles(x)[2],
    "Mean" = mean,
    "Median" = median,
    "Ptile90" = function(x, na.rm = FALSE) deciles(x)[10],
    "Max" = max,
    "SD" = sd,
    "CV" = function(x, na.rm = FALSE) sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
  ),
  na.rm = TRUE,
  kable = FALSE,
  digits = 2,
  plot = FALSE
) {
  ss_(data, .dots = lazyeval::lazy_dots(...), funs = funs, na.rm = na.rm, kable = kable, digits = digits, plot = plot)
}


