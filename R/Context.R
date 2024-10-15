#' @include Backend.R

#' @title
#' Context
#'
#' @description
#' This class represents the base context for interacting with
#' [`parabar::Backend`] implementations via the [`parabar::Service`] interface.
#'
#' @details
#' This class is a vanilla wrapper around a [`parabar::Backend`] implementation.
#' It registers a backend instance and forwards all [`parabar::Service`] methods
#' calls to the backend instance. Subclasses can override any of the
#' [`parabar::Service`] methods to decorate the backend instance with additional
#' functionality (e.g., see the [`parabar::ProgressTrackingContext`] class).
#'
#' @examples
#' # Define a task to run in parallel.
#' task <- function(x, y) {
#'     # Sleep a bit.
#'     Sys.sleep(0.25)
#'
#'     # Return the result of a computation.
#'     return(x + y)
#' }
#'
#' # Create a specification object.
#' specification <- Specification$new()
#'
#' # Set the number of cores.
#' specification$set_cores(cores = 2)
#'
#' # Set the cluster type.
#' specification$set_type(type = "psock")
#'
#' # Create a backend factory.
#' backend_factory <- BackendFactory$new()
#'
#' # Get a synchronous backend instance.
#' backend <- backend_factory$get("sync")
#'
#' # Create a base context object.
#' context <- Context$new()
#'
#' # Register the backend with the context.
#' context$set_backend(backend)
#'
#' # From now all, all backend operations are intercepted by the context.
#'
#' # Start the backend.
#' context$start(specification)
#'
#' # Run a task in parallel (i.e., approx. 1.25 seconds).
#' context$sapply(x = 1:10, fun = task, y = 10)
#'
#' # Get the task output.
#' context$get_output()
#'
#' # Close the backend.
#' context$stop()
#'
#' # Get an asynchronous backend instance.
#' backend <- backend_factory$get("async")
#'
#' # Register the backend with the same context object.
#' context$set_backend(backend)
#'
#' # Start the backend reusing the specification object.
#' context$start(specification)
#'
#' # Run a task in parallel (i.e., approx. 1.25 seconds).
#' context$sapply(x = 1:10, fun = task, y = 10)
#'
#' # Get the task output.
#' backend$get_output(wait = TRUE)
#'
#' # Close the backend.
#' context$stop()
#'
#' @seealso
#' [`parabar::ProgressTrackingContext`], [`parabar::Service`],
#' [`parabar::Backend`], and [`parabar::SyncBackend`].
#'
#' @export
Context <- R6::R6Class("Context",
    inherit = Service,

    private = list(
        # The backend used by the context manager.
        .backend = NULL
    ),

    public = list(
        #' @description
        #' Create a new [`parabar::Context`] object.
        #'
        #' @return
        #' An object of class [`parabar::Context`].
        initialize = function() { invisible() },

        #' @description
        #' Set the backend instance to be used by the context.
        #'
        #' @param backend An object of class [`parabar::Backend`] that
        #' implements the [`parabar::Service`] interface.
        set_backend = function(backend) {
            private$.backend <- backend
        },

        #' @description
        #' Start the backend.
        #'
        #' @param specification An object of class [`parabar::Specification`]
        #' that contains the backend configuration.
        #'
        #' @return
        #' This method returns void. The resulting backend must be stored in the
        #' `.cluster` private field on the [`parabar::Backend`] abstract class,
        #' and accessible to any concrete backend implementations via the active
        #' binding `cluster`.
        start = function(specification) {
            # Consume the backend API.
            private$.backend$start(specification)
        },

        #' @description
        #' Stop the backend.
        #'
        #' @return
        #' This method returns void.
        stop = function() {
            # Consume the backend API.
            private$.backend$stop()
        },

        #' @description
        #' Remove all objects from the backend. This function is equivalent to
        #' calling `rm(list = ls(all.names = TRUE))` on each node in the
        #' backend.
        #'
        #' @return
        #' This method returns void.
        clear = function() {
            # Consume the backend API.
            private$.backend$clear()
        },

        #' @description
        #' Inspect the backend for variables available in the `.GlobalEnv`.
        #'
        #' @return
        #' This method returns a list of character vectors, where each element
        #' corresponds to a node in the backend. The character vectors contain
        #' the names of the variables available in the `.GlobalEnv` on each
        #' node.
        peek = function() {
            # Consume the backend API.
            private$.backend$peek()
        },

        #' @description
        #' Export variables from a given environment to the backend.
        #'
        #' @param variables A character vector of variable names to export.
        #'
        #' @param environment An environment object from which to export the
        #' variables. Defaults to the parent frame.
        #'
        #' @return This method returns void.
        export = function(variables, environment) {
            # If no environment is provided.
            if (missing(environment)) {
                # Use the caller's environment where the variables are defined.
                environment <- parent.frame()
            }

            # Consume the backend API.
            private$.backend$export(variables, environment)
        },

        #' @description
        #' Evaluate an arbitrary expression on the backend.
        #'
        #' @param expression An unquoted expression to evaluate on the backend.
        #'
        #' @return
        #' This method returns the result of the expression evaluation.
        evaluate = function(expression) {
            # Capture the expression.
            capture <- substitute(expression)

            # Create the call.
            capture_call <- bquote(private$.backend$evaluate(.(capture)))

            # Perform the call.
            eval(capture_call)
        },

        #' @description
        #' Run a task on the backend akin to [`parallel::parSapply()`].
        #'
        #' @param x An atomic vector or list to pass to the `fun` function.
        #'
        #' @param fun A function to apply to each element of `x`.
        #'
        #' @param ... Additional arguments to pass to the `fun` function.
        #'
        #' @return
        #' This method returns void. The output of the task execution must be
        #' stored in the private field `.output` on the [`parabar::Backend`]
        #' abstract class, and is accessible via the `get_output()` method.
        sapply = function(x, fun, ...) {
            # Consume the backend API.
            private$.backend$sapply(x = x, fun = fun, ...)
        },

        #' @description
        #' Run a task on the backend akin to [`parallel::parLapply()`].
        #'
        #' @param x An atomic vector or list to pass to the `fun` function.
        #'
        #' @param fun A function to apply to each element of `x`.
        #'
        #' @param ... Additional arguments to pass to the `fun` function.
        #'
        #' @return
        #' This method returns void. The output of the task execution must be
        #' stored in the private field `.output` on the [`parabar::Backend`]
        #' abstract class, and is accessible via the `get_output()` method.
        lapply = function(x, fun, ...) {
            # Consume the backend API.
            private$.backend$lapply(x = x, fun = fun, ...)
        },

        #' @description
        #' Run a task on the backend akin to [`parallel::parApply()`].
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
        #' @return
        #' This method returns void. The output of the task execution must be
        #' stored in the private field `.output` on the [`parabar::Backend`]
        #' abstract class, and is accessible via the `get_output()` method.
        apply = function(x, margin, fun, ...) {
            # Consume the backend API.
            private$.backend$apply(x = x, margin = margin, fun = fun, ...)
        },

        #' @description
        #' Get the output of the task execution.
        #'
        #' @param ... Additional arguments to pass to the backend registered
        #' with the context. This is useful for backends that require additional
        #' arguments to fetch the output (e.g., [`AsyncBackend$get_output(wait =
        #' TRUE)`][`parabar::AsyncBackend`]).
        #'
        #' @details
        #' This method fetches the output of the task execution after calling
        #' the `sapply()` method. It returns the output and immediately removes
        #' it from the backend. Therefore, subsequent calls to this method are
        #' not advised. This method should be called after the execution of a
        #' task.
        #'
        #' @return
        #' A vector, matrix, or list of the same length as `x`, containing the
        #' results of the `fun`. The output format differs based on the specific
        #' operation employed. Check out the documentation for the `apply`
        #' operations of [`parallel::parallel`] for more information.
        get_output = function(...) {
            # Consume the backend API.
            private$.backend$get_output(...)
        }
    ),

    active = list(
        #' @field backend The [`parabar::Backend`] object registered with the
        #' context.
        backend = function() { return(private$.backend) }
    )
)
