#' @title
#' Stop a Backend
#'
#' @description
#' This function can be used to stop a [`backend`][`parabar::Backend`] created
#' by [parabar::start_backend()].
#'
#' @param backend An object of class [`parabar::Backend`] as returned by the
#' [parabar::start_backend()] function.
#'
#' @details
#' This function is a convenience wrapper around the lower-lever API of
#' [`parabar::parabar`] aimed at developers. More specifically, this function
#' calls the [`stop`][`parabar::Service`] method on the provided
#' [`backend`][`parabar::Backend`] instance.
#'
#' @return
#' The function returns void. It throws an error if:
#' - the value provided for the `backend` argument is not an instance of class
#'   [`parabar::Backend`].
#' - the [`backend`][`parabar::Backend`] object provided is already stopped
#'   (i.e., is not active).
#'
#' @inherit start_backend examples
#'
#' @seealso
#' [parabar::start_backend()], [parabar::peek()], [parabar::export()],
#' [parabar::evaluate()], [parabar::clear()], [parabar::configure_bar()],
#' [parabar::par_sapply()], [parabar::par_lapply()], and [`parabar::Service`].
