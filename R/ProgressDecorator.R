#' @include Context.R Bar.R

# Blueprint for creating a progress tracking context manager for consuming backend APIs.
ProgressDecorator <- R6::R6Class("ProgressDecorator",
    inherit = Context,

    private = list(
        # The progress bar.
        .bar = NULL,

        # Progress bar configuration.
        .bar_config = NULL,

        # Create a temporary file to log progress from backend tasks.
        .make_log = function() {
            # Get a temporary file name (i.e., OS specific).
            file_path <- tempfile()

            # Create the temporary file.
            creation_status <- file.create(file_path)

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
            # Get the body of the function to patch.
            fun_body <- body(task)

            # Get the length of the body.
            length_fun_body <- length(fun_body)

            # Insert the expression.
            fun_body[[length_fun_body + 1]] <- substitute(
                # The injected expression.
                on.exit({
                    cat("\n", file = log, sep = "", append = TRUE)
                }),

                # The environment to use for substitution.
                parent.frame(n = 1)
            )

            # Reorder the body.
            fun_body <- fun_body[c(1, (length_fun_body + 1), 2:length_fun_body)]

            # Attach the function body and return it.
            body(task) <- fun_body

            return(task)
        },

        # Show the progress bar based on the backend task execution.
        .show_progress = function(total, log) {
            # Get the checking delay from options.
            timeout <- getOption("parabar.progress.timeout", default = 0.001)

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

            # While there are still tasks1 to be processed.
            while (tasks_processed < total) {
                # Get the current number of tasks processed.
                current_tasks_processed <- length(readLines(log, warn = FALSE))

                # Redraw the bar only if the number of tasks processed has increased.
                if (current_tasks_processed > tasks_processed) {
                    # Update the number of tasks processed.
                    tasks_processed <- current_tasks_processed

                    # Update the progress bar to completed state.
                    private$.bar$update(tasks_processed)
                }

                # Wait a bit.
                Sys.sleep(timeout)
            }

            # Close and remove the progress bar.
            private$.bar$terminate()
        }
    ),

    public = list(
        # Override to validate the backend provided.
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

        # Set progress bar instance.
        set_bar = function(bar) {
            # Set the bar.
            private$.bar = bar
        },

        # Set bar configuration.
        configure_bar = function(...) {
            # Store bar options.
            private$.bar_config = list(...)
        },

        # Run the task with a progress bar.
        sapply = function(x, fun, ...) {
            # Create file for logging progress.
            log <- private$.make_log()

            # Clear the temporary file on function exit.
            on.exit({
                # Remove.
                unlink(log)
            })

            # Decorate task function.
            task <- private$.decorate(task = fun, log = log)

            # Execute the decorated task.
            super$sapply(x = x, fun = task, ...)

            # Show the progress bar and block the main process.
            private$.show_progress(total = length(x), log = log)
        }
    ),

    active = list(
        # Get the progress bar instance.
        bar = function() { return(private$.bar) }
    )
)
