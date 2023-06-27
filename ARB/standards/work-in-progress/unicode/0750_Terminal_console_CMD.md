# Terminal, console, CMD

## ARB recommendations

(TBD)

## Draft Notes

> (René) Describing the right environment for the tests.


## C locale

### [What is the difference between C.UTF-8 and en_US.UTF-8 locales?](https://stackoverflow.com/questions/55673886/what-is-the-difference-between-c-utf-8-and-en-us-utf-8-locales)  
jlf: looking at that because of this [blog](https://lucumr.pocoo.org/2014/5/12/everything-about-unicode/)
from Armin Ronacher (search for "C.UTF-8").

In general C is for computer, en_US is for people in US who speak English (and
other people who want the same behaviour).  
The for computer means that the strings are sometime more standardized (but still
in English), so an output of a program could be read from another program.  
With en_US, strings could be more user-friendly, but possibly less stable. 

Note: locales are not just for translation of strings, but also for collation
(alphabetic order, numbers (e.g. thousand separator), currency (I think it is
safe to predict that $ and 2 decimal digits will remain), months, day of weeks, etc.

Programs that read from other programs should set C before opening the pipe, so
it should not really matter.

Note: Micro-optimization will prescribe C/C.UTF-8 locale: no translation of files
(gettext), and simple rules on collation and number formatting, but this should
be visible only on server side.

### [Python "Click" Unicode Support](https://click.palletsprojects.com/en/8.1.x/unicode-support/)

Click has to take extra care to support Unicode text in different environments.

In Python 3.7 and later you will no longer get a RuntimeError in many cases thanks
to PEP 538 and PEP 540, which changed the default assumption in unconfigured
environments. This doesn’t change the general issue that your locale may be misconfigured.

jlf: [Click](https://github.com/pallets/click/) is cited by Armin Ronacher when talking
about the Unicode text model in Python 3. Comment about [old version](https://click.palletsprojects.com/en/5.x/python3/#python-3-surrogate-handling)
but worth reading.

jlf: TBD test cases to be analyzed.


### [Python "Click" Windows Console Notes](https://click.palletsprojects.com/en/8.1.x/wincmd/)

Click emulates output streams on Windows to support unicode to the Windows console
through separate APIs and we perform different decoding of parameters.

jlf: Review TBD


### [Python PEP 538 – Coercing the legacy C locale to a UTF-8 based locale](https://peps.python.org/pep-0538/)

Status: Final  
Created: 28-Dec-2016  
Python-Version: 3.7

This PEP proposes that independently of the UTF-8 mode proposed in PEP 540, the
way the CPython implementation handles the default C locale be changed to be
roughly equivalent to the following existing configuration settings (supported
since Python 3.1):

        LC_CTYPE=C.UTF-8
        PYTHONIOENCODING=utf-8:surrogateescape

jlf: Review TBD


### [Python PEP 540 – Add a new UTF-8 Mode](https://peps.python.org/pep-0540/)
Status: Final  
Created: 05-Jan-2016  
Python-Version: 3.7

Add a new “UTF-8 Mode” to enhance Python’s use of UTF-8. When UTF-8 Mode is active, Python will:

- use the utf-8 encoding, regardless of the locale currently set by the current platform, and
- change the stdin and stdout error handlers to surrogateescape.

This mode is off by default, but is automatically activated when using the “POSIX” locale.  
Add the -X utf8 command line option and PYTHONUTF8 environment variable to control UTF-8 Mode.

jlf: Review TBD


### [Fedora Changes/python3 c.utf-8 locale](https://fedoraproject.org/wiki/Changes/python3_c.utf-8_locale)

The standalone Python 3.6 binary will automatically attempt to coerce the C locale
to C.UTF-8, unless the new PYTHONCOERCECLOCALE environment variable is set to 0.

When run under the C locale, Python 3 doesn't work properly on systems where UTF-8
is the correct encoding for interacting with the rest of the system. This proposed
change for Python 3 packaged in Fedora assumes the current locale is misconfigured
when it detects that "LC_TYPE" refers to the "C" locale, and in that case, prints
a warnings to stderr and forces the use of the C.UTF-8 locale instead.

The effects of the problem for a popular CLI construction library are explained on
[Armin Ronacher's blog](http://click.pocoo.org/5/python3/#python-3-surrogate-handling).  
The problem is described in detail in [PEP (Python Enhancement Proposal) 538](https://www.python.org/dev/peps/pep-0538/).

jlf: Review TBD


### [Red Hat Proposal: force C.UTF-8 when Python 3 is run under the C locale](https://bugzilla.redhat.com/show_bug.cgi?id=1404918)

When run under the C locale, Python 3 doesn't really work properly on systems where
UTF-8 is the correct encoding for interacting with the rest of the system. This is
described in detail by Armin Ronacher in the [click documentation](http://click.pocoo.org/5/python3/#python-3-surrogate-handling).

The attached patch is a proposed change to the system Python that assumes the current
process is misconfigured when it detects that "LC_CTYPE" refers to the "C" locale,
and in that case prints a warnings to stderr and forces the use of the C.UTF-8 locale
instead.

jlf: Review TBD


### [Locales on Ubuntu, languages configuration](https://www.sqlpac.com/en/documents/linux-ubuntu-locales-language-settings-configuration.html)

jlf: I put this topic here, not in [0675_Locale.md](0675_Locale.md) because (I think)
it's more related to system configuration than to CLDR (which is more API oriented).

The major inconvenient : locale settings are OS dependent. If a requested locale
is not installed on the OS where the program runs, formatting will fail or will
fallback to default settings.

The current settings are displayed using `locale` command.

The supported locales for Ubuntu are stored in the file `/usr/share/i18n/SUPPORTED`.

`locale-gen` as root installs a new locale:

        root$ locale-gen fr_FR.UTF-8
        Generating locales (this might take a while)...
          fr_FR.UTF-8... done
        Generation complete.


`locale -a` lists installed locales :

        C
        C.UTF-8
        POSIX
        en_US.utf8


### Workaround in ooRexx to convert a string to a double when the locale is not "C"

[NumberString::doubleValue](https://github.com/ooRexx/ooRexx/blob/d1187af908fa0b1e42d439ae839335eb93dfff95/interpreter/classes/NumberStringClass.cpp#L708C1-L723C53)

[NumberString::newInstanceFromDouble](https://github.com/ooRexx/ooRexx/blob/d1187af908fa0b1e42d439ae839335eb93dfff95/interpreter/classes/NumberStringClass.cpp#L4096C1-L4105C26)

jlf:  
The problem described by the ooRexx team is: `strtod()` is locale-dependent, and
we cannot be sure that we run under the default "C" locale.  
TBD how other Rexx interpreters are managing that?
