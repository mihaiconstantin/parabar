#' @title
#' Inspect a Backend
#'
#' @description
#' This function can be used to check the names of the variables present on a
#' [`backend`][`parabar::Backend`] created by [parabar::start_backend()].
#'
#' @param backend An object of class [`parabar::Backend`] as returned by the
#' [parabar::start_backend()] function.
#'
#' @details
#' This function is a convenience wrapper around the lower-lever API of
#' [`parabar::parabar`] aimed at developers. More specifically, this function
#' calls the [`peek`][`parabar::Service`] method on the provided
#' [`backend`][`parabar::Backend`] instance.
#'
#' @return
#' The function returns a list of character vectors, where each list element
#' corresponds to a node, and each element of the character vector is the name
#' of a variable present on that node. It throws an error if the value provided
#' for the `backend` argument is not an instance of class [`parabar::Backend`].
#'
#' @inherit start_backend examples
#'
#' @seealso
#' [parabar::start_backend()], [parabar::export()], [parabar::evaluate()],
#' [parabar::clear()], [parabar::configure_bar()], [parabar::par_sapply()],
#' [parabar::par_lapply()], [parabar::stop_backend()], and [`parabar::Service`].
