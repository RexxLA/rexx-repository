# Define what is a character

## ARB recommendations

(TBD)

## Draft notes

See [requirement document](./Unicode_Requirements.md).

Probably grapheme, but good to investigate if another approach could be valuable for some scenarios.

(jmb)

Some BIFs will be really difficult to define if we opt for grapheme clusters. See for example this document: ["Proper Complex Script Support
in Text Terminals"](https://www.unicode.org/L2/L2023/23107-terminal-suppt.pdf). There doesn't seem to exist a reasonable way to decide what is the "perceived" width of a grapheme cluster (even if a grapheme cluster is _defined_ to be a user-perceived character -- in appears that there are some serious consistency problems in the Unicode usage of the term "perception"). Hence, BIFs like CENTER will have to be (a) defined against the (false) assumption that one grapheme cluster = 1 space (and then their general utility, especially as formatting functions, will be greatly diminished), or (b) defined against some specifications which are inconsistent and immature.

Take, for example, devanagari जन्म, _janma_, "birth". It's formed by the letter ज, _ja_, the letter न, _na_ followed by a _visarga_, ्, which eliminates the implicit _a_ from _na_, giving _n_, and a conjunct with म, _ma_, so that a ligature is formed, न्म, _nma_.

      जन्मX  
      xxxX

In my view of github's code editor (Windows 11, Chrome), "जन्म" appears slightly _wider_ that "xxx"; in Notepad++ for Windows, slightly _narrower_. And in the Windows CLI with codepage 65001, well, it's a disaster, _comme d'habitude_.

Now, what should Center("जन्म",8) be supposed to mean, exactly?

Still some details more. जन्म counts as _three_ graphemes, namely ज, न् and म. But न्म is kind of a ligature...

(/jmb)

(rvj)
In my view, centre()/center() lost its relevance when proportional fonts for terminals and printers were introduced.
(/rvj)

(jmb)

An example of why we need to work with graphemes. Look at the output of this small NetRexx program

```
options utf8

test = "Rene\u0301"
Say test", last char ="test.substr(test.length,1).c2x
test2 = test.changeStr("e","a")
Say test2", last char ="test2.substr(test2.length,1).c2x
test = "René"
Say test", last char ="test.substr(test.length,1).c2x
test2 = test.changeStr("e","a")
Say test2", last char ="test2.substr(test2.length,1).c2x
```

If you compile and run it with ``nrc -utf8 -exec test.nrx``, you'll get (Windows, CP 28591):

```
Rene?, last char =301  <--- "René", but it doesn't print with this codepage
Rana?, last char =301  <--- This would be "Raná", which is wrong
René, last char =E9    <--- Prints correctly since E9 < 100
Rané, last char =E9    <--- This is a correct result
```

(/jmb)
