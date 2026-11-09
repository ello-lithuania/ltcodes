\name{personal_code_sex}
\alias{personal_code_sex}
\title{Read the sex from Lithuanian personal codes}
\usage{
personal_code_sex(x)
}
\arguments{
\item{x}{A character vector of personal codes.}
}
\value{
A character vector with \code{"M"} for first digits 1, 3 and 5, \code{"F"} for 2, 4 and 6, and \code{NA} otherwise.
}
\description{
Reads the sex stored in the first digit.
}
\examples{
personal_code_sex("33309240064")
}
