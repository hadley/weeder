Weaver
=====================

A program for inserting R code into latex (and later html files).  Similar to Sweave, but written in Ruby so as to be easier to maintain (Ruby's text processing features are more powerful) and provide caching functionality that Sweave doesn't.

Caching
------------------------

Should be possible to run only code that has changed since the last run. Two attacks

	* load example.r.weave at start of each run, and save workspace into example.r.weave when done
	* hash each block to check for changes, only rerun that block if code has changes
		* hash also used to name sink and graphics files

Command-line use
------------------------

weaver example.tex.weave 
 * produces example.tex, and then runs pdflatex to produce example.pdf
weaver example.html.weave --no-cache
 * produces example.html, not using any cached output

Essentially splits and text file into two parts - R and non R.  R part gets run and then inserted back into latex (graphics).

Types of blocks:
 * no output - contains R code run to set up variables etc for later output
 * raw r output 
 * raw r output with commands used to create it 
 * latex output - output from R functions is inserted into latex document
 * grapic output - R graphic output redirected to a physical graphics device

no output <% %>
--------------------
Always run.
Cut out of sources. R code goes in

latex output <%= %>
--------------------
May be cached.
Sink to a text file.

graphic output <%g %>
--------------------
May be cached.
Need to wrap lattice graph calls with print, and wrap around with calls to postscript.