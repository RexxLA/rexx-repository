# Date Built-in-function

##
[Jon Wolfers' 2019 Symposium Presentation](https://www.rexxla.org/presentations/2019/Subclassing%20the%20ooRexx%20dateTime%20class.pdf)

## Options (Existing ones with issues)

### Date('Julian')
- *Date('J')*:
 not in [X3J18-199X](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/historic/j18pub.pdf) and has been deprecated (limited for conversions)) in the CMS/TSO interpreter; it has been removed from ooRexx. Rexx users working with mainframe data need this format almost daily; when scripts are moved to ooRexx this format is missing. For variants and implementations that contain it, X3J18-202X proposes to standardize the year number to 4 digits.

| Statement   | Rexx version | Platform  | Supported | Output |
|-----------  |--------------|-----------|-----------|--------|
| `Date('j')` | CMS/TSO 4.02 | z/VM, z/OS| yes       | 23015  |
|             | Regina       | all       |           ||
|             | Brexx 2.1    | all except| yes       | 23015  |



### Date('Normal')
- *Leading zero on Day:*
According to the z/VM Reference and the [Extended Standard](https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/historic/Extended_Rexx_Standard_Dallas_Version-1998.pdf) both the input and output format for *Day* cannot have a leading zero for day numbers 1-9. Implementations are inconsistent and while there is consensus over the output format, there is resistance registered to change existing implementations to stop accepting (otherwise well formed) date strings like '02 Jan 2023'.
- *Abbreviated Month Name*: 
The accepted input month format is English only and the three character, capitalized strings are case sensitive in some implementations, and case insensitive in others. Cannot find the case sensitivity requirements in X3J18 nor -extended. (Or is this a general rule somewhere?) 

- Output format is localized in the IBM CMS/TSO implementations - but some languages do not captalize month names.

### Date(Non-Standard-Options)
Date() seems one of the most popular bifs to extend - in the sense of adding new functionality with options that are not in X3J18-199X or -extended. This has a drawback of letting execs being produced that are only valid for a limited number of implementations. The proposal here would be to properly extend (in the oo-sense of subclassing) the Date() class (which already subclasses Time() in some implementations) with new proper names, that can be standardized. One of those proposals is *LocalDate()*, another is *ISODate()*. [ISO 8601 Wikipedia](https://en.wikipedia.org/wiki/ISO_8601).

