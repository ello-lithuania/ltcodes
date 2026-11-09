\name{is_company_code}
\alias{is_company_code}
\title{Test Lithuanian company codes}
\usage{
is_company_code(x)
}
\arguments{
\item{x}{A character vector of codes.}
}
\value{
A logical vector of the same length as \code{x}; \code{NA} input gives \code{NA}.
}
\description{
A company code has nine digits and ends in a check digit.
}
\examples{
is_company_code(c("123033512", "123033513"))
}
