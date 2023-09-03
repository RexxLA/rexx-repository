# How the standard is produced

The initial text is taken from the last known draft of the Extended Standard, which was a work in progress that was never completed. The reasons for this are not important for this readme.md

# Goals

The goal is to have a new standard for the work on Rexx implementations. The standard should be a publication in the form of a printed book; web, electronic publishing and pdf are definite targets but the form of the standard is that of a traditional printed book and users, implementors and other interested parties should be able to buy a hardcopy book without high cost attached.

# Production

## Markdown
We aim to have all source text in Markdown. This has great advantages of being readable even with markup in it, well integrated with the version management system at github, and suitable for conversion to more probable typograpical software like TeX. For that reason, the original source text of the (Extended) standard is converted to markdown and readable (and, important, editable) from the github repository.

### Conversion to TeX
Markdown, when converted (using pandoc) to Latex source is almost suitable for producing the publication to the pdf book source, but not quite. For this reason the conversion script, [build.rexx](ARB/standards/work-in-progress/document/tex/standard/build.rexx) produces two intermediate formats, both using the comment syntax native to markdown and TeX. This enables us to add some essential ingredients of the publication:

- an index (use <!--index--> right before the word to index in the markdown source, this should be invisible in the markdown but shows when editing
- a bibliography for the referenced publications
- Latex formatting and automated execution of Rexx examples. This, experience has shown. is the only way to have correct examples in any publication: run them live during the compilation of the book source and include the actual output.

The build.rexx script handles the conversion of the markdown files using pandoc and the subsequent reformatting of these components. The structure of the book is in the standard.tex document; this just includes a lot from the boilerplate directory and the converted documents. It also runs the makeindex and bibtex processes. Output is a pdf file called standard.pdf, which is (after some preflight actions using ghostscript) the file that becomes the book.

## Assistance
Please ask if you want to build the book for yourself and you run into problems. Prerequisites are:

- ooRexx or Regina
- A recent TeX distribution containing XeLaTeX and all utilities like bibtex and makeindex
- some fonts, current choice is Minion Pro, IBM Plex Mono and some others but we are looking for a suitable open source font that we can put into github
- pandoc (including imagemagick)

For editing, the github website should be sufficient, or for a checked out version, your editor of choice.

