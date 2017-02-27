

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




