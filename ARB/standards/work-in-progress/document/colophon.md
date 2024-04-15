# Colophon for the Rexx Standard Document

## Principles

The text is in (github-) Markdown as much as possible; online display is an important medium, but a printed book is the deliverable. 

All text is in the rexx-repository/ARB/standards/work-in-progress/document directory and its subdirectories.
The end product is a pdf file in the tex/standard subdirectory. This subdirectory has no content in the git repository and the contents can be erased at all times.

A build.rexx exec produces the document. It is started in the tex/standard directory with the command 'rexx ../../build.rexx'

The derived products are produced using this build.rexx exec; they are preprocessed .md files, with some .tex files and various graphics formats (preferable separated in subdirectories) and one bibliography.bib file

Tools used are:

- rexx
- xetex
  -- bibtex
- pandoc

## Additions to the Markdown format

Most of the conversion from .md to .tex is done using markdown. Some features are added to the markdown, using encodings in the markdown comment format, as to be invisible in the online representation of the repository:

- index entries
- bibliography references
- source code formatting independent from github


### Index format one

This adds an *\<!--index-->* statement to index only the immediately following word. 

### Index format two (not implemented yet?)

This adds an *\<!--index-->word1,word2\</--end-index-->* statement to index a two word combination with a comma in between for a two level index entry.

### Bibliography reference

This adds a *\<!--cite-->*\[hyperlink]  tag to add a bibiography reference before a hyperlink, so the standard bibtex mechanism can be used for citing publication.

The hyperlinked text should be an existing bibtex reference from a file called bibliography.bib

### Inclusion and formatting of source code

Source code needs the language name after the three backticks (\```) and a comment which names a file after one space. This will result in writing the source
 to a file in the current directory for inclusion via the listings package or another source code formatter; it also enables easy execution using the bashful environment.

## Remember to

- Do a *touch \*.md* in the source directory with a certain regularity - files that are not newer that their derived versions will not be preprocessed again until they are. Do this especially after changes to the preprocessing part of the `build.rexx` exec.
