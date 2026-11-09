\name{is_iban}
\alias{is_iban}
\title{Test Lithuanian IBANs}
\usage{
is_iban(x)
}
\arguments{
\item{x}{A character vector of account numbers.}
}
\value{
A logical vector of the same length as \code{x}; \code{NA} input gives \code{NA}.
}
\description{
A Lithuanian IBAN has 20 characters, starts with \code{LT} and passes the MOD-97 rule.
}
\examples{
is_iban(c("LT121000011101001000", "LT121000011101001001"))
}
