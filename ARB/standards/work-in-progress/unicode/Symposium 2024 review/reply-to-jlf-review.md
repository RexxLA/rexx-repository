# Reply to Jean Louis Faucher review of the TUTOR article

I am replying in markdown format, because pdf is not very useable to have a dialog.

Please note that the version you have reviewed is not final. I have uploaded the final, published, versions of the articles in the Unicode/publications/35 subdirectory.

I will not copy some of your comments in the pdf, and intersperse my own comments in between. Page references are to the version you reviewed, not to the final document.

(p. 33)
>Inheritance from String.
>
>Each time a new instance of Byte, Codepoints, Graphemes or Text is created, a new copy of the original string is created. That can be confirmed by displaying the identityhash of the ~string.
>
>Not a problem for a prototype, but would be a problem for a real implementation. As written elsewhere, these 4 instances are a view of the same string. So it would be better to share this same string between the 4 views.
>
>Executor provides only Text, which correspond roughly to Tutor’s Graphemes (no normalization, but also no automatic conversion to UTF-8).  The original string is referenced (delegation), not inherited.
>That doesnt forbid to offer the same interface as .String.

OK. As you say, TUTOR is a prototype; I have not strived for efficiency. I am also under the impression that the code is much simpler if I use inheritance instead of delegation (but I might be wrong).

(p. 34)
>Executor applies NFC normalization on the fly when strict comparison of text.
>
>The difference between strict and non-strict is the management of blanks and numeric values.
>
>Rexxref: The two strings must be identical (character by character) and of the same length to be considered strictly equal. 
>No padding, no attempt to perform a numeric comparison

My interpretation of strict equality forbids any normalization. I understand "character by character" as _binary_ equality. 
If you normalize on the fly, you lose a first-class operator to determine whether two strings are binary identical.

My impression is that normalization pertains to _non-strict_ equality. "Normal" equality, that is, non-strict equality, is, somehow, the default
one: blanks are ignored, numbers have to be equivalent, etc., ... and "e" + acute accent is the same as "é".

OTOH, "==", I think, should mean "identical", that is, binary identical.



