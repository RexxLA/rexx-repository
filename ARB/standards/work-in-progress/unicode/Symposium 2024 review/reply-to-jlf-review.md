# Reply to Jean Louis Faucher review of the TUTOR article

I am replying in markdown format, because pdf is not very useable to have a dialog.

Please note that the version you have reviewed is not the final one. I have uploaded the final, published, versions of the articles in the Unicode/publications/35 subdirectory.

I will now copy some of your comments in the pdf, and intersperse my own comments in between. Page references are to the version you reviewed, not to the final document.

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

"==", I think, should mean "identical", that is, binary identical.

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
codepoint >= "100"X, which is ridiculous), as it is the remnant of a situation which is no longer true: when strings were manageable by a simple adlen pair and a chunk of bytes.

(Ibid.)
>Hum… Don’t you have another BIF that convert to  a target encoding?

Yes. The addition of a second, encoding parameter to C2X is a compatibility aid: if you want NetRexx behaviour, for example, you just add "UTF-16" and you are done.

(p. 45)
> This is not very usual to return 2 results at once. Sounds like an internal optimization for your implementation.
> 
> UTF8()) returns a stem.

You are right, there are several details in the current version that are internal optimization leftovers. Will try to fix in a subsequent release. https://github.com/RexxLA/rexx-repository/issues/10

(Ibid.)
>This decode/encode reminds me Python.
>
>But your functions seems to be still a draft…
>
>with decode, you can transcode from a source encoding to a target encoding, where the target encoding is limited to UTF-8/16/32?

Only -8 and -32. This is another leftover. I need the -32 version internally, but I should most probably not expose that as an API.

(cont.)
>encode is also doing a transcoding… Only the target encoding is specified.
>The source encoding is UTF-8/16/32? Why is it not needed to specify it here?

My way of understanding the standard is the following: Unicode is the _lingua franca_ of all encodings. You only need a DECODE function that
specifies an encoding E (this converts from E to Unicode, our _lingua franca_), and a ENCODE function: this converts from Unicode,
our _lingua franca_, to a specified encoding E. You do not need a source encoding for ENCODE, since your source string is always (abstract)
Unicode.

If you want to transcode, say, from UTF-32 to another encoding E, you should first DECODE from UTF-32, and then ENCODE to E.

Most probably, the fact that DECODE allows a limited set of target Unicode encodings is misleading, and therefore a bad design decision. Thanks for bringing
this aspect to my attention.

(p. 47)
>I’m not aware of WTF32, and I don’t see how it could be needed. There is no low/high surrogates in UTF32.
>Do you have links?

I can't seem to be able to recover the links I once had, my bad; I have not invented the term. Just because UTF-32 does not allow
lone surrogates, we _need_ WTF-32. For example, when handling WTF-8, we may find lone surrogates. Either we forbid transforming
WTF-8 to a four-bytes per codepoint format (bad), or we have to implement WTF-32.

(p. 48)
>U2C() is cited once elsewhere in this document. But not yet implemented? or discarded?

Forgot to document it :/ It was implemented as a method, but not as a (new) BIF. Fixed: https://github.com/RexxLA/rexx-repository/blob/master/ARB/standards/work-in-progress/unicode/UnicodeTools/doc/new-functions.md#u2c-unicode-to-character

(Ibid.)
>Should I provide U2C? it would support only the U+ notation.
>Yes, having C2U/U2C would be consistent with C2X/X2C.
>The target encoding would be the default encoding.

I can see that this is a note to yourself. Just wanted to add that this is just the idea: consistency with C2X/X2C. My U2C allows names, aliases and labels, in addition to codepoints and U+codepoints.

(Ibid.)
>Low level, so maybe you need it for your implementation.
>
>But from an end-user perspective, don’t you have a BIF that returns all the properties of a unicode character? including its name and aliases. Yes: UNICODE()

I think that in many cases it may be very convenient to specify a character by name. Not so much low-level, I think.

The idea of subsuming this in UNICODE is great. https://github.com/RexxLA/rexx-repository/issues/11

(p. 50)
>You could also support a Unicode character name, but I understand that it collides with the other form UNICODE(string…).

Again a great idea. https://github.com/RexxLA/rexx-repository/issues/12

(p. 55)
>Under macOS, and probably under Linux:
>
>  rlwrap rexx rxutry
>
>to have an history of commands.

Thanks for the tip! I will document it in the following release.

(p. 56)
>Something specific to ooRexx (and maybe Netrexx?): the caseless methods.

Have not delved into case folding still. Thanks for the info!
