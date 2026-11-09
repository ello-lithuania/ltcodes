\name{personal_code_birth_date}
\alias{personal_code_birth_date}
\title{Read the birth date from Lithuanian personal codes}
\usage{
personal_code_birth_date(x)
}
\arguments{
\item{x}{A character vector of personal codes.}
}
\value{
A \code{Date} vector of the same length as \code{x}, with \code{NA} where a code holds no valid date.
}
\description{
Reads the date stored in the second to seventh digits. The check digit is not tested.
}
\examples{
personal_code_birth_date("33309240064")
}
