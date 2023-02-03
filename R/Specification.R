#' @include Exception.R

# Blueprint for determining and holding cluster specifications.
Specification <- R6::R6Class("Specification",
    private = list(
        # Number of cores for the cluster.
        .cores = NULL,

        # Cluster type (i.e., "fork" or "psock").
        .type = NULL,

        # Supported cluster types.
        .types = c(unix = "fork", windows = "psock"),

        # Determine the number of usable cores.
        .get_available_cores = function() {
            # Get the number of available cores.
            available <- parallel::detectCores()

            # If the machine has less than two cores.
            if (available < 2) {
                # Throw.
                Exception$not_enough_cores()
            }

            # If the machine has more than two cores.
            if (available > 2) {
                # Ensure a core is not used as part of the available pool.
                available <- available - 1
            }

            return(available)
        },

        # Determine the number of nodes to create in the cluster,
        .validate_requested_cores = function(requested_cores) {
            # Get the number of cores that can be used.
            available_cores <- private$.get_available_cores()

            # If not enough cores are requested.
            if (requested_cores < 2) {
                # Warn the users.
                Warning$requested_cluster_cores_too_low()

                # Allow two cores.
                return(2)
            }

            # If more cores than available are requested.
            if (requested_cores > available_cores) {
                # Warn the users.
                Warning$requested_cluster_cores_too_high(available_cores)

                # Allow all available cores.
                return(available_cores)
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
                # Set the cluster as requested.
                return(toupper(requested_type))
            }
        }
    ),

    public = list(
        # Validate and set the number of cores based on availability.
        set_cores = function(cores) {
            # Set cores.
            private$.cores <- private$.validate_requested_cores(cores)
        },

        # Set or select the type of cluster to create.
        set_type = function(type) {
            # Set type.
            private$.type <- private$.validate_requested_type(type)
        }
    ),

    active = list(
        # Get the number of cores.
        cores = function() { return(private$.cores) },

        # Get the cluster type.
        type = function() { return(private$.type) }
    )
)
