# The Search Order problem

A place to collect all things related to the Search Order problem

## Contents

* [References](references/README.md) -- external references related to the problem
* [Documents](documents/README.md) -- describing the problem
* [Tests](tests/README.md) -- testing different aspects of the problem

## Definition of a search algorithm

Given: 

* A sequence $\langle p_1, \dots, p_n \rangle$ of _path lists_, where each $p_i$ is a sequence of (relative or absolute) directories, $\langle d_{i1}, \dots, d_{im_{i}}\rangle$.
* A sequence $\langle l_1, \dots, l_k \rangle$ of _file extension lists_, where each $l_j$ is a sequence of (possibly empty) file extensions, $\langle e_{i1}, \dots, e_{jn_{j}}\rangle$.
* A *file name* $f$, which can contain or not an extension and/or a relative or absolute path.
* A _composition operation_ $C$ that, given a directory $d_{ij}$, an extension $e_{kl}$ and a file name $f$ produces an absolute file specification $F$.

Locate the first $F = C(d_{ij},e_{kl},f)$ such that $F$ that exists.

A search algorithm can be

* _Directory-first_, i.e. all the directories of $p_1$ are checked in turn, then all the directories of $p_2$, and so on. Inside each directories, all the extensions are checked.
* _Extension-first_, i.e. all the extensions of $l_1$ are checked in turn, then all the extensions of $l_2$, and so on. For each $e_{kl}$, all the directories in $p_1$ are checked, then all the directories in $p_2$, and so on; then the next extension is checked, etcetera.

The composition operation can incorporate a number of _exceptions_ where the search algoritgh is bypassed (and then, normally, the $f$ parameter is resolved by the operating system in a system-dependent way).
