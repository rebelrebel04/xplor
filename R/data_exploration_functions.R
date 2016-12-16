# Key Exploration ####

# Is mapping between values of x and values of y 1:1?
# Returns distribution of x:y mappings, i.e. number of unique y values for each unique x value
mapping <- function(f, data, max_rows = 10, na.rm = FALSE, plot = FALSE) {
  
  #if (na.rm) temp <- filter(temp, !is.na(as.name(f[[2]])) & !is.na(f[[3]]))
  
  temp <- 
    data %>%
    group_by_(.dots = paste(f[[2]])) %>% 
    summarize_(
      .dots = setNames(
        lazyeval::interp("length(unique(y))", y = as.name(f[[3]])),
        "n_uniques"
      )
    ) %>% 
    ungroup() %>% 
    count(n_uniques) %>% 
    mutate(
      n_uniques = formattable::comma(n_uniques, digits = 0),
      n = formattable::comma(n, digits = 0),
      pct = formattable::percent(n / sum(n, na.rm = TRUE), digits = 0)
    )
  
  if (!is.null(max_rows)) {
    temp <-
      temp %>%
      mutate(
        i = 1:n(),
        h = ifelse(i < max_rows, i, max_rows),
        h_label = ifelse(i < max_rows, paste(i), paste0(max_rows,"+"))
      ) %>% 
      group_by(h) %>% 
      summarize(
        n_uniques = first(h_label),
        n = sum(n, na.rm = TRUE),
        pct = sum(pct, na.rm = TRUE)
      ) %>% 
      ungroup() %>% 
      select(-h)
  }
  
  if (plot && max(unique(temp$n_uniques)) > 1) plot(factor(temp$n_uniques), temp$n)
  #if (plot) print(ggplot2::ggplot(data = temp, ggplot2::aes(x = factor(n_uniques), y = n)) + ggplot2::geom_bar(stat = "identity"))
  temp
}
#mapping(Order ~ Name, trans.1)
#mapping(Order ~ Created.At, trans.1)




# At what level (combination of dimensions) are records unique in df?
# Returns, for each combination of dimensions, df with the number of non-unique cases (i.e., cases that share the same values of the key variables with one or more other cases)
findDataLevel <- function(data, ..., max_comb = 3, topn = 25) {
  findDataLevel_(data, .dots = lazyeval::lazy_dots(...), max_comb = max_comb, topn = topn)
}
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



deciles <- function(x) {
  quantile(x, seq(0, 1, .1))
}




getRecordLayout <- function(data, csv_path = NULL) {
  
  fieldProperties <- function(x, nm) {
    modalValue <- 
      data.frame(x = trimws(paste(x)), stringsAsFactors = FALSE) %>% 
      filter(x != "") %>% 
      group_by(x) %>% 
      summarize(n = n()) %>% 
      ungroup() %>% 
      top_n(1, n) %>% 
      slice(1)
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




#' Check data frame for duplicates by index(es).
#'
#' @param .data The data frame to check for duplicate cases, where duplication is specific to the variables listed in \code{...}.
#' @param ... The variables whose values are to be checked for duplication.
#' @param verbose If \code{TRUE}, will print all duplicated cases in \code{.data}.
#'
#' @return Invisible dataframe of duplicated cases.
#' @export
#' @examples
#' d = data.frame(x = rep(1:10, 2), y = rep(1:5, 4), z = 1:20, a = c(1:15, 1:5))
#' dup(d, y, a, verbose = T)
#'
#' #SE version
#' dup_(d, "y", "a")
dup <- function(data, ..., verbose = FALSE) {
  dup_(data, .dots = lazyeval::lazy_dots(...), verbose = verbose)
}
#' @rdname dup
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



ptab <- function(..., useNA = "ifany", margins = TRUE) {
  tbl <- table(..., useNA = useNA)
  ptbl <- round(prop.table(tbl), 2)
  if (margins) tbl <- addmargins(tbl)
  print(tbl); print(ptbl)
  invisible(tbl)
}
#ptab(temp2$dim_transactionType)



#///todo: add weight parameter
cpf <- function(data, ..., sort = TRUE) {
  tbl <- 
    data %>%
    dplyr::group_by(...) %>% 
    dplyr::summarize(
      n = n()
    ) %>%
    dplyr::ungroup()
  tot <-
    data %>%
    dplyr::summarize(
      n = n(),
      pct = n / nrow(data)
    )
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
  tbl
}
#cpf(temp2, flag_straightPurchase, flag_straightExchange)


