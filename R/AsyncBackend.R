#' @include Exception.R Backend.R Specification.R TaskState.R

#' @title
#' AsyncBackend
#'
#' @description
#' This is a concrete implementation of the abstract class [`parabar::Backend`]
#' that implements the [`parabar::Service`] interface. This backend executes
#' tasks in parallel asynchronously (i.e., without blocking the main `R`
#' session) on a [parallel::makeCluster()] cluster created in a background `R`
#' [`session`][`callr::r_session`].
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
#' # Create an asynchronous backend object.
#' backend <- AsyncBackend$new()
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
#' # Export the variable to the backend.
#' backend$export("name")
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
#' # Run a task in parallel (i.e., approx. 2.5 seconds).
#' backend$sapply(
#'     x = 1:10,
#'     fun = function(x) {
#'         # Sleep a bit.
#'         Sys.sleep(0.5)
#'
#'         # Compute something.
#'         output <- x + 1
#'
#'         # Return the result.
#'         return(output)
#'     }
#' )
#'
#' # Right know the main process is free and the task is executing on a `psock`
#' # cluster started in a background `R` session.
#'
#' # Trying to get the output immediately will throw an error, indicating that the
#' # task is still running.
#' try(backend$get_output())
#'
#' # However, we can block the main process and wait for the task to complete
#' # before fetching the results.
#' backend$get_output(wait = TRUE)
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
#' [`parabar::Service`], [`parabar::Backend`], [`parabar::SyncBackend`],
#' [`parabar::ProgressTrackingContext`], and [`parabar::TaskState`].
#'
#' @export
AsyncBackend <- R6::R6Class("AsyncBackend",
    inherit = Backend,

    private = list(
        # The progress tracking capabilities of the backend implementation.
        .supports_progress = TRUE,

        # Create a parallel cluster in the `R` session.
        .make_cluster = function(specification) {
           # Create cluster in the `.GlobalEnv` in the separate session.
            private$.cluster$run(function(cores, type) {
                # Make the actual cluster.
                cluster <<- parallel::makeCluster(spec = cores, type = type)
            }, args = list(
                specification$cores, specification$type
            ))
        },

        # Stop the cluster existing in the separate `R` session.
        .close_cluster = function() {
            # Send the function.
            private$.cluster$run(function() {
                # Stop the cluster.
                parallel::stopCluster(cluster)
            })
        },

        # Start a cluster in a separate `R` session.
        .start = function(specification) {
            # If a cluster is already active.
            if (private$.active) {
                # Throw error.
                Exception$cluster_active()
            }

            # Create a permanent separate `R` session.
            private$.cluster <- callr::r_session$new()

            # Create cluster in session based on specification.
            private$.make_cluster(specification)

            # Sanitize the cluster.
            private$.clear()

            # Toggle the active flag.
            private$.toggle_active_state()
        },

        # Stop the cluster in the session.
        .stop = function() {
            # If there is no cluster active.
            if (!private$.active) {
                # Throw.
                Exception$cluster_not_active()
            }

            # Terminate the cluster in the separate `R` session.
            private$.close_cluster()

            # Terminate the separate `R` session.
            private$.cluster$close()

            # Rest the cluster field.
            private$.cluster <- NULL

            # Toggle the active flag.
            private$.toggle_active_state()
        },

        # Sanitize the cluster in the session.
        .clear = function() {
            # Run the clear command in the session.
            private$.cluster$run(function() {
                # Evaluate the expression on the cluster.
                parallel::clusterEvalQ(cluster, rm(list = ls(all.names = TRUE)))
            })

            # Remain silent.
            invisible()
        },

        # Inspect what is on the cluster, not the session.
        .peek = function() {
            # Run the command on the cluster in the session.
            private$.cluster$run(function() {
                # Check what is on the cluster.
                parallel::clusterEvalQ(cluster, ls(all.names = TRUE))
            })
        },

        # Export variables on the cluster in the session.
        .export = function(variables, environment) {
            # Create new environment only with the variables that are being exported.
            new_environment <- new.env()

            # Assign the variables to be exported in the new environment.
            for (variable in variables) {
               # Assign the variables.
               assign(variable, get(variable, environment), new_environment)
            }

            # Export to the cluster via the session.
            private$.cluster$run(function(variables, environment) {
                # The actual export command.
                parallel::clusterExport(cluster, variables, environment)
            }, args = list(variables, new_environment))

            # Remain silent.
            invisible()
        },

        # Evaluate an expression on the cluster in the session.
        .evaluate = function(expression) {
            # Capture the expression.
            capture <- substitute(expression)

           # Perform the evaluation on the cluster via the `R` session.
            private$.cluster$run(function(expression) {
                # Evaluate the expression.
                parallel::clusterCall(cluster, eval, expression)
            }, args = list(capture))
        },

        # Run tasks asynchronously via the cluster in the session.
        .sapply = function(x, fun, ...) {
            # Capture the `...`.
            dots <- list(...)

            # Perform the evaluation from the `R` session.
            private$.cluster$call(function(x, fun, dots) {
                # Run the task.
                output <- do.call(parallel::parSapply, c(list(cluster, x, fun), dots))

                # Return to the session.
                return(output)
            }, args = list(x, fun, dots))
        },

        # Run tasks asynchronously via the cluster in the session.
        .lapply = function(x, fun, ...) {
            # Capture the `...`.
            dots <- list(...)

            # Perform the evaluation from the `R` session.
            private$.cluster$call(function(x, fun, dots) {
                # Run the task.
                output <- do.call(parallel::parLapply, c(list(cluster, x, fun), dots))

                # Return to the session.
                return(output)
            }, args = list(x, fun, dots))
        },

        # Run tasks asynchronously via the cluster in the session.
        .apply = function(x, margin, fun, ...) {
            # Capture the `...`.
            dots <- list(...)

            # Perform the evaluation from the `R` session.
            private$.cluster$call(function(x, margin, fun, dots) {
                # Run the task.
                output <- do.call(parallel::parApply, c(list(cluster, x, margin, fun), dots))

                # Return to the session.
                return(output)
            }, args = list(x, margin, fun, dots))
        },

        # Clear the current output on the backend.
        .clear_output = function() {
            # Clear output.
            private$.output <- NULL
        },

        # Set the output based on the session read.
        .set_output = function() {
            # Get all session output.
            output <- private$.cluster$read()

            # If an error ocurred in the session.
            if (!is.null(output$error)) {
                # Throw error in the main session.
                Exception$async_task_error(output$error)
            }

            # Otherwise, store the relevant results from the output.
            private$.output <- output$result
        },

        # Get the current task state (i.e., what is happening in the session).
        .get_task_state = function() {
            # If the backend does not have an active cluster (i.e., session in this case).
            if (!private$.active) {
                # Throw.
                Exception$cluster_not_active()
            }

            # Create task state object holding the current state.
            task_state <- TaskState$new(private$.cluster)

            return(task_state)
        },

        # Throw an exception if the backend is not ready to be used.
        .throw_if_backend_is_busy = function() {
            # Get task state.
            task_state <- private$.get_task_state()

            # If a task is running.
            if (task_state$task_is_running) {
                # Throw error.
                Exception$async_task_running()
            }

            # If a task is completed with unread results.
            if (task_state$task_is_completed) {
                # Throw error.
                Exception$async_task_completed()
            }
        },

        # Wait for the task to finish and fetch the results.
        .wait_to_fetch_results = function() {
            # Get task state.
            task_state <- private$.get_task_state()

            # If no task has started (i.e., not deployed) on the backend.
            if (task_state$task_not_started) {
                # Throw error.
                Exception$async_task_not_started()
            }

            # If a task is currently running, wait for its completion.
            if (task_state$task_is_running) {
                # Wait for task to finish.
                private$.cluster$poll_process(-1)

                # Read the session and set the output.
                private$.set_output()

            # Otherwise, a completed task awaits results to be read.
            } else {
                # Fetch and set the results right away.
                private$.set_output()
            }
        },

        # Attempt to fetch the results if the task finished.
        .fetch_results = function() {
            # Get task state.
            task_state <- private$.get_task_state()

            # If no task has started (i.e., not deployed) on the backend.
            if (task_state$task_not_started) {
                # Throw error.
                Exception$async_task_not_started()
            }

            # If a task is still running on the backend.
            if (task_state$task_is_running) {
                # Throw error.
                Exception$async_task_running()
            }

            # Otherwise, read the results of a completed task.
            private$.set_output()
        }
    ),

    public = list(
        #' @description
        #' Create a new [`parabar::AsyncBackend`] object.
        #'
        #' @return
        #' An object of class [`parabar::AsyncBackend`].
        initialize = function() { invisible() },

        #' @description
        #' Destroy the current [`parabar::AsyncBackend`] instance.
        #'
        #' @return
        #' An object of class [`parabar::AsyncBackend`].
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
        #' variables.
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

            # Prepare the call.
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
            # Throw if backend is busy.
            private$.throw_if_backend_is_busy()

            # Deploy the task asynchronously.
            private$.sapply(x, fun, ...)
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
            # Throw if backend is busy.
            private$.throw_if_backend_is_busy()

            # Deploy the task asynchronously.
            private$.lapply(x, fun, ...)
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
            # Throw if backend is busy.
            private$.throw_if_backend_is_busy()

            # Validate provided margins.
            Helper$check_array_margins(margin, dim(x))

            # Deploy the task asynchronously.
            private$.apply(x, margin, fun, ...)
        },

        #' @description
        #' Get the output of the task execution.
        #'
        #' @param wait A logical value indicating whether to wait for the task
        #' to finish executing before fetching the results. Defaults to `FALSE`.
        #' See the **Details** section for more information.
        #'
        #' @details
        #' This method fetches the output of the task execution after calling
        #' the `sapply()` method. It returns the output and immediately removes
        #' it from the backend. Subsequent calls to this method will throw an
        #' error if no additional tasks have been executed in the meantime. This
        #' method should be called after the execution of a task.
        #'
        #' If `wait = TRUE`, the method will block the main process until the
        #' backend finishes executing the task and the results are available. If
        #' `wait = FALSE`, the method will immediately attempt to fetch the
        #' results from the background `R` session, and throw an error if the
        #' task is still running.
        #'
        #' @return
        #' A vector, matrix, or list of the same length as `x`, containing the
        #' results of the `fun`. The output format differs based on the specific
        #' operation employed. Check out the documentation for the `apply`
        #' operations of [`parallel::parallel`] for more information.
        get_output = function(wait = FALSE) {
            # Reset the output on exit.
            on.exit({
                # Clear.
                private$.clear_output()
            })

            # If the user wants to wait for the results.
            if (wait) {
                # Wait to fetch the results.
                private$.wait_to_fetch_results()
            } else {
                # Otherwise, try to fetch the results now (i.e., without waiting).
                private$.fetch_results()
            }

            # Return the simplified output.
            return(private$.output)
        }
    ),

    active = list(
        #' @field task_state A list of logical values indicating the state of
        #' the task execution. See the [`parabar::TaskState`] class for more
        #' information on how the statues are determined. The following statuses
        #' are available:
        #' - `task_not_started`: Indicates whether the backend is free. `TRUE`
        #' signifies that no task has been started and the backend is free to
        #' deploy.
        #' - `task_is_running`: Indicates whether a task is currently running on
        #' the backend.
        #' - `task_is_completed`: Indicates whether a task has finished
        #' executing. `TRUE` signifies that the output of the task has not been
        #' fetched. Calling the method `get_option()` will move the output from
        #' the background `R` session to the main `R` session. Once the output
        #' has been fetched, the backend is free to deploy another task.
        task_state = function() {
            # Get a task state instance with the state.
            task_state <- private$.get_task_state()

            # Return a simplified state.
            return(list(
                task_not_started = task_state$task_not_started,
                task_is_running = task_state$task_is_running,
                task_is_completed = task_state$task_is_completed
            ))
        }
    )
)
