# The shared check digit rule: weights 1 to 9, then 3 to 9, 1, 2 if the first
# pass gives 10.
check_digit <- function(d) {
  i <- seq_along(d) - 1L
  first <- sum((1L + i %% 9L) * d) %% 11L
  if (first != 10L) {
    return(first)
  }
  (sum((1L + (i + 2L) %% 9L) * d) %% 11L) %% 10L
}

to_digits <- function(s) as.integer(strsplit(s, "", fixed = TRUE)[[1L]])

compact <- function(s) toupper(gsub("[[:space:]-]", "", s))

each <- function(x, f) {
  x <- as.character(x)
  out <- vapply(x, function(s) if (is.na(s)) NA else f(s), logical(1L), USE.NAMES = FALSE)
  out
}

birth_string <- function(s) {
  if (!grepl("^[0-9]{11}$", s)) {
    return(NA_character_)
  }
  d <- to_digits(s)
  century <- c(1800L, 1800L, 1900L, 1900L, 2000L, 2000L)[d[1L]]
  if (d[1L] < 1L || d[1L] > 6L) {
    return(NA_character_)
  }
  text <- sprintf("%d-%s-%s", century + as.integer(substr(s, 2L, 3L)), substr(s, 4L, 5L), substr(s, 6L, 7L))
  parsed <- tryCatch(as.Date(text, format = "%Y-%m-%d"), error = function(e) as.Date(NA))
  if (is.na(parsed)) NA_character_ else text
}

#' Test Lithuanian personal codes
#'
#' A personal code has 11 digits: the first gives the century and sex, the next
#' six the birth date, and the last is a check digit. Codes that start with 9
#' carry no date, so only the check digit is tested.
#'
#' @param x A character vector of codes.
#' @return A logical vector of the same length as \code{x}; \code{NA} input
#'   gives \code{NA}.
#' @examples
#' is_personal_code(c("33309240064", "33309240164"))
#' @export
is_personal_code <- function(x) {
  each(x, function(s) {
    if (!grepl("^[0-9]{11}$", s)) {
      return(FALSE)
    }
    d <- to_digits(s)
    if (d[1L] != 9L && is.na(birth_string(s))) {
      return(FALSE)
    }
    check_digit(d[1:10]) == d[11L]
  })
}

#' Read the birth date from Lithuanian personal codes
#'
#' @param x A character vector of personal codes.
#' @return A \code{Date} vector of the same length as \code{x}, with \code{NA}
#'   where a code holds no valid date. The check digit is not tested.
#' @examples
#' personal_code_birth_date("33309240064")
#' @export
personal_code_birth_date <- function(x) {
  x <- as.character(x)
  as.Date(vapply(x, function(s) if (is.na(s)) NA_character_ else birth_string(s), character(1L), USE.NAMES = FALSE))
}

#' Read the sex from Lithuanian personal codes
#'
#' @param x A character vector of personal codes.
#' @return A character vector with \code{"M"} for odd first digits 1, 3 and 5,
#'   \code{"F"} for 2, 4 and 6, and \code{NA} otherwise.
#' @examples
#' personal_code_sex("33309240064")
#' @export
personal_code_sex <- function(x) {
  x <- as.character(x)
  first <- substr(x, 1L, 1L)
  out <- rep(NA_character_, length(x))
  out[!is.na(x) & first %in% c("1", "3", "5")] <- "M"
  out[!is.na(x) & first %in% c("2", "4", "6")] <- "F"
  out
}

#' Test Lithuanian company codes
#'
#' A company code has nine digits and ends in a check digit.
#'
#' @param x A character vector of codes.
#' @return A logical vector of the same length as \code{x}; \code{NA} input
#'   gives \code{NA}.
#' @examples
#' is_company_code(c("123033512", "123033513"))
#' @export
is_company_code <- function(x) {
  each(x, function(s) {
    if (!grepl("^[0-9]{9}$", s)) {
      return(FALSE)
    }
    d <- to_digits(s)
    check_digit(d[1:8]) == d[9L]
  })
}

#' Test Lithuanian VAT numbers
#'
#' A VAT number has 9 or 12 digits and may start with \code{LT}.
#'
#' @param x A character vector of numbers.
#' @return A logical vector of the same length as \code{x}; \code{NA} input
#'   gives \code{NA}.
#' @examples
#' is_vat_number(c("LT119511515", "LT119511516"))
#' @export
is_vat_number <- function(x) {
  each(x, function(s) {
    s <- sub("^LT", "", compact(s))
    if (!grepl("^([0-9]{9}|[0-9]{12})$", s)) {
      return(FALSE)
    }
    d <- to_digits(s)
    n <- length(d)
    marker <- if (n == 9L) 8L else 11L
    d[marker] == 1L && check_digit(d[-n]) == d[n]
  })
}

#' Test Lithuanian IBANs
#'
#' A Lithuanian IBAN has 20 characters, starts with \code{LT} and passes the
#' MOD-97 rule.
#'
#' @param x A character vector of account numbers.
#' @return A logical vector of the same length as \code{x}; \code{NA} input
#'   gives \code{NA}.
#' @examples
#' is_iban(c("LT121000011101001000", "LT121000011101001001"))
#' @export
is_iban <- function(x) {
  each(x, function(s) {
    s <- compact(s)
    if (!grepl("^LT[0-9]{18}$", s)) {
      return(FALSE)
    }
    moved <- paste0(substr(s, 5L, 20L), "2129", substr(s, 3L, 4L))
    rem <- 0L
    for (n in to_digits(moved)) {
      rem <- (rem * 10L + n) %% 97L
    }
    rem == 1L
  })
}
