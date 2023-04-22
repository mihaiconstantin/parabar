#' @include Exception.R

#' @title
#' Specification
#'
#' @description
#' This class contains the information required to start a backend. An instance
#' of this class is used by the `start` method of the [`parabar::Service`]
#' interface.
#'
#' @examples
#' # Create a specification object.
#' specification <- Specification$new()
#'
#' # Set the number of cores.
#' specification$set_cores(cores = 4)
#'
#' # Set the cluster type.
#' specification$set_type(type = "psock")
#'
#' # Get the number of cores.
#' specification$cores
#'
#' # Get the cluster type.
#' specification$type
#'
#' # Attempt to set too many cores.
#' specification$set_cores(cores = 100)
#'
#' # Check that the cores were reasonably set.
#' specification$cores
#'
#' # Allow the object to determine the adequate cluster type.
#' specification$set_type(type = NULL)
#'
#' # Check the type determined.
#' specification$type
#'
#' # Attempt to set an invalid cluster type.
#' specification$set_type(type = "invalid")
#'
#' # Check that the type was set to `psock`.
#' specification$type
#'
#' @seealso
#' [`parabar::Service`], [`parabar::Backend`], [`parabar::SyncBackend`], and
#' [`parabar::AsyncBackend`].
#'
#' @export
Specification <- R6::R6Class("Specification",
    private = list(
        # Number of cores for the cluster.
        .cores = NULL,

        # Cluster type (i.e., "fork" or "psock").
        .type = NULL,

        # Supported cluster types.
        .types = c(unix = "fork", windows = "psock"),

        # Determine the number of available cores on the machine.
        .get_available_cores = function() {
            # Determine the number of cores.
            return(parallel::detectCores())
        },

        # Determine the number of usable cores.
        .determine_usable_cores = function(available_cores) {
            # If the machine has less than two cores.
            if (available_cores < 2) {
                # Throw.
                Exception$not_enough_cores()
            }

            # If the machine has more than two cores.
            if (available_cores > 2) {
                # Ensure a core is not used as part of the available pool.
                available_cores <- available_cores - 1
            }

            return(available_cores)
        },

        # Determine the number of nodes to create in the cluster,
        .validate_requested_cores = function(requested_cores) {
            # Get the number of cores available on the machine.
            available_cores <- private$.get_available_cores()

            # Get the number of cores that can be used.
            usable_cores <- private$.determine_usable_cores(available_cores)

            # If not enough cores are requested.
            if (requested_cores < 2) {
                # Warn the users.
                Warning$requested_cluster_cores_too_low()

                # Allow two cores.
                return(2)
            }

            # If more cores than available are requested.
            if (requested_cores > usable_cores) {
                # Warn the users.
                Warning$requested_cluster_cores_too_high(usable_cores)

                # Allow all available cores.
                return(usable_cores)
            }

            # Otherwise, honor the request.
            return(requested_cores)
        },

        # Determine the type of the cluster to use.
        .validate_requested_type = function(requested_type) {
            # If no type is explicitly requested.
            if (is.null(requested_type)) {
                if (.Platform$OS.type == "unix") {
                    # Select type for Unix.
                    return(toupper(private$.types["unix"]))
                } else {
                    # Select type for Windows.
                    return(toupper(private$.types["windows"]))
                }
            }

            # If the requested type is unknown.
            if (!tolower(requested_type) %in% private$.types) {
                # Warn if an unknown cluster is provided.
                Warning$requested_cluster_type_not_supported(private$.types)

                # Default to 'PSOCK'.
                return(toupper(private$.types["windows"]))
            } else {
                # If the platform is not Unix.
                if (.Platform$OS.type == "windows" && requested_type == private$.types["unix"]) {
                    # Warn if a Unix cluster is requested on Windows.
                    Warning$requested_cluster_type_not_compatible(private$.types)

                    # Default to 'PSOCK'.
                    return(toupper(private$.types["windows"]))
                }

                # Set the cluster as requested.
                return(toupper(requested_type))
            }
        }
    ),

    public = list(
        #' @description
        #' Set the number of nodes to use in the cluster.
        #'
        #' @param cores The number of nodes to use in the cluster.
        #'
        #' @details
        #' This method also performs a validation of the requested number of
        #' cores, ensuring that the the value lies between `2` and
        #' `parallel::detectCores() - 1`.
        set_cores = function(cores) {
            # Set cores.
            private$.cores <- private$.validate_requested_cores(cores)
        },

        #' @description
        #' Set the type of cluster to create.
        #'
        #' @param type The type of cluster to create. Possible values are
        #' `"fork"` and `"psock"`. Defaults to `"psock"`.
        #'
        #' @details
        #' If no type is explicitly requested (i.e., `type = NULL`), the type is
        #' determined based on the operating system. On Unix-like systems, the
        #' type is set to `"fork"`, while on Windows systems, the type is set to
        #' `"psock"`. If an unknown type is requested, a warning is issued and
        #' the type is set to `"psock"`.
        set_type = function(type) {
            # Set type.
            private$.type <- private$.validate_requested_type(type)
        }
    ),

    active = list(
        #' @field cores The number of nodes to use in the cluster creation.
        cores = function() { return(private$.cores) },

        #' @field type The type of cluster to create.
        type = function() { return(private$.type) },

        #' @field types The supported cluster types.
        types = function() { return(private$.types) }
    )
)
