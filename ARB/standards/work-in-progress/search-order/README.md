# The Search Order problem

A place to collect all things related to the Search Order problem

## Contents

* [References](references/README.md) -- external references related to the problem
* [Documents](documents/README.md) -- describing the problem
* [Tests](tests/README.md) -- testing different aspects of the problem

## Definition of a search algorithm

Given: 

* A sequence $\langle p_1, \dots, p_n \rangle$ of **path lists**, where each $p_i$ is a sequence of (relative or absolute) directories, $\langle d_{i1}, \dots, d_{im_{i}}\rangle$.

>For example, ooRexx determines that $p_1 = \langle S \rangle$, where $S$ is the "same" or caller directory; $p_2 = \langle "." \rangle$, the 1-element sequence containing as its only element the current directory; $p_3$ is the application-defined path; $p_4$ is the list of directories contained in the `REXX_PATH` environment variable, and $p_5$ is the list of directories contained in the `PATH` environment variable.

* A sequence $\langle l_1, \dots, l_k \rangle$ of **file extension lists**, where each $l_j$ is a sequence of (possibly empty) file extensions, $\langle e_{i1}, \dots, e_{jn_{j}}\rangle$.

>For example, ooRexx determines that the first extension list contains only one element, `".cls"`, but only in the case of a `::requires` invocation; the next extension list has also only one element, and is the same extension as the caller program, if it exists; the next extension list is defined by the application, for example by an editor; the next list is either $\langle$ `".REX"`, `".rex"` $\rangle$, in the case of Unix-like operating systems, or $\langle$ `".rex"` $\rangle$, in the case of Windows; and, finally, the last extension list has also only one element, the empty extension (that is, no extension).

* A **file name** $f$, which can contain or not an extension and/or a relative or absolute path.
* A **composition operation** $C$ that, given a directory $d_{ij}$, an extension $e_{kl}$ and a file name $f$ produces an absolute file specification $F = C(d_{ij},e_{kl},f)$.

>The simplest cases of composition are similar to a concatenation, adding a path separator character if necessary. For example, if $d_{ij}=$ `"C:\my\files"`, $e_{kl} =$ `".cls"` and $f=$ `"routine"`, then probably $C(d_{ij},e_{kl},f) =$ `"C:\my\files\routine.cls"`. There are also some non-obvious, more complicated variations.

Locate the first $F = C(d_{ij},e_{kl},f)$ such that $F$ that exists.

A search algorithm can be

* _Directory-first_, i.e. all the directories in $p_1$ are checked in turn, then all the directories in $p_2$, and so on. Inside each directories, all the extensions are checked.
* _Extension-first_, i.e. all the extensions in $l_1$ are checked in turn, then all the extensions in $l_2$, and so on. For each $e_{kl}$, all the directories in $p_1$ are checked, then all the directories in $p_2$, and so on; then the next extension is checked, etcetera.

>For example, ooRexx search is extension-first, while Regina search is directory-first.

The composition operation can incorporate a number of _exceptions_ where the search algoritgh is bypassed (and then, normally, the $f$ parameter is resolved by the operating system in a system-dependent way).

>For example, ooRexx does not follow the search order when `f[1] == "\" | f[1] == "/" | f[2] == ":" | f[1,2] == ".\" | f[1,2] == "./" ! f[1,3] == "..\" ! f[1,3] == "../"`.
