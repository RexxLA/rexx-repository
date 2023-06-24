# Define what is a character

## ARB recommendations

(TBD)

## Draft notes

See [requirement document](./Unicode_Requirements.md).

Probably grapheme, but good to investigate if another approach could be valuable for some scenarios.

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
