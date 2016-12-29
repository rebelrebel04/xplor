
#' Check data frame for duplicates by index(es).
#'
#' @param .data The data frame to check for duplicate cases, where duplication is specific to the variables listed in \code{...}.
#' @param ... Bare variable names whose values are to be checked for duplication.
#' @param .dots Quoted variable names whose values are to be checked for duplication.
#' @param verbose If \code{TRUE}, will print all duplicated cases in \code{data}.
#'
#' @return Invisible dataframe of duplicated cases.
#' @export
#' @examples
#' d = data.frame(x = rep(1:10, 2), y = rep(1:5, 4), z = 1:20, a = c(1:15, 1:5))
#' dup(d, y, a, verbose = T)
#'
#' #SE version
#' dup_(d, .dots = c("y", "a"))
#'
#' @export
#' @importFrom magrittr %>%
dup_ <- function(data, ..., .dots, verbose = FALSE) {
  .dots = lazyeval::all_dots(.dots, ...)
  d <- data.frame(lazyeval::lazy_eval(.dots, data), stringsAsFactors = FALSE)
  dups <- duplicated(d, fromLast = FALSE)
  print(table(dups))

  dupsLast <- duplicated(d, fromLast = TRUE)
  dupRows <- dups | dupsLast
  dups.df <- dplyr::arrange_(data[dupRows, ], .dots = .dots)
  if (verbose) print(dups.df)

  invisible(dups.df)
}



#' @rdname dup_
#' @export
dup <- function(data, ..., verbose = FALSE) {
  dup_(data, .dots = lazyeval::lazy_dots(...), verbose = verbose)
}
