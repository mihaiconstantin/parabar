#' @title
#' Run a Task in Parallel
#'
#' @description
#' This function can be used to run a task in parallel. The task is executed in
#' parallel on the specified backend, similar to [parallel::parSapply()]. If
#' `backend = NULL`, the task is executed sequentially using [base::sapply()].
#' See the **Details** section for more information on how this function works.
#'
#' @param backend An object of class [`parabar::Backend`] as returned by the
#' [parabar::start_backend()] function. It can also be `NULL` to run the task
#' sequentially via [base::sapply()]. The default value is `NULL`.
#'
#' @param x A vector (i.e., usually of integers) to pass to the `fun` function.
#'
#' @param fun A function to apply to each element of `x`.
#'
#' @param ... Additional arguments to pass to the `fun` function.
#'
#' @details
#' This function is a wrapper around the developer API of the
#' [`parabar::parabar`] package. More specifically, this function:
#' - Instantiates an appropriate [`parabar::parabar`] context. If the backend
#' supports progress tracking (i.e., the backend is an instance of
#' [`parabar::AsyncBackend`]), a progress tracking context (i.e.,
#' [`parabar::ProgressDecorator`]) is instantiated and used. Otherwise, a
#' regular context (i.e., [`parabar::Context`]) is instantiated. A regular
#' context is also used if the progress tracking is disabled via the
#' [`parabar::Options`] instance.
#' - Registers the [`backend`][`parabar::Backend`] with the context.
#' - Instantiates and configures the progress bar based on the
#'   [`parabar::Options`] instance in the session [`base::.Options`] list.
#' - Executes the task in parallel, and displays a progress bar if appropriate.
#'
#' @return
#' A vector or list of the same length as `x` containing the results of the
#' `fun`. The output format resembles that of [base::sapply()].
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
#'     return(x + 1)
#' }
#'
#' # Start an asynchronous backend.
#' backend <- start_backend(cores = 2, cluster_type = "psock", backend_type = "async")
#'
#' # Run a task in parallel.
#' results <- par_sapply(backend, x = 1:300, fun = task)
#'
#' # Disable progress tracking.
#' set_option("progress_track", FALSE)
#'
#' # Run a task in parallel.
#' results <- par_sapply(backend, x = 1:300, fun = task)
#'
#' # Enable progress tracking.
#' set_option("progress_track", TRUE)
#'
#' # Change the progress bar options.
#' configure_bar(type = "modern", format = "[:bar] :percent")
#'
#' # Run a task in parallel.
#' results <- par_sapply(backend, x = 1:300, fun = task)
#'
#' # Stop the backend.
#' stop_backend(backend)
#'
#' # Start a synchronous backend.
#' backend <- start_backend(cores = 2, cluster_type = "psock", backend_type = "sync")
#'
#' # Run a task in parallel.
#' results <- par_sapply(backend, x = 1:300, fun = task)
#'
#' # Disable progress tracking to remove the warning that progress is not supported.
#' set_option("progress_track", FALSE)
#'
#' # Run a task in parallel.
#' results <- par_sapply(backend, x = 1:300, fun = task)
#'
#' # Stop the backend.
#' stop_backend(backend)
#'
#' # Run the task using the `base::sapply` (i.e., non-parallel).
#' results <- par_sapply(NULL, x = 1:300, fun = task)
#'
#' }
#'
#' @seealso
#' [parabar::start_backend()], [parabar::peek()], [parabar::export()],
#' [parabar::evaluate()], [parabar::clear()], [parabar::configure_bar()],
#' [parabar::stop_backend()], [parabar::set_option()], [parabar::get_option()],
#' [`parabar::Options`], and [`parabar::Service`].
