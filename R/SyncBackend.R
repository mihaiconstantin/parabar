#' @include Exception.R Backend.R Specification.R

#' @title
#' SyncBackend
#'
#' @description
#' This is a concrete implementation of the abstract class [`parabar::Backend`]
#' that implements the [`parabar::Service`] interface. This backend executes
#' tasks in parallel on a [parallel::makeCluster()] cluster synchronously (i.e.,
#' blocking the main `R` session).
#'
#' @examples
#' # Create a specification object.
#' specification <- Specification$new()
#'
#' # Set the number of cores.
#' specification$set_cores(cores = 2)
#'
#' # Set the cluster type.
#' specification$set_type(type = "psock")
#'
#' # Create a synchronous backend object.
#' backend <- SyncBackend$new()
#'
#' # Start the cluster on the backend.
#' backend$start(specification)
#'
#' # Check if there is anything on the backend.
#' backend$peek()
#'
#' # Create a dummy variable.
#' name <- "parabar"
#'
#' # Export the variable from the current environment to the backend.
#' backend$export("name", environment())
#'
#' # Remove variable from current environment.
#' rm(name)
#'
#' # Run an expression on the backend, using the exported variable `name`.
#' backend$evaluate({
#'     # Print the name.
#'     print(paste0("Hello, ", name, "!"))
#' })
#'
#' # Run a task in parallel (i.e., approx. 1.25 seconds).
#' backend$sapply(
#'     x = 1:10,
#'     fun = function(x) {
#'         # Sleep a bit.
#'         Sys.sleep(0.25)
#'
#'         # Compute something.
#'         output <- x + 1
#'
#'         # Return the result.
#'         return(output)
#'     }
#' )
#'
#' # Get the task output.
#' backend$get_output()
#'
#' # Clear the backend.
#' backend$clear()
#'
#' # Check that there is nothing on the cluster.
#' backend$peek()
#'
#' # Stop the backend.
#' backend$stop()
#'
#' # Check that the backend is not active.
#' backend$active
#'
#' @seealso
#' [`parabar::Service`], [`parabar::Backend`], [`parabar::AsyncBackend`], and
#' [`parabar::Context`].
#'
#' @export
SyncBackend <- R6::R6Class("SyncBackend",
    inherit = Backend,

    private = list(
        # Start a cluster.
        .start = function(specification) {
            # If a cluster is already active.
            if (private$.active) {
                # Throw error.
                Exception$cluster_active()
            }

            # Create cluster based on specification.
            private$.cluster <- parallel::makeCluster(specification$cores, specification$type)

            # Sanitize the cluster.
            private$.clear()

            # Toggle the active flag.
            private$.toggle_active_state()
        },

        # Stop the cluster.
        .stop = function() {
            # If there is no cluster active.
            if (!private$.active) {
                # Throw.
                Exception$cluster_not_active()
            }

            # Stop the cluster.
            parallel::stopCluster(private$.cluster)

            # Rest the cluster field.
            private$.cluster <- NULL

            # Toggle the active flag.
            private$.toggle_active_state()
        },

        # Sanitize the cluster.
        .clear = function() {
            # Evaluate the cleaning expression on the cluster.
            parallel::clusterEvalQ(private$.cluster, rm(list = ls(all.names = TRUE)))

            # Remain silent.
            invisible()
        },

        # Inspect what is on the cluster.
        .peek = function() {
            # Check what is on the cluster.
            parallel::clusterEvalQ(private$.cluster, ls(all.names = TRUE))
        },

        # Export variables on the cluster.
        .export = function(variables, environment) {
            # Export to the cluster.
            parallel::clusterExport(private$.cluster, variables, environment)

            # Remain silent.
            invisible()
        },

        # Evaluate an expression on the cluster.
        .evaluate = function(expression) {
            # Capture the expression.
            capture <- substitute(expression)

            # Evaluate the expression.
            parallel::clusterCall(private$.cluster, eval, capture)
        },

        # A wrapper around `parallel:parSapply` to run tasks on the cluster.
        .sapply = function(x, fun, ...) {
            # Run the task and return the results.
            parallel::parSapply(private$.cluster, X = x, FUN = fun, ...)
        },

        # A wrapper around `parallel:parLapply` to run tasks on the cluster.
        .lapply = function(x, fun, ...) {
            # Run the task and return the results.
            parallel::parLapply(private$.cluster, X = x, fun = fun, ...)
        },

        # A wrapper around `parallel:parApply` to run tasks on the cluster.
        .apply = function(x, margin, fun, ...) {
            # Run the task and return the results.
            parallel::parApply(private$.cluster, X = x, MARGIN = margin, FUN = fun, ...)
        },

        # Clear the current output on the backend.
        .clear_output = function() {
            # Clear output.
            private$.output <- NULL
        }
    ),

    public = list(
        #' @description
        #' Create a new [`parabar::SyncBackend`] object.
        #'
        #' @return
        #' An object of class [`parabar::SyncBackend`].
        initialize = function() {},

        #' @description
        #' Destroy the current [`parabar::SyncBackend`] instance.
        #'
        #' @return
        #' An object of class [`parabar::SyncBackend`].
        finalize = function() {
           # If a cluster is active, stop before deleting the instance.
            if (private$.active) {
                # Stop the cluster.
                private$.stop()
            }
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
            private$.start(specification)
        },

        #' @description
        #' Stop the backend.
        #'
        #' @return
        #' This method returns void.
        stop = function() {
            private$.stop()
        },

        #' @description
        #' Remove all objects from the backend. This function is equivalent to
        #' calling `rm(list = ls(all.names = TRUE))` on each node in the
        #' backend.
        #'
        #' @return
        #' This method returns void.
        clear = function() {
            private$.clear()
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
            private$.peek()
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

            # Export and return the output.
            private$.export(variables, environment)
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

            # Create call.
            capture_call <- bquote(private$.evaluate(.(capture)))

            # Perform the call.
            eval(capture_call)
        },

        #' @description
        #' Run a task on the backend akin to [parallel::parSapply()].
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
            private$.output = private$.sapply(x, fun, ...)
        },

        #' @description
        #' Run a task on the backend akin to [parallel::parLapply()].
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
            private$.output = private$.lapply(x, fun, ...)
        },

        #' @description
        #' Run a task on the backend akin to [parallel::parApply()].
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
        #' @param ... Additional arguments to pass to the `fun` function.
        #'
        #' @return
        #' This method returns void. The output of the task execution must be
        #' stored in the private field `.output` on the [`parabar::Backend`]
        #' abstract class, and is accessible via the `get_output()` method.
        apply = function(x, margin, fun, ...) {
            # Validate provided margins.
            Helper$check_array_margins(margin, dim(x))

            # Deploy the task synchronously.
            private$.output = private$.apply(x, margin, fun, ...)
        },

        #' @description
        #' Get the output of the task execution.
        #'
        #' @param ... Additional arguments currently not in use.
        #'
        #' @details
        #' This method fetches the output of the task execution after calling
        #' the `sapply()` method. It returns the output and immediately removes
        #' it from the backend. Therefore, subsequent calls to this method will
        #' return `NULL`. This method should be called after the execution of a
        #' task.
        #'
        #' @return
        #' A vector, matrix, or list of the same length as `x`, containing the
        #' results of the `fun`. The output format differs based on the specific
        #' operation employed. Check out the documentation for the `apply`
        #' operations of [`parallel::parallel`] for more information.
        get_output = function(...) {
            # Reset the output on exit.
            on.exit({
                # Clear.
                private$.clear_output()
            })

            return(private$.output)
        }
    )
)
