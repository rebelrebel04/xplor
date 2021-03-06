% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{cutQuantile}
\alias{cutQuantile}
\title{Convert Numeric to Quantile-Split Factor}
\usage{
cutQuantile(x, quantiles, labels = paste(1:quantiles), na.rm = FALSE,
  type = 7)
}
\arguments{
\item{x}{Numeric vector which is to be converted to a factor by splitting into quantiles.}

\item{quantiles}{Integer number of quantiles desired (3 = tertiles, 4 = quartiles, etc.).}

\item{labels}{Character vector of labels for the levels of the resulting category. By default, labels are constructed by converting the quantile integer codes to a character vector. If labels = FALSE, simple integer codes are returned instead of a factor.}

\item{na.rm}{Logical, if \code{TRUE} any \code{NA} and \code{NaN}s are removed from \code{x} before the quantiles are computed.}
}
\value{
A \code{factor} is returned, unless \code{labels = FALSE} which results in an integer vector of level codes.
}
\description{
Convert Numeric to Quantile-Split Factor
}
\examples{
table(cutQuantile(1:100, 4))
}
