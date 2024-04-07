(There is a bifs.cmd but bifs.bat is more comprehensive.)

REXX COMPATIBILITY KIT (RCK) - old comments.

There are several scattered sources of example results from Rexx programs.
The idea of the RCK is to gather these and re-organise them into a
REXXLA-endorsed test suite.  The tests would be a way of testing conformance to
the American National Standard for Rexx, although the tests themselves have no
connection to ANSI.

Components of test kits come in various styles:

A) The simplest test is a sequence of SAY statements together with a file
showing what the answers should be.  Staying simple avoids possible problems
where the test fails for reasons other than failure in the feature it was meant
to be testing.  The file of results may need to be different for different
operating systems just because of line end conventions.

B) Nearly as simple is a sequence of "if exp \== answer then exit" statements.
This is a "self-test" in the sense that the output of the test can directly show
success or failure.

C) A series of "call SpecialRoutine exp,answer" statements involves quite a bit
more mechanism but allows for logging of failures with details.

D) A file with lines containing "exp" and "answer" pairs can be the subject
of a test program, so that many pairs can be tested without making the test
program large.

E) Generating a series of "call SpecialRoutine exp,answer" statements from some
test specification allows tests to be tailored for ASCII-or-EBCDIC versions,
and other external factors.

Obviously there are other possible variations.

For the RCK, it seems sensible to use style B in general.  Where the output is
voluminous, eg checking the ERRORTEXT built-in, then style A would be suitable.
Testing combinations of operator and operand values may be better as Style C.

There follows an account of the buildup of the RCK suite:

May 1999:

Tests constructed from the examples in the book "The REXX Language" and examples
from the REGINA implementation for the built-ins ABBREV ABS ARG CENTER CHANGESTR
COMPARE COPIES COUNTSTR DATATYPE DELSTR DELWORD DIGITS FORM FORMAT FUZZ INSERT
LASTPOS LEFT LENGTH MAX MIN OVERLAY POS RANDOM REVERSE RIGHT SIGN SPACE STRIP
SUBSTR SUBWORD TRANSLATE VERIFY WORD WORDINDEX WORDLENGTH WORDPOS WORDS XRANGE
