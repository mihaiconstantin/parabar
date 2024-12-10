#' @include Helper.R

#' @title
#' Package Warnings
#'
#' @description
#' This class contains static methods for throwing warnings with informative
#' messages.
#'
#' @format
#' \describe{
#'   \item{\code{Warning$requested_cluster_cores_too_low()}}{Warning for not requesting enough cluster cores.}
#'   \item{\code{Warning$requested_cluster_cores_too_high()}}{Warning for requesting too many cluster cores.}
#'   \item{\code{Warning$requested_cluster_type_not_supported()}}{Warning for requesting an unsupported cluster type.}
#'   \item{\code{Warning$progress_not_supported_for_backend()}}{Warning for using a backend incompatible with progress tracking.}
#'   \item{\code{Warning$error_in_backend_finalizer()}}{Warning for errors in the backend finalizer during garbage collection.}
#' }
#'
#' @export
Warning <- R6::R6Class("Warning",
    cloneable = FALSE
)

# Warning for not requesting enough cluster cores.
Warning$requested_cluster_cores_too_low <- function() {
    # Construct the message.
    message <- paste0("Argument `cores` too low. Setting to 1.")

    # Issue the warning.
    warning(message, call. = FALSE)
}

# Warning for requesting too many cluster cores.
Warning$requested_cluster_cores_too_high <- function(max_cores) {
    # Construct the message.
    message <- paste0("Argument `cores` cannot be larger than ", max_cores, ". Setting to ", max_cores, ".")

    # Issue the warning.
    warning(message, call. = FALSE)
}

# Warning for requesting an unsupported cluster type.
Warning$requested_cluster_type_not_supported <- function(supported_types) {
    # Issue the warning.
    warning(
        paste0(
            "Argument `type` must be ",
            paste0("'", supported_types, "'", collapse = " or ", sep = ""), ". Defaulting to '", supported_types["windows"], "'."
        ),
        call. = FALSE
    )
}

# Warning for requesting an incompatible cluster type.
Warning$requested_cluster_type_not_compatible <- function(supported_types) {
    # Issue the warning.
    warning(
        paste0(
            "Requested cluster type not compatible. Defaulting to '", supported_types["windows"], "'."
        ),
        call. = FALSE
    )
}

# Warning for using a backend incompatible with progress tracking.
Warning$progress_not_supported_for_backend <- function(backend) {
    # Get backend type.
    type <- Helper$get_class_name(backend)

    # Construct warning message.
    message <- paste0("Progress tracking not supported for backend of type '", type, "'.")

    # Throw the error.
    warning(message, call. = FALSE)
}

# Warning for errors in the backend finalizer during garbage collection.
Warning$error_in_backend_finalizer <- function(backend, error) {
    # Get the backend type.
    backend_type <- Helper$get_class_name(backend)

    # Construct the message.
    message <- paste0("Caught error in '", backend_type ,"' finalizer: '", error$message, "'.")

    # Issue the warning.
    warning(message, call. = FALSE)
}
