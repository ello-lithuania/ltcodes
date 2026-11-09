\name{is_personal_code}
\alias{is_personal_code}
\title{Test Lithuanian personal codes}
\usage{
is_personal_code(x)
}
\arguments{
\item{x}{A character vector of codes.}
}
\value{
A logical vector of the same length as \code{x}; \code{NA} input gives \code{NA}.
}
\description{
A personal code has 11 digits: the first gives the century and sex, the next six the birth date, and the last is a check digit. Codes that start with 9 carry no date, so only the check digit is tested.
}
\examples{
is_personal_code(c("33309240064", "33309240164"))
}
