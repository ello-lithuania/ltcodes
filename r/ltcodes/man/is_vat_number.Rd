\name{is_vat_number}
\alias{is_vat_number}
\title{Test Lithuanian VAT numbers}
\usage{
is_vat_number(x)
}
\arguments{
\item{x}{A character vector of numbers.}
}
\value{
A logical vector of the same length as \code{x}; \code{NA} input gives \code{NA}.
}
\description{
A VAT number has 9 or 12 digits and may start with \code{LT}.
}
\examples{
is_vat_number(c("LT119511515", "LT119511516"))
}
