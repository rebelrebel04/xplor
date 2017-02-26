#' Verbose Join
#'
#' Merge with diagnostic output.
#'
#' @param x,y Dataframes to join.
#' @param by Character vector giving the name(s) of columns to be used for merging.
#' @param join String specifying type of join: valid join types are "inner", "left", "right", "full".
#' @return Merged data frame.
#' @export
#' @examples
#' x <- data.frame(a = LETTERS[1:10], b = 1:10, stringsAsFactors = F)
#' y <- data.frame(a = LETTERS[6:15], c = 6:15, stringsAsFactors = F)
#' vjoin(x, y, by = "a", join = "full")
vjoin <- function(x, y, by, join = "left") {
  x_by <- dplyr::select_(x, .dots = by)
  y_by <- dplyr::select_(y, .dots = by)
  in1and2 <- nrow(dplyr::intersect(x_by, y_by))
  in1not2 <- nrow(dplyr::setdiff(x_by, y_by))
  in2not1 <- nrow(dplyr::setdiff(y_by, x_by))
  message("Verbose Join (",join,"):")
  message("|Set 1: ", nrow(x), " obs, ", ncol(x), " variables")
  message("|Set 2: ", nrow(y), " obs, ", ncol(y), " variables")
  message("|In 1 and 2: ", in1and2)
  message("|In 1 not 2: ", in1not2)
  message("|In 2 not 1: ", in2not1)
  d <- switch(
    join,
    inner = merge(x, y, by, all = F),
    left = merge(x, y, by, all.x = T, all.y = F),
    right = merge(x, y, by, all.x = F, all.y = T),
    full = merge(x, y, by, all = T),
    stop(join, " is not a valid type of join in function vjoin.")
  )
  message("|Merged dataset: ", nrow(d), " obs, ", ncol(d), " variables")
  invisible(d)
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

