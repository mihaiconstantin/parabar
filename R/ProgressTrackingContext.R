#' @include Context.R Bar.R

#' @title
#' ProgressTrackingContext
#'
#' @description
#' This class represents a progress tracking context for interacting with
#' [`parabar::Backend`] implementations via the [`parabar::Service`] interface.
#'
#' @details
#' This class extends the base [`parabar::Context`] class and overrides the
#' [`sapply`][`parabar::Context`] parent method to decorate the backend instance
#' with additional functionality. Specifically, this class creates a temporary
#' file to log the progress of backend tasks, and then creates a progress bar to
#' display the progress of the backend tasks.
#'
#' The progress bar is updated after each backend task execution. The timeout
#' between subsequent checks of the temporary log file is controlled by the
#' [`parabar::Options`] class and defaults to `0.001`. This value can be
#' adjusted via the [`parabar::Options`] instance present in the session
#' [`base::.Options`] list (i.e., see [parabar::set_option()]). For example, to
#' set the timeout to `0.1` we can run `set_option("progress_timeout", 0.1)`.
#'
#' This class is a good example of how to extend the base [`parabar::Context`]
#' class to decorate the backend instance with additional functionality.
#'
#' @examples
#' # Define a task to run in parallel.
#' task <- function(x, y) {
#'     # Sleep a bit.
#'     Sys.sleep(0.15)
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
#' # Get a backend instance that does not support progress tracking.
#' backend <- backend_factory$get("sync")
#'
#' # Create a progress tracking context object.
#' context <- ProgressTrackingContext$new()
#'
#' # Attempt to set the incompatible backend instance.
#' try(context$set_backend(backend))
#'
#' # Get a backend instance that does support progress tracking.
#' backend <- backend_factory$get("async")
#'
#' # Register the backend with the context.
#' context$set_backend(backend)
#'
#' # From now all, all backend operations are intercepted by the context.
#'
#' # Start the backend.
#' context$start(specification)
#'
#' # Create a bar factory.
#' bar_factory <- BarFactory$new()
#'
#' # Get a modern bar instance.
#' bar <- bar_factory$get("modern")
#'
#' # Register the bar with the context.
#' context$set_bar(bar)
#'
#' # Configure the bar.
#' context$configure_bar(
#'     show_after = 0,
#'     format = " > completed :current out of :total tasks [:percent] [:elapsed]"
#' )
#'
#' # Run a task in parallel (i.e., approx. 1.9 seconds).
#' context$sapply(x = 1:25, fun = task, y = 10)
#'
#' # Get the task output.
#' backend$get_output(wait = TRUE)
#'
#' # Change the bar type.
#' bar <- bar_factory$get("basic")
#'
#' # Register the bar with the context.
#' context$set_bar(bar)
#'
#' # Remove the previous bar configuration.
#' context$configure_bar()
#'
#' # Run a task in parallel (i.e., approx. 1.9 seconds).
#' context$sapply(x = 1:25, fun = task, y = 10)
#'
#' # Get the task output.
#' backend$get_output(wait = TRUE)
#'
#' # Close the backend.
#' context$stop()
#'
#' @seealso
#' [`parabar::Context`], [`parabar::Service`], [`parabar::Backend`], and
#' [`parabar::AsyncBackend`].
#'
#' @export
ProgressTrackingContext <- R6::R6Class("ProgressTrackingContext",
    inherit = Context,

    private = list(
        # The progress bar.
        .bar = NULL,

        # Progress bar configuration.
        .bar_config = list(),

        # Validate the type of task provided.
        .validate_task = function(task) {
            # If the task is a primitive.
            if (is.primitive(task)) {
                # Then throw an exception.
                Exception$primitive_as_task_not_allowed()
            }
        },

        # Create a temporary file to log progress from backend tasks.
        .make_log = function() {
            # Get a temporary file name (i.e., OS specific) or a fixed one.
            file_path <- Helper$get_option("progress_log_path")

            # Create the temporary file.
            creation_status <- file.create(file_path, showWarnings = FALSE)

            # If the file creation failed.
            if (!creation_status) {
                # Throw.
                Exception$temporary_file_creation_failed(file_path)
            }

            # Return path of created file.
            return(file_path)
        },

        # Decorate task function to log the progress after each execution.
        .decorate = function(task, log) {
            # Validate the task function provided.
            private$.validate_task(task)

            # Create the language construct to inject.
            injection <- bquote(
                # The injected expression to run after each task execution.
                on.exit({
                    # Acquire an exclusive lock.
                    log_lock <- filelock::lock(.(paste0(log, ".lock")))

                    # Write the line.
                    cat("\n", file = .(log), sep = "", append = TRUE)

                    # Release the lock.
                    filelock::unlock(log_lock)
                })
            )

            # Capture the task body.
            task_body <- body(task)

            # If the body is a call wrapped in a `{` primitive.
            if (Helper$is_of_class(task_body, "{")) {
                # Remove the `{` call.
                task_body <- as.list(task_body)[-1]
            }

            # Update the body of the task function.
            body(task) <- as.call(
                # Coerce the elements to a `list` mode.
                c(
                    # Specify the function part.
                    as.symbol("{"),

                    # Provide the injection.
                    injection,

                    # The task body.
                    task_body
                )
            )

            return(task)
        },

        # Show the progress bar based on the backend task execution.
        .show_progress = function(total, log) {
            # Get the checking delay from options.
            timeout <- Helper$get_option("progress_timeout")

            # Get the waiting time between progress bar updates from options.
            wait <- Helper$get_option("progress_wait")

            # Initialize the bar at the initial starting point.
            do.call(
                private$.bar$create,
                utils::modifyList(
                    list(total = total, initial = 0), private$.bar_config
                )
            )

            # Kick-start the bar.
            private$.bar$update(0)

            # Counter for the number of tasks processed.
            tasks_processed <- 0

            # Counter for the loop cycles without progress bar updates.
            cycles_without_tasks_processed <- 0

            # Maximum allowed loop cycles without progress bar updates.
            allowed_cycles_without_tasks_processed <- ceiling(wait / timeout)

            # While there are still tasks to be processed.
            while (tasks_processed < total) {
                # Get the current number of tasks processed.
                current_tasks_processed <- length(readLines(log, warn = FALSE))

                # Redraw the bar only if the number of tasks processed has increased.
                if (current_tasks_processed > tasks_processed) {
                    # Update the number of tasks processed.
                    tasks_processed <- current_tasks_processed

                    # Reset the cycles without progress bar updates.
                    cycles_without_tasks_processed <- 0

                    # Update the progress bar to completed state.
                    private$.bar$update(tasks_processed)

                    # Jump to next iteration.
                    next
                }

                # Otherwise, record a new cycle without progress bar update.
                cycles_without_tasks_processed <- cycles_without_tasks_processed + 1

                # If the number of cycles without progress bar updates exceeded the allowed number.
                if (cycles_without_tasks_processed > allowed_cycles_without_tasks_processed &&
                    # And the session has results ready to be read (i.e., the task is completed).
                    private$.backend$task_state$task_is_completed
                ) {
                    # Break the loop to interrupt the progress bar updating.
                    break
                }

                # Wait a bit.
                Sys.sleep(timeout)
            }

            # Close and remove the progress bar.
            private$.bar$terminate()
        },

        # Template function for tracking progress of backend operations.
        .execute = function(operation, fun, total) {
            # Create file for logging progress.
            log <- private$.make_log()

            # Clear the temporary file on function exit.
            on.exit({
                # Remove.
                unlink(log)
            })

            # Decorate the task function.
            fun <- private$.decorate(task = fun, log = log)

            # Evaluate the operation now referencing the decorated task.
            eval(operation)

            # Show the progress bar and block the main process.
            private$.show_progress(total = total, log = log)
        }
    ),

    public = list(
        #' @description
        #' Set the backend instance to be used by the context.
        #'
        #' @param backend An object of class [`parabar::Backend`] that supports
        #' progress tracking implements the [`parabar::Service`] interface.
        #'
        #' @details
        #' This method overrides the parent method to validate the backend
        #' provided and guarantee it is an instance of the
        #' [`parabar::AsyncBackend`] class.
        set_backend = function(backend) {
            # Get backend type.
            type <- Helper$get_class_name(backend)

            # If an incompatible backend is provided.
            if (type != "AsyncBackend") {
                # Throw incorrect type error.
                Exception$type_not_assignable(type, "AsyncBackend")
            }

            # Set the backend.
            super$set_backend(backend)
        },

        #' @description
        #' Set the [`parabar::Bar`] instance to be used by the context.
        #'
        #' @param bar An object of class [`parabar::Bar`].
        set_bar = function(bar) {
            # Set the bar.
            private$.bar = bar
        },

        # Set bar configuration.
        #' @description
        #' Configure the [`parabar::Bar`] instance registered with the context.
        #'
        #' @param ... A list of named arguments passed to the `create()` method
        #' of the [`parabar::Bar`] instance. See the documentation of the
        #' specific concrete bar for details (e.g., [`parabar::ModernBar`]).
        configure_bar = function(...) {
            # Store bar options.
            private$.bar_config = list(...)
        },

        #' @description
        #' Run a task on the backend akin to [parallel::parSapply()], but with a
        #' progress bar.
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
            # Prepare the backend operation with early evaluated `...`.
            operation <- bquote(
                do.call(
                    super$sapply, c(list(x = .(x), fun = fun), .(list(...)))
                )
            )

            # Execute the task using the desired backend operation.
            private$.execute(operation = operation, fun = fun, total = length(x))
        },

        #' @description
        #' Run a task on the backend akin to [parallel::parLapply()], but with a
        #' progress bar.
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
            # Prepare the backend operation with early evaluated `...`.
            operation <- bquote(
                do.call(
                    super$lapply, c(list(x = .(x), fun = fun), .(list(...)))
                )
            )

            # Execute the task via the `lapply` backend operation.
            private$.execute(operation = operation, fun = fun, total = length(x))
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
            # Determine the number of task executions.
            total <- prod(dim(x)[margin])

            # Prepare the backend operation with early evaluated `...`.
            operation <- bquote(
                do.call(
                    super$apply, c(list(x = .(x), margin = .(margin), fun = fun), .(list(...)))
                )
            )

            # Execute the task via the `lapply` backend operation.
            private$.execute(operation = operation, fun = fun, total = total)
        }
    ),

    active = list(
        #' @field bar The [`parabar::Bar`] instance registered with the context.
        bar = function() { return(private$.bar) }
    )
)
