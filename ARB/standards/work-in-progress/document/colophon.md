# Colophon for the Rexx Standard Document

## Principles

The text is in (github-) MarkDown as much as possible; online display is an important medium, but a printed book is the deliverable. 

All text is in the `rexx-repository/ARB/standards/work-in-progress/document` directory and its subdirectories.
The end product is a pdf file in the `tex/standard` subdirectory. This subdirectory has no content in the git repository and the contents can be erased at all times.

A `build.rexx` exec produces the document. It should be run from the `tex/standard` directory. You can download it and [here](https://github.com/RexxLA/TextTools).

The derived products are produced using this `build.rexx` exec; they are preprocessed `.md` files, with some `.tex` files and various graphics 
formats (preferably separated in subdirectories) and one `bibliography.bib` file.

## Operating environments

This documentation applies to the Mac and Linux operating systems; a Windows version of the software is in the works.

You can also run the software under the Windows Subsystem for Linux (`wsl2`) without problems: you just have to install all the necessary software (for example, under Ubuntu 22.04, which works fine) and fonts, 
and you are ready to go.

A useful trick to share fonts between your Windows and wsl2 installations: put the necessary fonts in a designated Windows directory (say, `C:\document\fonts`); then, under wsl, navigate to 
`/etc/fonts`, and create a file called `local.conf` contanining

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <dir>/mnt/c/document/fonts</dir>
</fontconfig>
```

## Tools used

- rexx
- xetex
    - bibtex
- pandoc

## Additions to the Markdown format

Most of the conversion from `.md` to `.tex` is done automatically from standard MarkDown files. Some features are added to the markdown, using encodings in the markdown comment format, as to be invisible in the online representation of the repository:

- index entries
- bibliography references
- source code formatting independent from github

### Index format one

This adds an `<!--index-->` statement to index only the immediately following word. 

### Index format two (not implemented yet?)

This adds an `<!--index-->word1,word2</--end-index-->` statement to index a two word combination with a comma in between for a two level index entry.

### Bibliography reference

This adds a `\<!--cite-->`\[hyperlink]  tag to add a bibiography reference before a hyperlink, so the standard bibtex mechanism can be used for citing publication.

The hyperlinked text should be an existing bibtex reference from a file called `bibliography.bib`.

### Inclusion and formatting of source code

Source code needs the language name after the three backticks (\```) and a comment which names a file after one space. This will result in writing the source
to a file in the current directory for inclusion via the listings package or any other source code formatter; it also enables easy execution using the bashful environment.

## Remember to

- Do a `touch *.md` in the source directory with a certain regularity - files that are not newer that their derived versions will not be preprocessed again until they are. Do this especially after changes to the preprocessing part of the `build.rexx` exec.
