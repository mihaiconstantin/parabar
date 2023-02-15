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
#' calls the `stop` method on the provided [`backend`][`parabar::Backend`]
#' instance.
#'
#' @return
#' The function returns void. It throws an error if the
#' [`backend`][`parabar::Backend`] provided is already stopped.
#'
#' @examples
#' # Create a synchronous backend.
#' backend <- start_backend(cores = 2, cluster_type = "psock", backend_type = "sync")
#'
#' # Check that the backend is active.
#' backend$active
#'
#' # Stop the backend.
#' stop_backend(backend)
#'
#' # Check that the backend is not active.
#' backend$active
#'
#' @seealso [parabar::start_backend()], [`parabar::Service`]
