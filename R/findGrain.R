
#' Find Data Grain
#'
#' This function attempts to answer the question: At what grain (combination of dimensions) are records in a dataframe unique?
#' It searches over all combinations of candidate dimensions (specified via \code{...} or \code{.dots}), up to combinations of size \code{max_comb}, and returns a list of the combinations ranked according to maximum de-duplication of the table.
#'
#' @param data A dataframe.
#' @param ... Bare variable names of candidate dimensions to test for defining the grain of \code{data}.
#' @param .dots Quoted variable names of candidate dimensions.
#' @param max_comb Maximum number of candidate dimensions to combine for testing grain.
#' @param topn Number of top combinations to report in results.
#'
#' @return A dataframe with, for each combination of dimensions, the number of duplicate cases (i.e., cases that share the same values of the key variables with one or more other cases). Ideally, if the true grain of the table were found, there would be 0 duplicates.
#' @export
#'
#' @examples
#' data(mtcars)
#' findGrain(mtcars, gear, cyl, carb)
findGrain_ <- function(data, ..., .dots, max_comb = 3, topn = 25) {
  dots <- lazyeval::all_dots(.dots, ...)
  dims <- as.character(lapply(dots, function(x) x$expr))
  if (length(dims) == 0) dims <- names(data)
  if (max_comb > length(dims)) max_comb <- length(dims)
  stopifnot(length(dims) >= max_comb && max_comb > 0)

  results <- data.frame(stringsAsFactors = FALSE)
  for (i in 1:max_comb) {
    m <- combn(dims, i)
    for (col in 1:ncol(m)) {
      #dups <- nrow(data) - nrow(unique(data[, m[, col]])) #same as below
      dups <- sum(duplicated(data[, m[, col]]))
      results <- dplyr::bind_rows(
        results,
        data.frame(
          n_keys = i,
          keys = paste(m[, col], collapse = " * "),
          duplicates = dups,
          stringsAsFactors = FALSE
        )
      )
    }
  }

  print(head(dplyr::arrange(results, duplicates, n_keys), topn))
  invisible(results)
}



#' @rdname findGrain_
#' @export
findGrain <- function(data, ..., max_comb = 3, topn = 25) {
  findGrain_(data, .dots = lazyeval::lazy_dots(...), max_comb = max_comb, topn = topn)
}

