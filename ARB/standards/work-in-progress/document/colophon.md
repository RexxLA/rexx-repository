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
- pandoc

## Additions to the Markdown format

Most of the conversion from .md to .tex is done using markdown. Some features are added to the markdown, using encodings in the markdown comment format, as to be invisible in the online representation of the repository:

- index entries
- bibliography references
- source code formatting independent from github

