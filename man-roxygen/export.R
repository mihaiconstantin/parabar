#' @title
#' Export Objects To a Backend
#'
#' @description
#' This function can be used to export objects to a
#' [`backend`][`parabar::Backend`] created by [parabar::start_backend()].
#'
#' @param backend An object of class [`parabar::Backend`] as returned by the
#' [parabar::start_backend()] function.
#'
#' @param variables A character vector of variable names to export to the
#' backend.
#'
#' @param environment An environment from which to export the variables. If no
#' environment is provided, the `.GlobalEnv` environment is used.
#'
#' @details
#' This function is a convenience wrapper around the lower-lever API of
#' [`parabar::parabar`] aimed at developers. More specifically, this function
#' calls the [`export`][`parabar::BackendService`] method on the provided
#' [`backend`][`parabar::Backend`] instance.
#'
#' @return
#' The function returns void. It throws an error if the value provided for the
#' `backend` argument is not an instance of class [`parabar::Backend`].
#'
#' @inherit start_backend examples
#'
#' @seealso
#' [parabar::start_backend()], [parabar::peek()], [parabar::evaluate()],
#' [parabar::clear()], [parabar::configure_bar()], [parabar::par_sapply()],
#' [parabar::par_lapply()], [parabar::par_apply()], [parabar::stop_backend()],
#' and [`parabar::BackendService`].
