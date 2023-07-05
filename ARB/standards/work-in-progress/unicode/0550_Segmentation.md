# Segmentation

## ARB recommendations

(TBD)

## Draft Notes

### (jmb) A priority should be given. For example, segmentation by words and sentences is less prioritary than codepoints & graphemes.

### Code point (proto)

### Grapheme (proto)

Rules [GB12 and GB13](https://www.unicode.org/reports/tr29/#GB12) of the Grapheme Cluster Boundary Rules are ambiguous, in the sense that 
(a) they say "do not break between regional indicator (RI) symbols if there is an odd number of RI characters before the break point", which
seems to imply that you _can_ break when there is an even number of RI characters, but then (b) they write rules that contain "(RI RI)* RI × RI", and
one does not see how could one arrive at one or several pairs "RI RI" without having broken first at an even number of RIs.

See [this discussion](https://stackoverflow.com/questions/26862282/swift-countelements-return-incorrect-value-when-count-flag-emoji) about how different
versions of Swift handle the problem.

### Codepoint/grapheme indexation  (proto)

### Whitespaces, separators

### Hyphenation

### Words, Sentences
