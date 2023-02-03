# Blue print for class handling warning issuing.
Warning <- R6::R6Class("Warning")

# Warning for not requesting enough cluster cores.
Warning$requested_cluster_cores_too_low <- function() {
    # Issue the warning.
    warning("Argument `cores` must be greater than 1. Setting to 2.", call. = FALSE)
}

# Warning for requesting too many cluster cores.
Warning$requested_cluster_cores_too_high <- function(max_cores) {
    # Issue the warning.
    warning(paste0("Argument `cores` cannot be larger than ", max_cores, ". Setting to ", max_cores, "."), call. = FALSE)
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

# Warning for using a backend incompatible with progress tracking.
Warning$progress_not_supported_for_backend <- function(backend) {
    # Get backend type.
    type <- Helper$get_class_name(backend)

    # Construct warning message.
    message <- paste0("Progress tracking not supported for backend of type '", type, "'.")

    # Throw the error.
    warning(message, call. = FALSE)
}
