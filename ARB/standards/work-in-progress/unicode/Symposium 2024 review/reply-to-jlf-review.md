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

(p. 43)
>Can’t resist to remind my point of view, but feel free to ignore, was already discussed at one moment and written somewhere in the draft documents.
>
>It’s well defined: it’s what the interpreter exposes to you via the native C2X.
>
>Netrexx: UCS-2 (16 bits)
>
>Crexx: UTF-8
>
>all other interpreters: byte, whatever the encoding.
>
>You defined several views. Just apply these views on the native C2X. That will be exactly the same hex digits than the native C2X, but grouped according the view.

I think the final version refers to it (not sure about the version you have commented): it appears that recent versions of Java store Unicode strings as ISO-8859-1 when all 
codepoints are < "FF"X. This means that the notion of "internal representation" does no longer make sense (or varies according to whether a string contains a single
codepoint >= "100"X, which is ridiculous), as it is the remnant of a situation which is no longer true: when strings were manageable by a simple adlen pair, and were
composed of bytes.

(Ibid.)
>Hum… Don’t you have another BIF that convert to  a target encoding?

Yes. The addition of a second, encoding parameter to C2X is a compatibility aid: if you want NetRexx behaviour, for example, you just add "UTF-16" and you are done.

(p. 45)
> This is not very usual to return 2 results at once. Sounds like an internal optimization for your implementation.
> 
> UTF8()) returns a stem.

You are right, there are several details in the current version that are internal optimization leftovers. Will try to fix in a subsequent release.


