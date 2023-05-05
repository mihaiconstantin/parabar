#' @title
#' Evaluate An Expression On The Backend
#'
#' @description
#' This function can be used to evaluate an arbitrary [base::expression()] a
#' [`backend`][`parabar::Backend`] created by [parabar::start_backend()].
#'
#' @param backend An object of class [`parabar::Backend`] as returned by the
#' [parabar::start_backend()] function.
#'
 #' @param expression An unquoted expression to evaluate on the backend.
#'
#' @details
#' This function is a convenience wrapper around the lower-lever API of
#' [`parabar::parabar`] aimed at developers. More specifically, this function
#' calls the [`evaluate`][`parabar::Service`] method on the provided
#' [`backend`][`parabar::Backend`] instance.
#'
#' @return
#' This method returns the result of the expression evaluation. It throws an
#' error if the value provided for the `backend` argument is not an instance of
#' class [`parabar::Backend`].
#'
#' @inherit start_backend examples
#'
#' @seealso
#' [parabar::start_backend()], [parabar::peek()], [parabar::export()],
#' [parabar::clear()], [parabar::configure_bar()], [parabar::par_sapply()],
#' [parabar::par_lapply()], [parabar::par_apply()], [parabar::stop_backend()],
#' and [`parabar::Service`].
