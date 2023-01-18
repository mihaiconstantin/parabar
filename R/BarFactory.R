#' @include constants.R BasicBar.R ModernBar.R

# Factory for fetching bar types of different instances.
BarFactory <- R6::R6Class("BarFactory",
    public = list(
        get = function(type) {
            return(
                switch(type,
                    basic = BasicBar$new(),
                    modern = ModernBar$new(),
                    stop(.__ERRORS__$not_developed)
                )
            )
        }
    )
)
