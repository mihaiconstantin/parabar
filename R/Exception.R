#' @include Helper.R

#' @title
#' Package Exceptions
#'
#' @description
#' This class contains static methods for throwing exceptions with informative
#' messages.
#'
#' @format
#' \describe{
#'   \item{\code{Exception$abstract_class_not_instantiable(object)}}{Exception for instantiating abstract classes or interfaces.}
#'   \item{\code{Exception$method_not_implemented()}}{Exception for calling methods without an implementation.}
#'   \item{\code{Exception$feature_not_developed()}}{Exception for running into things not yet developed.}
#'   \item{\code{Exception$not_enough_cores()}}{Exception for requesting more cores than available on the machine.}
#'   \item{\code{Exception$cluster_active()}}{Exception for attempting to start a cluster while another one is active.}
#'   \item{\code{Exception$cluster_not_active()}}{Exception for attempting to stop a cluster while not active.}
#'   \item{\code{Exception$async_task_not_started()}}{Exception for reading results while an asynchronous task has not yet started.}
#'   \item{\code{Exception$async_task_running()}}{Exception for reading results while an asynchronous task is running.}
#'   \item{\code{Exception$async_task_completed()}}{Exception for reading results while a completed asynchronous task has unread results.}
#'   \item{\code{Exception$async_task_error(error)}}{Exception for errors while running an asynchronous task.}
#'   \item{\code{Exception$stop_busy_backend_not_allowed()}}{Exception for stopping a busy backend without intent.}
#'   \item{\code{Exception$temporary_file_creation_failed()}}{Exception for reading results while an asynchronous task is running.}
#'   \item{\code{Exception$type_not_assignable(actual, expected)}}{Exception for when providing incorrect object types.}
#'   \item{\code{Exception$unknown_package_option(option)}}{Exception for when requesting unknown package options.}
#'   \item{\code{Exception$primitive_as_task_not_allowed()}}{Exception for when decorating primitive functions with progress tracking.}
#'   \item{\code{Exception$array_margins_not_compatible(actual, allowed)}}{Exception for using improper margins in the `BackendService$apply` operation.}
#' }
#'
#' @export
Exception <- R6::R6Class("Exception",
    cloneable = FALSE
)

# Exception for instantiating abstract classes or interfaces.
Exception$abstract_class_not_instantiable <- function(object) {
    if (missing(object)) {
        # Throw the error.
        stop("Abstract class cannot to be instantiated.", call. = FALSE)
    } else {
        # Construct exception message.
        message <- paste0("Abstract class '", Helper$get_class_name(object), "' cannot to be instantiated.")

        # Throw the error.
        stop(message, call. = FALSE)
    }
}

# Exception for calling methods without an implementation (i.e., lacking override).
Exception$method_not_implemented <- function() {
    # Throw the error.
    stop("Abstract method is not implemented.", call. = FALSE)
}

# Exception for running into things not yet developed.
Exception$feature_not_developed <- function() {
    # Throw the error.
    stop("Not supported. Please request at 'https://github.com/mihaiconstantin/parabar/issues'.", call. = FALSE)
}

# Exception for requesting more cores than available on the machine.
Exception$not_enough_cores <- function() {
    # Throw the error.
    stop("Not enough cores available on the machine.", call. = FALSE)
}

# Exception for attempting to start a cluster while another one is active.
Exception$cluster_active <- function() {
    # Throw the error.
    stop("A cluster is already active. Please stop it before starting a new one.", call. = FALSE)
}

# Exception for attempting to stop a cluster while not active.
Exception$cluster_not_active <- function() {
    # Throw the error.
    stop("No active cluster. Please start one.", call. = FALSE)
}

# Exception for reading results while an asynchronous task has not yet started.
Exception$async_task_not_started <- function() {
    # Throw the error.
    stop("No task deployed to the backend.", call. = FALSE)
}

# Exception for reading results while an asynchronous task is running.
Exception$async_task_running <- function() {
    # Throw the error.
    stop("A task is currently running.", call. = FALSE)
}

# Exception for reading results while a completed asynchronous task has unread results.
Exception$async_task_completed <- function() {
    # Throw the error.
    stop("A task is completed with unread results.", call. = FALSE)
}

# Exception for errors in the session while running an asynchronous task.
Exception$async_task_error <- function(error) {
    # Throw the error.
    stop(error)
}

# Exception for stopping a busy backend without intent.
Exception$stop_busy_backend_not_allowed <- function() {
    # Construct exception message.
    message <- "Cannot stop a busy backend when option `stop_forceful = FALSE`."

    # Throw the error.
    stop(message, call. = FALSE)
}

# Exception for reading results while an asynchronous task is running.
Exception$temporary_file_creation_failed <- function(path) {
    # Construct exception message.
    message <- paste0("Failed to create file '", path, "'.")

    # Throw the error.
    stop(message, call. = FALSE)
}

# Exception for when providing incorrect object types.
Exception$type_not_assignable <- function(actual, expected) {
    # Construct exception message.
    message = paste0("Argument of type '", actual, "' is not assignable to parameter of type '", expected, "'.")

    # Throw the error.
    stop(message, call. = FALSE)
}

# Exception for when requesting unknown package options.
Exception$unknown_package_option <- function(option) {
    # Construct exception message.
    message = paste0("Unknown package option '", option, "'.")

    # Throw the error.
    stop(message, call. = FALSE)
}

# Exception for trying to decorate a primitive in a progress tracking context.
Exception$primitive_as_task_not_allowed <- function() {
    # Construct exception message.
    message = paste0("Cannot decorate primitive function with progress tracking.")

    # Throw the error.
    stop(message, call. = FALSE)
}

# Exception for providing incompatible margins in the `apply` operation.
Exception$array_margins_not_compatible <- function(margins, dimensions) {
    # Convert the margins to character.
    margins <- paste(margins, collapse = ", ")

    # Convert the dimensions to character.
    dimensions <- paste(dimensions, collapse = ", ")

    # Construct exception message.
    message = paste0(
        "Margins {", margins, "} not compatible with array dimensions {", dimensions, "}."
    )

    # Throw the error.
    stop(message, call. = FALSE)
}
