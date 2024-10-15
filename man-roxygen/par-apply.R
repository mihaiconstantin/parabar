#' @title
#' Run a Task in Parallel
#'
#' @description
#' This function can be used to run a task in parallel. The task is executed in
#' parallel on the specified backend, similar to [`parallel::parApply()`]. If
#' `backend = NULL`, the task is executed sequentially using [`base::apply()`].
#' See the **Details** section for more information on how this function works.
#'
#' @param backend An object of class [`parabar::Backend`] as returned by the
#' [parabar::start_backend()] function. It can also be `NULL` to run the task
#' sequentially via [`base::apply()`]. The default value is `NULL`.
#'
#' @param x An array to pass to the `fun` function.
#'
#' @param margin A numeric vector indicating the dimensions of `x` the
#' `fun` function should be applied over. For example, for a matrix,
#' `margin = 1` indicates applying `fun` rows-wise, `margin = 2`
#' indicates applying `fun` columns-wise, and `margin = c(1, 2)`
#' indicates applying `fun` element-wise. Named dimensions are also
#' possible depending on `x`. See [`parallel::parApply()`] and
#' [`base::apply()`] for more details.
#'
#' @param fun A function to apply to `x` according to the `margin`.
#'
#' @param ... Additional arguments to pass to the `fun` function.
#'
#' @details
#' This function uses the [`parabar::UserApiConsumer`] class that acts like an
#' interface for the developer API of the [`parabar::parabar`] package.
#'
#' @return
#' The dimensions of the output vary according to the `margin` argument. Consult
#' the documentation of [`base::apply()`] for a detailed explanation on how the
#' output is structured.
#'
#' @examples
#' \donttest{
#'
#' # Define a simple task.
#' task <- function(x) {
#'     # Perform computations.
#'     Sys.sleep(0.01)
#'
#'     # Return the result.
#'     mean(x)
#' }
#'
#' # Define a matrix for the task.
#' x <- matrix(rnorm(100^2, mean = 10, sd = 0.5), nrow = 100, ncol = 100)
#'
#' # Start an asynchronous backend.
#' backend <- start_backend(cores = 2, cluster_type = "psock", backend_type = "async")
#'
#' # Run a task in parallel over the rows of `x`.
#' results <- par_apply(backend, x = x, margin = 1, fun = task)
#'
#' # Run a task in parallel over the columns of `x`.
#' results <- par_apply(backend, x = x, margin = 2, fun = task)
#'
#' # The task can also be run over all elements of `x` using `margin = c(1, 2)`.
#' # Improper dimensions will throw an error.
#' try(par_apply(backend, x = x, margin = c(1, 2, 3), fun = task))
#'
#' # Disable progress tracking.
#' set_option("progress_track", FALSE)
#'
#' # Run a task in parallel.
#' results <- par_apply(backend, x = x, margin = 1, fun = task)
#'
#' # Enable progress tracking.
#' set_option("progress_track", TRUE)
#'
#' # Change the progress bar options.
#' configure_bar(type = "modern", format = "[:bar] :percent")
#'
#' # Run a task in parallel.
#' results <- par_apply(backend, x = x, margin = 1, fun = task)
#'
#' # Stop the backend.
#' stop_backend(backend)
#'
#' # Start a synchronous backend.
#' backend <- start_backend(cores = 2, cluster_type = "psock", backend_type = "sync")
#'
#' # Run a task in parallel.
#' results <- par_apply(backend, x = x, margin = 1, fun = task)
#'
#' # Disable progress tracking to remove the warning that progress is not supported.
#' set_option("progress_track", FALSE)
#'
#' # Run a task in parallel.
#' results <- par_apply(backend, x = x, margin = 1, fun = task)
#'
#' # Stop the backend.
#' stop_backend(backend)
#'
#' # Run the task using the `base::lapply` (i.e., non-parallel).
#' results <- par_apply(NULL, x = x, margin = 1, fun = task)
#'
#' }
#'
#' @seealso
#' [parabar::start_backend()], [parabar::peek()], [parabar::export()],
#' [parabar::evaluate()], [parabar::clear()], [parabar::configure_bar()],
#' [parabar::par_sapply()], [parabar::par_lapply()], [parabar::stop_backend()],
#' [parabar::set_option()], [parabar::get_option()], [`parabar::Options`],
#' [`parabar::UserApiConsumer`], and [`parabar::Service`].
