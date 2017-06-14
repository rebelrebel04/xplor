
#' Convert Numeric to Quantile-Split Factor
#'
#' @param x Numeric vector which is to be converted to a factor by splitting into quantiles.
#' @param quantiles Integer number of quantiles desired (3 = tertiles, 4 = quartiles, etc.).
#' @param labels Character vector of labels for the levels of the resulting category. By default, labels are constructed by converting the quantile integer codes to a character vector. If labels = FALSE, simple integer codes are returned instead of a factor.
#' @param na.rm Logical, if \code{TRUE} any \code{NA} and \code{NaN}s are removed from \code{x} before the quantiles are computed.
#' @inheritParams base::quantile
#' @return A \code{factor} is returned, unless \code{labels = FALSE} which results in an integer vector of level codes.
#' @export
#' @examples
#' table(cutQuantile(1:100, 4))
cutQuantile <- function(x, quantiles, labels = paste(1:quantiles), na.rm = FALSE, type = 7) {
  cut(x, breaks = quantile(x, seq(0, 1, length = quantiles+1), type = type, na.rm = na.rm), include.lowest = TRUE, labels = labels)
}



#' Deciles and icosatiles
#'
#' @param x Numeric vector.
#' @param na.rm Logical, whether to remove \code{NA} values.
#'
#' @return Numeric vector of specified quantiles.
#' @export
deciles <- function(x, na.rm = TRUE) {
  quantile(x, seq(0, 1, .1), na.rm = na.rm)
}


#' @export
#' @importFrom magrittr %>%
#' @rdname deciles
icosatiles <- function(x, na.rm = TRUE) {
  quantile(x, seq(0, 1, .05), na.rm = na.rm)
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
cleanKey <- function(key, also_drop = NULL, to_na = "^$") {
  key_clean <- as.character(key)
  if (!is.null(also_drop))
    key_clean <- gsub(also_drop, "", key_clean)
  key_clean <- trimws(gsub("[^A-Z0-9 -_]", "", toupper(key_clean)))
  if (!is.null(to_na))
    key_clean <- ifelse(grepl(to_na, key_clean, ignore.case = TRUE, perl = TRUE), NA, key_clean)
  key_clean
}






#' Find names in dataframe matching regex pattern
#'
#' @param .data The data frame to search.
#' @param pattern The regex pattern to match against variable names in \code{.data}.
#' @return Character vector of variable names in \code{.data} matching regex \code{pattern}.
#' @export
#' @examples
#' d = data.frame(x1 = runif(10), y2 = runif(10))
#' matchNames(d, "x")
#' d[matchNames(d, "x")]
matchNames <- function(.data, pattern, ignore.case = TRUE) {
  names(.data)[grep(pattern, names(.data), ignore.case = ignore.case)]
}



#///todo: rewrite so this returns the indices of all elements that match any of NA, Inf, or NaN -- more useful this way (e.g., replacing all at once)
# #' Check dataframe for variables with \code{NA}, \code{Inf}, or \code{NaN} values.
# #'
# #' @param .data The data frame to check.
# #' @return \code{summary} of all variables in \code{.data} containing one or more invalid values.
# #' @export
# #' @examples
# #' set.seed(1234)
# #' d = data.frame(w = rnorm(100), x = sample(c(1:10,NA), 100, TRUE), y = c(1:99,Inf), z = c(NaN,2:100), a = sample(LETTERS,100,TRUE))
# #' hasNA(d)
# hasNA <- function(.data) {
#   summary(
#     .data[sapply(.data, function(x) any(is.na(x) | is.infinite(x) | is.nan(x)))]
#   )
# }





# Infix operators ####


#' Concatenation Ignoring NA
#'
#' Infix operators for string concatenation. \code{NA} values are ignored rather than pasted as literals (the default \code{paste} behavior).
#'
#' @inheritParams base::paste0
#' @return A string equal to the concatenation of \code{...}.
#' @export
#' @examples
#' "Timestamp: " %&% Sys.time()
#' c(1,2) %&% c("a","b")
#' "foo" %&% "bar"
#' "foo" %&% NA
#' NA %&% "bar"
#' c("foo",NA) %&% "buzz"
#' c("foo","fizz") % % c("bar","buzz") %_% 1
concat <- function(x, y, sep) {
  paste(
    ifelse(is.na(x), "", x),
    ifelse(is.na(y), "", y),
    sep = ifelse(is.na(x) | is.na(y), "", sep)
  )
}


#' @rdname concat
#' @export
`%&%` <- function(x, y) {
  concat(x, y, "")
}


#' @rdname concat
#' @export
`%_%` <- function(x, y) {
  concat(x, y, "_")
}


#' @rdname concat
#' @export
`% %` <- function(x, y) {
  concat(x, y, " ")
}
