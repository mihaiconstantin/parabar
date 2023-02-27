#' @title
#' Generate Package Logo
#'
#' @description
#' This function is meant for generating or updating the logo. After running
#' this procedure we end up with what is stored in the [`parabar::LOGO`]
#' constant.
#'
#' @param template A character string representing the path to the logo
#' template.
#'
#' @param version A numerical vector of three positive integers representing the
#' version of the package to append to the logo.
#'
#' @return The ASCII logo.
#'
#' @examples
#' # Generate the logo.
#' logo <- make_logo()
#'
#' # Print the logo.
#' cat(logo)
#'
#' @seealso [`parabar::LOGO`]
