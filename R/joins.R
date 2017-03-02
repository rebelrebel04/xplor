

#' Verbose Join
#'
#' Join with diagnostic output. Joins are implemented via \code{dplyr} join functions.
#'
#' @param x,y Dataframes to join.
#' @param by Character vector giving the name(s) of columns to be used for merging.
#' @param join String specifying type of join: valid join types are "inner", "left", "right", "full", "semi" and "anti".
#' @param flag_source Logical, whether to add two variables (\code{.in_x} and \code{.in_y}) flagging source(s) for each case in result.
#' @param ... Additional parameters passed to \code{dplyr} join function.
#' @return Merged data frame.
#' @export
#' @examples
#' x <- data.frame(a = LETTERS[1:10], b = 1:10, stringsAsFactors = F)
#' y <- data.frame(a = LETTERS[6:15], c = 6:15, stringsAsFactors = F)
#' vjoin(x, y, by = "a", join = "full")
vjoin <- function(x, y, by, join = "left", flag_source = FALSE, ...) {

  x_by <- dplyr::select_(x, .dots = by)
  y_by <- dplyr::select_(y, .dots = by)

  inxandy <- nrow(dplyr::intersect(x_by, y_by))
  inxnoty <- nrow(dplyr::setdiff(x_by, y_by))
  inynotx <- nrow(dplyr::setdiff(y_by, x_by))

  unq_x <- nrow(unique(x_by))
  unq_y <- nrow(unique(y_by))

  # Check for duplicates in merge keys -- could create trouble
  dups_x <- nrow(unique(as.data.frame(x_by[duplicated(x_by), ])))
  dups_y <- nrow(unique(as.data.frame(y_by[duplicated(y_by), ])))
  # dups_x <- sum(duplicated(x_by), na.rm = TRUE)
  # dups_y <- sum(duplicated(y_by), na.rm = TRUE)

  xnm <- deparse(substitute(x))
  ynm <- deparse(substitute(y))
  message(xnm," ",toupper(join)," JOIN ",ynm," ON ",paste(by, collapse = ", "))
  message("SET ",xnm,":\t", nrow(x), " obs\t", ncol(x), " variables\t",unq_x," unique keys\t",dups_x," keys with duplicates")
  message("SET ",ynm,":\t", nrow(y), " obs\t", ncol(y), " variables\t",unq_y," unique keys\t",dups_y," keys with duplicates")
  message("IN ",xnm," AND ",ynm,":\t",inxandy)
  message("IN ",xnm," NOT ",ynm,":\t",inxnoty)
  message("IN ",ynm," NOT ",xnm,":\t",inynotx)

  if (flag_source) {
    x[[paste0(".in_",xnm)]] <- TRUE
    y[[paste0(".in_",ynm)]] <- TRUE
  }

  # Perform join
  fn <- get(paste0(join,"_join"), asNamespace("dplyr"))
  m <- do.call(fn, list(x = x, y = y, by = by, ... = ...))

  # Replace NAs with FALSE
  if (flag_source) {
    m[[paste0(".in_",xnm)]] <- ifelse(is.na(m[[paste0(".in_",xnm)]]), FALSE, TRUE)
    m[[paste0(".in_",ynm)]] <- ifelse(is.na(m[[paste0(".in_",ynm)]]), FALSE, TRUE)
  }

  m_by <- dplyr::select_(m, .dots = by)
  unq_m <- nrow(unique(m_by))
  dups_m <- nrow(unique(as.data.frame(m_by[duplicated(m_by), ])))

  message("Result:\t", nrow(m), " obs\t", ncol(m), " variables\t",unq_m," unique keys\t",dups_m," keys with duplicates")
  invisible(m)
}




#' Closest matches by edit distance between all non-matching strings
#'
#' A typical use case is aligning merge keys when key variables may be fuzzy (e.g., merging pagePath to productName).
#'
#' @param x,y Character vectors whose non-identical elements will be compared for closest matches in the other vector.
#' @param collapse String used to separate multiple closest-match key values in the case of ties.
#' @param ignore.case Logical, if \code{TRUE} (default), case is ignored for computing the distances.
#' @return Dataframe listing the closest matches (and corresponding edit distance) for all non-identical elements in \code{x} and \code{y}.
#' @export
closestMatch <- function(x, y, collapse = " // ", ignore.case = T) {

  inXnotY <- setdiff(x, y)
  inYnotX <- setdiff(y, x)
  distMat <- adist(inXnotY, inYnotX)

  rowMins <- apply(distMat, 1, min)
  rowClosests <- t(apply(distMat, 1, function(x) x == min(x)))
  rowMatches <- lapply(sapply(seq_along(1:length(inXnotY)), function(i) inYnotX[rowClosests[i, ]]), function(x) paste0(x, collapse = collapse))

  colMins <- apply(distMat, 2, min)
  colClosests <- apply(distMat, 2, function(x) x == min(x))
  colMatches <- lapply(sapply(seq_along(1:length(inYnotX)), function(i) inXnotY[colClosests[, i]]), function(x) paste0(x, collapse = collapse))

  temp <- data.frame(
    source = c(rep("inXNotY", length(inXnotY)), rep("inYNotX", length(inYnotX))),
    value = c(inXnotY, inYnotX),
    closestMatch = as.character(c(rowMatches, colMatches)),
    distance = c(rowMins, colMins),
    stringsAsFactors = F
  )

}

