# Key Exploration ####

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
        n_uniques = first(h_label),
        n = sum(n, na.rm = TRUE),
        pct = sum(pct, na.rm = TRUE)
      ) %>%
      select(-h)
  }

  if (plot && max(unique(temp$unique_ys)) > 1) plot(factor(temp$unique_ys), temp$n_xs)
  #if (plot) print(ggplot2::ggplot(data = temp, ggplot2::aes(x = factor(n_uniques), y = n)) + ggplot2::geom_bar(stat = "identity"))

  if (kable) knitr::kable(temp) #///todo: pass ... to kable's col.names parameter
  else temp
}



# At what level (combination of dimensions) are records unique in df?
# Returns, for each combination of dimensions, df with the number of non-unique cases (i.e., cases that share the same values of the key variables with one or more other cases)
#' @export
#' @importFrom magrittr %>%
findDataLevel <- function(data, ..., max_comb = 3, topn = 25) {
  findDataLevel_(data, .dots = lazyeval::lazy_dots(...), max_comb = max_comb, topn = topn)
}


#' @export
#' @importFrom magrittr %>%
findDataLevel_ <- function(data, ..., .dots, max_comb = 3, topn = 25) {
  dots <- lazyeval::all_dots(.dots, ...)
  dims <- as.character(lapply(dots, function(x) x$expr))
  if (length(dims) == 0) dims <- names(data)
  stopifnot(length(dims) >= max_comb && max_comb > 0)

  results <- data.frame(stringsAsFactors = FALSE)
  for (i in 1:max_comb) {
    m <- combn(dims, i)
    for (col in 1:ncol(m)) {
      #dups <- nrow(data) - nrow(unique(data[, m[, col]])) #same as below
      dups <- sum(duplicated(data[, m[, col]]))
      results <- bind_rows(
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
#findDataLevel(data, First.Name, Last.Name, Email, City, max_comb = 2)
#View(findDataLevel(data, max_comb = 3))



#' Deciles and icosatiles
#'
#' @param x Numeric vector
#'
#' @return Numeric vector of specified quantiles.
#' @export
#'
#' @examples
#' data(mtcars)
#' deciles(mtcars$hp)
#' icosatiles(mtcars$disp)
deciles <- function(x) {
  quantile(x, seq(0, 1, .1))
}


#' @export
#' @importFrom magrittr %>%
#' @rdname deciles
icosatiles <- function(x) {
  quantile(x, seq(0, 1, .05))
}




#' @export
#' @importFrom magrittr %>%
getRecordLayout <- function(data, csv_path = NULL) {

  fieldProperties <- function(x, nm) {
    modalValue <-
      data.frame(x = trimws(paste(x)), stringsAsFactors = FALSE) %>%
      dplyr::filter(x != "") %>%
      dplyr::group_by(x) %>%
      dplyr::summarize(n = n()) %>%
      dplyr::ungroup() %>%
      dplyr::top_n(1, n) %>%
      dplyr::slice(1)
    data.frame(
      field = nm,
      type = paste(class(x)),
      modalValue = modalValue[["x"]],
      stringsAsFactors = FALSE
    )
  }

  props <- Map(fieldProperties, x = data, nm = names(data))
  temp <- data.frame()
  for(i in seq_along(props)) temp <- bind_rows(temp, props[[i]])

  if (!is.null(csv_path)) write.csv(temp, csv_path, row.names = FALSE)
  invisible(temp)

}


#' @export
# Summary function: paste unique values
punq <- function(x, missing_values = c("", NA), sep = "|") {
  x_char <- as.character(x)
  # Remove missing values
  x_char <- x_char[!(x_char %in% missing_values)]
  trimws(paste(unique(x_char), collapse = sep))
}
# punq(c(1, 1, NA))
# punq(c(TRUE, TRUE, NA))
# punq(c(1, 2, 3, 3, NA))
# punq(sh.CTP.0$Shipping.Method)
# punq(sh.CTP.0[1:500, ]$Created.at)


# Summary function: num unique values
#' @export
lunq <- function(x, missing_values = c("", NA)) {
  x_char <- as.character(x)
  # Remove missing values
  x_char <- x_char[!(x_char %in% missing_values)]
  length(unique(x_char))
}
# lunq(c(1, 1, NA))
# lunq(c(TRUE, TRUE, NA))
# lunq(c(1, 2, 3, 3, NA))
# lunq(sh.CTP.0$Shipping.Method)
# lunq(sh.CTP.0[1:500, ]$Created.at)



#' @rdname dup_
#' @export
dup <- function(data, ..., verbose = FALSE) {
  dup_(data, .dots = lazyeval::lazy_dots(...), verbose = verbose)
}


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




#' @rdname cpf_
#' @export
cpf <- function(data, ..., wt = NULL, sort = TRUE, kable = FALSE) {
  cpf_(data, .dots = lazyeval::lazy_dots(...), wt = wt, sort = sort, kable = kable)
}


#' Cumulative Percentile/Frequency Table
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
  else tbl
}







#' Standard cleaning of merge keys
#'
#' Removes all characters from \code{key} \emph{except} for alphanumerics, (internal) space, dash, and underscore. Result is trimmed of leading/trailing white space and converted to uppercase.
#' Use \code{also_drop} to provide a regex pattern specifying any additional patterns to be dropped. This rule is applied prior to \code{to_na}.
#'
#' @param key Vector of keys to clean; coerced to character.
#' @param also_drop Regex pattern specifying additional values to be dropped. Applied piror to \code{to_na}.
#' @param to_na Character vector of values to convert to \code{NA}.
#'
#' @return Character vector, a modified version of \code{key}.
#' @export
cleanKey <- function(key, also_drop = NULL, to_na = "") {
  key_clean <- as.character(key)
  if (!is.null(also_drop))
    key_clean <- gsub(also_drop, "", key_clean)
  key_clean <- trimws(gsub("[^A-Z0-9 -_]", "", toupper(key_clean)))
  if (!is.null(to_na))
    key_clean <- ifelse(grepl(to_na, key_clean, ignore.case = TRUE, perl = TRUE), NA, key_clean)
  key_clean
}




