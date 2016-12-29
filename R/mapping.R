
#' Mapping of x onto y
#'
#' This function returns the distribution of \eqn{x -> y}, i.e., the number of unique \code{y} values within each unique \code{x} value.
#'
#' @param f Formula, \code{x ~ y}
#' @param data Dataframe containing \code{x} and \code{y}.
#' @param max_rows Maximum number of rows to print (set to \code{NULL} to print all rows).
#' @param na.rm Logical, if \code{TRUE} will remove \code{NA} values from \code{x, y}.
#' @param plot Logical, if \code{TRUE} will print a bar chart of mapping.
#' @param kable Logical, if \code{TRUE} will print table as a \code{kable} for RMarkdown rendering.
#'
#' @return A dataframe summarizing the mapping, in \code{knitr::kable} format if \code{kable = TRUE}. Note that \code{plot} produces a plot as a side-effect.
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#' data(mtcars)
#' mapping(mpg ~ cyl, mtcars)
mapping <- function(f, data, max_rows = 10, na.rm = FALSE, plot = FALSE, kable = FALSE) {

  x <- paste(f[[2]])
  y <- paste(f[[3]])

  temp <- data[, c(x, y)]
  if (na.rm) temp <- na.omit(temp)

  temp <-
    temp %>%
    dplyr::group_by_(.dots = x) %>%
    dplyr::summarize_(
      .dots = setNames(
        lazyeval::interp("length(unique(y))", y = as.name(y)),
        "unique_ys"
      )
    ) %>%
    dplyr::count(unique_ys) %>%
    dplyr::rename(n_xs = n) %>%
    dplyr::mutate(
      unique_ys = formattable::comma(unique_ys, digits = 0),
      n_xs = formattable::comma(n_xs, digits = 0),
      pct_xs = formattable::percent(n_xs / sum(n_xs, na.rm = TRUE), digits = 0)
    )

  if (!is.null(max_rows)) {
    temp <-
      temp %>%
      dplyr::mutate(
        i = 1:n(),
        h = ifelse(i < max_rows, i, max_rows),
        h_label = ifelse(i < max_rows, paste(i), paste0(max_rows,"+"))
      ) %>%
      dplyr::group_by(h) %>%
      dplyr::summarize(
        unique_ys = dplyr::first(h_label),
        n_xs = sum(n_xs, na.rm = TRUE),
        pct_xs = sum(pct_xs, na.rm = TRUE)
      ) %>%
      dplyr::select(-h)
  }

  if (plot && max(unique(temp$unique_ys)) > 1) plot(factor(temp$unique_ys), temp$n_xs)
  #if (plot) print(ggplot2::ggplot(data = temp, ggplot2::aes(x = factor(n_uniques), y = n)) + ggplot2::geom_bar(stat = "identity"))

  if (kable) knitr::kable(temp) #///todo: pass ... to kable's col.names parameter
  else as.data.frame(temp, stringsAsFactors = FALSE)
}

