#' @include Helper.R Warning.R ContextFactory.R BarFactory.R

#' @title
#' UserApiConsumer
#'
#' @description
#' This class is an opinionated interface around the developer API of the
#' [`parabar::parabar`] package. See the **Details** section for more
#' information on how this class works.
#'
#' @param ... Additional arguments to pass to the `fun` function.
#'
#' @details
#' This class acts as a wrapper around the [`R6::R6`] developer API of the
#' [`parabar::parabar`] package. In a nutshell, it provides an opinionated
#' interface by wrapping the developer API in simple functional calls. More
#' specifically, for executing a task in parallel, this class performs the
#' following steps:
#' - Validates the backend provided.
#' - Instantiates an appropriate [`parabar::parabar`] context based on the
#'   backend. If the backend supports progress tracking (i.e., the backend is an
#'   instance of [`parabar::AsyncBackend`]), a progress tracking context (i.e.,
#'   [`parabar::ProgressTrackingContext`]) is instantiated and used. Otherwise,
#'   a regular context (i.e., [`parabar::Context`]) is instantiated. A regular
#'   context is also used if the progress tracking is disabled via the
#'   [`parabar::Options`] instance.
#' - Registers the [`backend`][`parabar::Backend`] with the context.
#' - Instantiates and configures the progress bar based on the
#'   [`parabar::Options`] instance in the session [`base::.Options`] list.
#' - Executes the task in parallel, and displays a progress bar if appropriate.
#' - Fetches the results from the backend and returns them.
#'
#' @examples
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
#' # Change the progress bar options.
#' configure_bar(type = "modern", format = "[:bar] :percent")
#'
#' # Create an user API consumer.
#' consumer <- UserApiConsumer$new()
#'
#' # Execute the task using the `sapply` parallel operation.
#' output_sapply <- consumer$sapply(backend = backend, x = 1:200, fun = task)
#'
#' # Print the head of the `sapply` operation output.
#' head(output_sapply)
#'
#' # Execute the task using the `sapply` parallel operation.
#' output_lapply <- consumer$lapply(backend = backend, x = 1:200, fun = task)
#'
#' # Print the head of the `lapply` operation output.
#' head(output_lapply)
#'
#' # Stop the backend.
#' stop_backend(backend)
#'
#' @seealso
#' [parabar::start_backend()], [parabar::stop_backend()],
#' [parabar::configure_bar()], [parabar::par_sapply()], and
#' [parabar::par_lapply()].
#'
#' @export
UserApiConsumer <- R6::R6Class("UserApiConsumer",
    private = list(
        # Execute a task via the user API with the corresponding operation.
        .execute = function(backend, parallel_operation, sequential_operation) {
            # If no backend is provided.
            if (is.null(backend)) {
                # Then use the non-parallel (i.e., sequential) operation.
                output <- eval(sequential_operation)

                # Return results.
                return(output)

            # Otherwise, if a backend is provided.
            } else {
                # Check the type.
                Helper$check_object_type(backend, "Backend")
            }

            # Get user warning settings.
            user_options <- options()

            # Enable printing warnings as soon as they occur.
            options(warn = 1)

            # Restore user's original settings.
            on.exit({
                # Reset user's options.
                options(user_options)
            })

            # Whether to track progress or not.
            progress <- get_option("progress_track")

            # If the user requested progress tracking and the backend does not support it.
            if (progress && !backend$supports_progress) {
                # Warn the users.
                Warning$progress_not_supported_for_backend(backend)
            }

            # Create a context manager factory.
            context_factory <- ContextFactory$new()

            # If progress is requested and the conditions are right.
            if (progress && backend$supports_progress && interactive()) {
                # Then use a progress-decorated context.
                context <- context_factory$get("progress")

                # Progress bar type.
                bar_type <- get_option("progress_bar_type")

                # Progress bar default configuration.
                bar_config <- get_option("progress_bar_config")[[bar_type]]

                # Create a bar factory.
                bar_factory <- BarFactory$new()

                # Get a bar of desired type.
                bar <- bar_factory$get(bar_type)

                # Set the bar.
                context$set_bar(bar)

                # Configure the bar.
                do.call(context$configure_bar, bar_config)

            # Otherwise, if progress tracking is not requested, nor possible.
            } else {
                # Use a regular context.
                context <- context_factory$get("regular")
            }

            # Register the backend with the context.
            context$set_backend(backend)

            # Register the backend with the context.
            context$set_backend(backend)

            # Execute the task via the requested parallel operation.
            eval(parallel_operation)

            # If the current context wraps a backend that supports progress tracking.
            if (context$backend$supports_progress) {
                # Then wait for the results.
                output <- context$get_output(wait = TRUE)
            } else {
                # Otherwise, return the output whenever the task is finished.
                output <- context$get_output()
            }

            return(output)
        }
    ),

    public = list(
        #' @description
        #' Execute a task in parallel akin to [parallel::parSapply()].
        #'
        #' @param backend An object of class [`parabar::Backend`] as returned by
        #' the [parabar::start_backend()] function. It can also be `NULL` to run
        #' the task sequentially via [base::sapply()].
        #'
        #' @param x An atomic vector or list to pass to the `fun` function.
        #'
        #' @param fun A function to apply to each element of `x`.
        #'
        #' @return
        #' A vector of the same length as `x` containing the results of the
        #' `fun`. The output format resembles that of [base::sapply()].
        sapply = function(backend, x, fun, ...) {
            # Prepare the sequential operation.
            sequential <- bquote(
                do.call(
                    base::sapply, c(list(X = .(x), FUN = .(fun)), .(list(...)))
                )
            )

            # Prepare the parallel operation.
            parallel <- bquote(
                do.call(
                    context$sapply, c(list(x = .(x), fun = .(fun)), .(list(...)))
                )
            )

            # Execute the `sapply` operation accordingly and return the results.
            private$.execute(backend, parallel, sequential)
        },

        #' @description
        #' Execute a task in parallel akin to [parallel::parLapply()].
        #'
        #' @param backend An object of class [`parabar::Backend`] as returned by
        #' the [parabar::start_backend()] function. It can also be `NULL` to run
        #' the task sequentially via [base::lapply()].
        #'
        #' @param x An atomic vector or list to pass to the `fun` function.
        #'
        #' @param fun A function to apply to each element of `x`.
        #'
        #' @return
        #' A list of the same length as `x` containing the results of the `fun`.
        #' The output format resembles that of [base::lapply()].
        lapply = function(backend, x, fun, ...) {
            # Prepare the sequential operation.
            sequential <- bquote(
                do.call(
                    base::lapply, c(list(X = .(x), FUN = .(fun)), .(list(...)))
                )
            )

            # Prepare the parallel operation.
            parallel <- bquote(
                do.call(
                    context$lapply, c(list(x = .(x), fun = .(fun)), .(list(...)))
                )
            )

            # Execute the `lapply` operation accordingly and return the results.
            private$.execute(backend, parallel, sequential)
        },

        #' @description
        #' Execute a task in parallel akin to [parallel::parApply()].
        #'
        #' @param backend An object of class [`parabar::Backend`] as returned by
        #' the [parabar::start_backend()] function. It can also be `NULL` to run
        #' the task sequentially via [base::apply()].
        #'
        #' @param x An array to pass to the `fun` function.
        #'
        #' @param margin A numeric vector indicating the dimensions of `x` the
        #' `fun` function should be applied over. For example, for a matrix,
        #' `margin = 1` indicates applying `fun` rows-wise, `margin = 2`
        #' indicates applying `fun` columns-wise, and `margin = c(1, 2)`
        #' indicates applying `fun` element-wise. Named dimensions are also
        #' possible depending on `x`. See [parallel::parApply()] and
        #' [base::apply()] for more details.
        #'
        #' @param fun A function to apply to `x` according to the `margin`.
        #'
        #' @return
        #' The dimensions of the output vary according to the `margin` argument.
        #' Consult the documentation of [base::apply()] for a detailed
        #' explanation on how the output is structured.
        apply = function(backend, x, margin, fun, ...) {
            # Prepare the sequential operation.
            sequential <- bquote(
                do.call(
                    base::apply, c(list(X = .(x), MARGIN = .(margin), FUN = .(fun)), .(list(...)))
                )
            )

            # Prepare the parallel operation.
            parallel <- bquote(
                do.call(
                    context$apply, c(list(x = .(x), margin = .(margin), fun = .(fun)), .(list(...)))
                )
            )

            # Execute the `lapply` operation accordingly and return the results.
            private$.execute(backend, parallel, sequential)
        }
    )
)
