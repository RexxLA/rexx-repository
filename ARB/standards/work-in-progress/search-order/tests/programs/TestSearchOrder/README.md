# Test Search Order

A program to test the Search Order

Features:

* "Call Test" and then "Call 'test'" (allows to check for case-sensitivity)
* See whether search is directory-first or extension-first (special tailored tests for ooRexx and Regina)
* Same (caller) directory calls
* Current directory tests
* PATH directory tests (PATH is modified so that it has only one directory -- that's enough)
* Downward-relative directory tests (i.e., "Call 'lib/test.rex'")
* Dot-relative directory tests (i.e., "Call './test.rex'")
* Dotdot-relative directory tests (i.e., "Call. '../test.rex'")

To do:

* There's a "debugLevel" variable in 'subdir/dotdotsame/same/main.rex' that allows control of verbosity. Change that to a program argument, expand and document.
* In-program documentation.
* Backslash-relative directory tests (Windows-only) (i.e., "Call '\\some\\path\\test.rex'").
* Drive-relative tests (Windows-only) (i.e., "Call 'D:relative\\path\\test.rex'").
* Drive-absolute tests (Windows-only) (i.e., "Call 'D:\\some\\path\\test.rex'").
* The three above, but with UNC "\\\\server\\share".
* Add support for new interpreters.

Works in

* ooRexx (tested with 5.1.0 under Windows 11 Pro, but should work with other versions).
* Regina (tested with 3.9.5 under Ubuntu 20.04 [wsl2], but should work with other versions).

Downloads:

* [Here](testsearchorder.zip)

Installation and running the test:

* Unzip [testsearchorder.zip](testsearchorder.zip) and execute testsearchorder.rex in the testsearchorder folder.
