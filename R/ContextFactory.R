#' @include Exception.R Context.R ProgressDecorator.R

# Factory for fetching context instances (i.e., for managing and decorating backends).
ContextFactory <- R6::R6Class("ContextFactory",
    public = list(
        get = function(type) {
            return(
                switch(type,
                    regular = Context$new(),
                    progress = ProgressDecorator$new(),
                    Exception$feature_not_developed()
                )
            )
        }
    )
)
