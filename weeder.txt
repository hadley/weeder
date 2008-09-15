Weeder
====================

Weeder is a ruby script that generates R documentation from inline comments.  This allows you to keep your code and documentation together, making it easier to see when one is out of date.  Assumes that the R files have been organised in standard package structure.

How it works
------------

It parses all r files in the given directory, builds up the documentation latex files and then outputs to ../man/.

	/($#.*^)+ ([a-z0-9_.]+)\s*<-\s*function\((.*?)\).*$}($#.*^)+/

Format
------

# Title
# Brief description.
#
# Full details
# May span many lines.
#
# @alias
# @arguments list of function arguments 
# @arguments in same order as function def
# @value what the function returns
# @value multiple returns correspond to 
# @seealso 
# @references
# @keyword
name <- function (arg1, arg2=3, ...) {
	
}
# #examples go here
# print("hi!")

Output
------

\name{name}. From parsing function def
\title{Title}.  First line of comments.
\description{...}. 2nd line to first break in comments.
\usage{fun(arg1, arg2, ...)}.  From parsing function def.
\arguments{...}.  From @param + function def to get names
 \item{arg_i}{Description of arg_i.}
\details{...}.  First break in comment to options..
\value{...}.  From @return
  \item{comp_i}{Description of comp_i.}
\references{...}.  From @ref
\note{...}.  Not available
\author{...}.  From @author, or set by default to Hadley Wickham
\seealso{...}.  From @see
\examples{...}.  From comment block immediately following function - NOT currently implemented
\keyword{key}.  From @keyword.
\alias{topic}.  name + @alias
