
#' Check dataframe for duplicate keys
#'
#' @param .data The dataframe to check for duplicate cases, where duplication is specific to the variables listed in \code{...}.
#' @param ... Variable names whose values are to be checked for duplication.
#' @param .dots Quoted variable names whose values are to be checked for duplication.
#' @param wt Optional weighting variable (as character) used to weight duplication rate diagnostics.
#' @param kable Logical, whether to format table for Rmarkdown.
#'
#' @return Invisible dataframe of duplicated cases.
#' @export
#' @examples
#' d = data.frame(x = rep(1:10, 2), y = rep(1:5, 4), z = 1:20, a = c(1:15, 1:5))
#' dup(d, y, a)
#'
#' #SE version
#' dup_(d, .dots = c("y", "a"))
#'
#' @export
#' @importFrom magrittr %>%
dup_ <- function(data, ..., .dots, wt = NULL, kable = TRUE) {

  .dots = lazyeval::all_dots(.dots, ...)

  d <-
    data %>%
    dplyr::group_by_(.dots = .dots) %>%
    dplyr::mutate(
      .n = n(),
      .isUnique = .n == 1
    ) %>%
    dplyr::ungroup()

  # Print duplication rate table
  print(cpf(d, isUnique = .isUnique, wt = wt, kable = kable))

  # Return duplicated rows
  d %>%
    dplyr::filter(!.isUnique) %>%
    dplyr::arrange_("desc(.n)", .dots = .dots) %>%
    dplyr::select(-.isUnique) %>%
    invisible()

}



#' @rdname dup_
#' @export
dup <- function(data, ..., wt = NULL, kable = TRUE) {
  dup_(data, .dots = lazyeval::lazy_dots(...), wt = wt, kable = kable)
}
