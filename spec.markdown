Weaver
========================

A program for inserting R code into latex (and later html files).  Similar to Sweave, but written in Ruby so as to be easier to maintain (Ruby's text processing features are more powerful) and provide caching functionality that Sweave doesn't.

Caching
------------------------

Should be possible to run only code that has changed since the last run. Two attacks:

  * load rdata.weave at start of each run, and save workspace into rdata.weave when done
  * hash each block to check for changes, only rerun that block if code has changes
    * hash also used to name sink and graphics files

All cached files stored in file-name.weave/

Command-line use
------------------------

weaver example.tex.weave 
 * produces example.tex, and then runs pdflatex to produce example.pdf, and then open to display in preview (previous command must complete succesfully before next is run)
weaver example.html.weave --no-cache
 * produces example.html, not using any cached output (but still caches everything)

How it works
========================

Essentially splits and text file into two parts - R and non R.  R part gets run and then inserted back into latex (graphics).

Types of blocks:
 * no output - contains R code run to set up variables etc for later output
 * raw r output 
 * raw r output with commands used to create it 
 * latex output - output from R functions is inserted into latex document
 * grapic output - R graphic output redirected to a physical graphics device

Also need some way of setting various options - eg. width, height etc.  Could probably do with a bit of R code eg. `<% weaver.width <- 5 %>` and my R code just checks before assigning defaults.

May need to trim out surround whitespace so latex doesn't add artifacts.

no output <% %>
--------------------
Cut out of sources. R code goes in code.r.  Not cached.

latex output <%= %>
--------------------
Need to wrap around with calls to sink (hash.txt)

graphic output <%=g %>
--------------------
May be cached.
Need to wrap lattice graph calls with print, and wrap around with calls to postscript (hash.ps).

r code output <%=r %>
---------------------
Should look like you had entered it into the r console - with R code and output interweaved.  Save into hash.txt.   Will probably need to use source.mvb from the mvbutils package.

Autobuilt R code
========================

 * sets working directory to directory weaver file is located in
 * sets up default widths and heights

Example
========================

Latex input (test.weaver)
---------------------
This is a latex file.  Writing latex makes kitten cry.

<% a <- read.csv("cool.csv") %>

We are doing to do a regression.

<%=r
  b <- lm(x ~ y, a)
	resid(b)
%>

Let's plot those residuals:

<%=g plot(b) %>

Created R code
---------------------

weaver.width = 10
weaver.height = 5

a <- read.csv("cool.csv")

sink("test.weaver/output-asdfadsfasdfa.txt")
source("test.weaver/input-asdfadsfasdfa.txt", echo=T)
sink()

postscript(file="test.weaver/sdfgdsfgsdf.txt", width=weaver.width, height=weaver.height)
plot(b)
dev.off()

Final latex
---------------------

This is a latex file.  Writing latex makes kitten cry.

We are doing to do a regression.

\verbatim{
> b <- lm(x ~ y, a)
> resid(b)
	
 ....

}

Let's plot those residuals:

%insert latex code here
