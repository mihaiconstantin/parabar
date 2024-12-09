% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BackendService.R
\name{BackendService}
\alias{BackendService}
\title{BackendService}
\description{
This is an interface that defines the operations available on a
\code{\link{Backend}} implementation. Backend implementations and the
\code{\link{Context}} class must implement this interface.
}
\seealso{
\code{\link{Backend}}, \code{\link{SyncBackend}}, \code{\link{AsyncBackend}},
and \code{\link{Context}}.
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-BackendService-new}{\code{BackendService$new()}}
\item \href{#method-BackendService-start}{\code{BackendService$start()}}
\item \href{#method-BackendService-stop}{\code{BackendService$stop()}}
\item \href{#method-BackendService-clear}{\code{BackendService$clear()}}
\item \href{#method-BackendService-peek}{\code{BackendService$peek()}}
\item \href{#method-BackendService-export}{\code{BackendService$export()}}
\item \href{#method-BackendService-evaluate}{\code{BackendService$evaluate()}}
\item \href{#method-BackendService-sapply}{\code{BackendService$sapply()}}
\item \href{#method-BackendService-lapply}{\code{BackendService$lapply()}}
\item \href{#method-BackendService-apply}{\code{BackendService$apply()}}
\item \href{#method-BackendService-get_output}{\code{BackendService$get_output()}}
\item \href{#method-BackendService-clone}{\code{BackendService$clone()}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-new"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-new}{}}}
\subsection{Method \code{new()}}{
Create a new \code{\link{BackendService}} object.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$new()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
Instantiating this class will throw an error.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-start"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-start}{}}}
\subsection{Method \code{start()}}{
Start the backend.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$start(specification)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{specification}}{An object of class \code{\link{Specification}}
that contains the backend configuration.}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
This method returns void. The resulting backend must be stored in the
\code{.cluster} private field on the \code{\link{Backend}} abstract class,
and accessible to any concrete backend implementations via the active
binding \code{cluster}.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-stop"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-stop}{}}}
\subsection{Method \code{stop()}}{
Stop the backend.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$stop()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
This method returns void.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-clear"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-clear}{}}}
\subsection{Method \code{clear()}}{
Remove all objects from the backend. This function is equivalent to
calling \code{rm(list = ls(all.names = TRUE))} on each node in the
backend.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$clear()}\if{html}{\out{</div>}}
}

\subsection{Details}{
This method is ran by default when the backend is started.
}

\subsection{Returns}{
This method returns void.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-peek"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-peek}{}}}
\subsection{Method \code{peek()}}{
Inspect the backend for variables available in the \code{.GlobalEnv}.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$peek()}\if{html}{\out{</div>}}
}

\subsection{Returns}{
This method returns a list of character vectors, where each element
corresponds to a node in the backend. The character vectors contain
the names of the variables available in the \code{.GlobalEnv} on each
node.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-export"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-export}{}}}
\subsection{Method \code{export()}}{
Export variables from a given environment to the backend.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$export(variables, environment)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{variables}}{A character vector of variable names to export.}

\item{\code{environment}}{An environment object from which to export the
variables.}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
This method returns void.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-evaluate"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-evaluate}{}}}
\subsection{Method \code{evaluate()}}{
Evaluate an arbitrary expression on the backend.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$evaluate(expression)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{expression}}{An unquoted expression to evaluate on the backend.}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
This method returns the result of the expression evaluation.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-sapply"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-sapply}{}}}
\subsection{Method \code{sapply()}}{
Run a task on the backend akin to \code{\link[parallel:clusterApply]{parallel::parSapply()}}.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$sapply(x, fun, ...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{x}}{An atomic vector or list to pass to the \code{fun} function.}

\item{\code{fun}}{A function to apply to each element of \code{x}.}

\item{\code{...}}{Additional arguments to pass to the \code{fun} function.}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
This method returns void. The output of the task execution must be
stored in the private field \code{.output} on the \code{\link{Backend}}
abstract class, and is accessible via the \code{get_output()} method.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-lapply"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-lapply}{}}}
\subsection{Method \code{lapply()}}{
Run a task on the backend akin to \code{\link[parallel:clusterApply]{parallel::parLapply()}}.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$lapply(x, fun, ...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{x}}{An atomic vector or list to pass to the \code{fun} function.}

\item{\code{fun}}{A function to apply to each element of \code{x}.}

\item{\code{...}}{Additional arguments to pass to the \code{fun} function.}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
This method returns void. The output of the task execution must be
stored in the private field \code{.output} on the \code{\link{Backend}}
abstract class, and is accessible via the \code{get_output()} method.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-apply"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-apply}{}}}
\subsection{Method \code{apply()}}{
Run a task on the backend akin to \code{\link[parallel:clusterApply]{parallel::parApply()}}.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$apply(x, margin, fun, ...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{x}}{An array to pass to the \code{fun} function.}

\item{\code{margin}}{A numeric vector indicating the dimensions of \code{x} the
\code{fun} function should be applied over. For example, for a matrix,
\code{margin = 1} indicates applying \code{fun} rows-wise, \code{margin = 2}
indicates applying \code{fun} columns-wise, and \code{margin = c(1, 2)}
indicates applying \code{fun} element-wise. Named dimensions are also
possible depending on \code{x}. See \code{\link[parallel:clusterApply]{parallel::parApply()}} and
\code{\link[base:apply]{base::apply()}} for more details.}

\item{\code{fun}}{A function to apply to \code{x} according to the \code{margin}.}

\item{\code{...}}{Additional arguments to pass to the \code{fun} function.}
}
\if{html}{\out{</div>}}
}
\subsection{Returns}{
This method returns void. The output of the task execution must be
stored in the private field \code{.output} on the \code{\link{Backend}}
abstract class, and is accessible via the \code{get_output()} method.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-get_output"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-get_output}{}}}
\subsection{Method \code{get_output()}}{
Get the output of the task execution.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$get_output(...)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{...}}{Additional optional arguments that may be used by concrete
implementations.}
}
\if{html}{\out{</div>}}
}
\subsection{Details}{
This method fetches the output of the task execution after calling
the \code{sapply()} method. It returns the output and immediately removes
it from the backend. Therefore, subsequent calls to this method are
not advised. This method should be called after the execution of a
task.
}

\subsection{Returns}{
A vector, matrix, or list of the same length as \code{x}, containing the
results of the \code{fun}. The output format differs based on the specific
operation employed. Check out the documentation for the \code{apply}
operations of \code{\link[parallel:parallel-package]{parallel::parallel}} for more information.
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-BackendService-clone"></a>}}
\if{latex}{\out{\hypertarget{method-BackendService-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{BackendService$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
