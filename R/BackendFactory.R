#' @include Exception.R SyncBackend.R AsyncBackend.R

# Factory for fetching backend instances of different types.
BackendFactory <- R6::R6Class("BackendFactory",
    public = list(
        get = function(type) {
            return(
                switch(type,
                    sync = SyncBackend$new(),
                    async = AsyncBackend$new(),
                    Exception$feature_not_developed()
                )
            )
        }
    )
)
