

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

  # convert data.tables?
  # data <- as.data.frame(data, stringsAsFactors = FALSE)

  # Select requested columns if specified -- otherwise will use all numeric columns in data
  if (length(.dots) > 0) {
    data <-
      data %>%
      dplyr::select_(.dots = c(unlist(dplyr::groups(data)), names(.dots)))
  }

  # Get indices of numeric columns - only type funs apply to
  numerics <- which(vapply(data, is.numeric, logical(1)))
  # Exclude grouping variables in the event they are of type numeric
  numerics <- numerics[!(numerics %in% which(names(data) %in% unlist(dplyr::groups(data))))]

  tbl <- tibble::tibble()
  for(i in seq_along(numerics)) {
    summaries <-
      data %>%
      # Note: data will carry any group_by attributes here if it was passed in with them
      dplyr::summarize_(
        .dots = setNames(
          lapply(funs, function(f) lazyeval::interp(f, x = as.name(names(data)[numerics[i]]))),
          nm = names(funs)
        )
      )
    tbl <- dplyr::bind_rows(tbl, summaries)
  }

  # Apply rounding
  tbl[, names(funs)] <- round(tbl[, names(funs)], digits)

  # Add grouping and variable columns at left of summary table
  tbl$Variable <- names(data)[numerics]
  tbl <-
    dplyr::bind_cols(
      dplyr::select_(tbl, .dots = c(unlist(dplyr::groups(data)), "Variable")),
      dplyr::select_(tbl, .dots = paste0("-", c(unlist(dplyr::groups(data)), "Variable")))
    ) %>%
    dplyr::arrange_(.dots = c(unlist(dplyr::groups(data))))

  if (plot) {
    p <-
      data[, numerics] %>%
      reshape2::melt(id.vars = NULL) %>%
      ggplot2::ggplot(ggplot2::aes(x = value)) +
      ggplot2::geom_histogram(bins = 30) +
      ggplot2::xlab("") + ggplot2::ylab("") +
      ggplot2::facet_wrap(~variable, scales = "free") +
      ggplot2::theme_bw()
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
    "N" = ~n(),
    "NAs" = ~sum(is.na(x)),
    "Min" = ~min(x, na.rm = TRUE),
    "P10" = ~deciles(x, na.rm = TRUE)[2],
    "Mean" = ~mean(x, na.rm = TRUE),
    "Median" = ~median(x, na.rm = TRUE),
    "P90" = ~deciles(x, na.rm = TRUE)[10],
    "Max" = ~max(x, na.rm = TRUE),
    "SD" = ~sd(x, na.rm = TRUE),
    "CV" = ~sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
  )
}
