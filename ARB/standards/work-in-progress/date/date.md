# ISODate and LocalDate Built-in-functions

This is a proposal for a set of new Date() built in functions. The ISODate() functionality is based on [ISO8601](#https://en.wikipedia.org/wiki/ISO_8601) with some input from [RFC3339](#https://datatracker.ietf.org/doc/html/rfc3339). The LocalDate function intends to standardize local variants as much as possible. As we do not intend to change existing BIFs in current implementation, these can provided be in addition to those. In implementations that support object orientation, these can inherit from existing functionality where opportune.

## Design Rationale

- Over the years the Rexx Date() BIF has diverged in functionality on several platforms. The X3J18 standard, which deprecated several functions often used, started this process; some implementations like ooRexx, removed these entirely.
- Several implementations added date formats in local variants; these cause problems when not available in other implementations
- To avoid having Locale support in the ISODate BIF, implementations have an opportunity to use LocalDate; it is expected that implementations try to implement a wide set of these calls, in order to have a good chance of compatible support for a large set of Rexx programs
- Implementations can have an option to enlarge the functionality of Date() by having it inherit from LocalDate and ISODate
- this implies that collisions in naming have to be avoided and/or resolved
##
[Jon Wolfers' 2019 Symposium Presentation](https://www.rexxla.org/presentations/2019/Subclassing%20the%20ooRexx%20dateTime%20class.pdf)

## ISODate

ISO8601. The goal is to adhere to the international standard, adopted by many countries, in order to eliminate ambiguity.
Local notations which deviate from ISO8601 are relegated to a LocalDate/Time function/method.

The proposal is to move all local date and time variants to LocalDate / LocalTime. Implementations keep already available local variants in their Date() and Time() BIFs, optionally signal them as deprecated and offer ISODate and ISOTime as preferred formats. No new local date and time formats are implemented in the traditional BIFs. In short, this is its main content:

### Years

YYYY

Calendar Dates

YYYY-MM-DD or YYYYMMDD
YYYY-MM

### Week dates

YYYY-Www or YYYYWww
YYYY-Www-D or YYYYWwwD

Week 01 is the first week with 4 January in it
The week number can be described by counting the Thursdays.

### Ordinal Dates

(earlier name: Julian Date) 

YYYY-DDD or YYYYDDD


### Times

Thh:mm:ss.sss	or	Thhmmss.sss
Thh:mm:ss	or	Thhmmss
Thh:mm.mmm	or	Thhmm.mmm
Thh:mm	or	Thhmm
Thh.hhh		
Thh		
In unambiguous contexts*		
hh:mm:ss.sss	or	hhmmss.sss*
hh:mm:ss	or	hhmmss*
hh:mm	or	hhmm*
hh*		


So a time might appear as either "T134730" in the basic format or "T13:47:30" in the extended format. ISO 8601-1:2019 allows the T to be omitted in the extended format, as in "13:47:30", but only allows the T to be omitted in the basic format when there is no risk of confusion with date expressions.

Either the seconds, or the minutes and seconds, may be omitted from the basic or extended time formats for greater brevity but decreased precision; the resulting reduced precision time formats are:

* T\[hh\]\[mm\] in basic format or T\[hh\]:\[mm\] in extended format, when seconds are omitted.
* T\[hh\], when both seconds and minutes are omitted.
As of ISO 8601-1:2019/Amd 1:2022, "00:00:00" may be used to refer to midnight corresponding to the instant at the beginning of a calendar day; and "24:00:00" to refer to midnight corresponding to the instant at the end of a calendar day. ISO 8601-1:2019 as originally published removed "24:00:00" as a representation for the end of day although it had been permitted in earlier versions of the standard.
A decimal fraction may be added to the lowest order time element present in any of these representations. A decimal mark, either a comma or a dot on the baseline, is used as a separator between the time element and its fraction. (Following ISO 80000-1 according to ISO 8601:1-2019 it does not stipulate a preference except within International Standards, but with a preference for a comma according to ISO 8601:2004.) For example, to denote "14 hours, 30 and one half minutes", do not include a seconds figure; represent it as "14:30,5", "T1430,5", "14:30.5", or "T1430.5".
There is no limit on the number of decimal places for the decimal fraction. However, the number of decimal places needs to be agreed to by the communicating parties. For example, in Microsoft SQL Server, the precision of a decimal fraction is 3 for a DATETIME, i.e., "yyyy-mm-ddThh:mm:ss\[.mmm\]".



## Time Zone Designators

Time zones in ISO8601 are represented as local time (with time zone unspecified), as UTC
or as an offset from UTC.

If time is UTC, add a Z suffix

<time>Z  
<time>±hh:mm  
<time>±hhmm  
<time>±hh  

Minus should be a UTF-8 minus and not an ASCII hyphen-minus


### Durations

PnYnMnDTnHnMnS  
PnW  
P<date>T<time>  

The capital letters P, Y, M, W, D, T, H, M, and S are designators for each of the date and time elements and are not replaced.
* P is the duration designator (for period) placed at the start of the duration representation.
    * Y is the year designator that follows the value for the number of calendar years.
    * M is the month designator that follows the value for the number of calendar months.
    * W is the week designator that follows the value for the number of weeks.
    * D is the day designator that follows the value for the number of calendar days.
* T is the time designator that precedes the time components of the representation.
    * H is the hour designator that follows the value for the number of hours.
    * M is the minute designator that follows the value for the number of minutes.
    * S is the second designator that follows the value for the number of seconds.
For example, "P3Y6M4DT12H30M5S" represents a duration of "three years, six months, four days, twelve hours, thirty minutes, and five seconds".


### No truncated representation

ISO 8601:2000 allowed truncation (by agreement), where leading components of a date or time are omitted. Notably, this allowed two-digit years to be used as well as the ambiguous formats YY-MM-DD and YYMMDD. This provision was removed in ISO 8601:2004.


## To be decided

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

