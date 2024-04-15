/* rexx build the pdf */
/* normally we are in a tex/book (two level) subdir of the project */
chapters = getMarkdownFilenames('../..')

/*
 * Every chapter is a markdown file. Precompile the changed chapters,
 * make-style
 */
do i=1 to words(chapters)
  file=word(chapters,i)
  orgfile='../../'file
  if newer(orgfile file) then do
    call eraseFiles file
    call preprocessMD(file'.md')
    say time() 'converting' file
    'pandoc -f markdown+latex_macros -t latex --top-level-division=chapter 'file'.md -o' file'.texin'
    say time() 'preprocessing' file
    call preprocessTEX(file)
  end
end

-- copy the charts for the latex compilation process
'mkdir -p charts'
'mkdir -p images'
'cp ../../standard.tex .'
'cp ../../bibliography.bib .'
'cp ../../structure.tex .'
'cp ../../hyphenation.tex .'
'cp ../../charts/*.pdf ./charts'
'cp ../../images/*.pdf ./images'
'cp ../../images/*.png ./images'
'cp ../../images/*.PNG ./images'
'cp ../../images/*.jpg ./images'
'cp ../../images/*.jpeg ./images'
'cp ../../images/*.tiff ./images'
/* 'cp ../../recursion/\*.svg ./images' */

-- build the document. at least 2 passes needed for coherence of contents and index
xelatexrc=1
/* do i=1 to 2 */
  'xelatex -output-driver="xdvipdfmx -i dvipdfmx-unsafe.cfg -q -E" -shell-esc standard.tex'
  xelatexrc=RC
  say 'xelatex return code:' xelatexrc
  'makeindex standard'
  say 'makeindex return code:' RC
    'bibtex8 --wolfgang standard'
  say 'bibtex return code:' RC
/* end */

'open standard.pdf'
exit

preprocessMD: procedure
parse lower arg filename
outfile=filename
 filename='../../'filename
call lineout outfile,'<!--preprocessed md-->',1
do while lines(filename)
  line=linein(filename)
  line=changestr('<!--index-->',line,'%index%')
  line=changestr('<!--index:',line,'%indexm%')
  line=changestr('<!--cite-->',line,'%cite%')
  if left(line,3)='```' then do
    parse var line '<!--'fn'-->'
    parse var line '```'language' <!--'
    call writeSourceFile filename fn
    line='%includesource='fn':'language'%'
  end
  call lineout outfile,line
end
call lineout outfile /* close the file */
return

/* write the sourcefile that is between the three backticks */
/* the filename is given in an html comment                 */
writeSourceFile: procedure
parse arg filename fnout
call lineout fnout,'/* rexx */',1
i=0
do while src<>'```'
  i=i+1
  src=linein(filename)
  if src='```' then leave
  call lineout fnout,src,i
end
call lineout fnout /* close the file */
return

preprocessTEX: procedure
parse lower arg filename
outfile=filename'.tex'
filename=filename'.texin'
call lineout outfile,'%preprocessed texin',1
do while lines(filename)
  line=linein(filename)
  tbidpos=pos('\{\#tbl:id\}',line)
  if tbidpos>0 then do
    line=changestr('\{\#tbl:id\}',line,'')
  end
  ixpos=pos('\%index\%',line)
  if ixpos>0 then line=replaceIndices()
  ixpos=pos('\%indexm\%',line)
  if ixpos>0 then line=replaceMultiIndices()
  ixpos=pos('\%cite\%',line)
  if ixpos>0 then line=replaceCites()
  ixpos=pos('\hyperlink',line)
  if ixpos>0 then line=replaceHyperlink()
  ixpos=pos('\%includesource',line)
  if ixpos>0 then line=includelisting()
  call lineout outfile,line
end
call lineout outfile /* close the file */
return

eraseFiles: procedure
parse lower arg filename
'rm' filename'.md'
'rm' filename'.texin'
'rm' filename'.tex'
return

includelisting: procedure expose line
outline=''
parse var line start '\%includesource='fn'\%'
parse var line start '\%includesource='fn':'language'\%'
outline='\lstinputlisting[language='language',label='fn',caption='fn']{'fn'}'
return outline

/* replaceIndices
 * replace a single <!--index--> tag with the indexable word
 * following the tag; no duplication but only a single index word
 * which is passed through to the .tex file 
 */  
replaceIndices: procedure expose line
outline=''
do until line=''
  parse var line start '\%index\%' rest
  ixword=word(rest,1)
  if ixword='' then do
    outline=outline||start
    leave
  end
  outline=outline||start||ixword'\index{'ixword'} '
  line=subword(rest,2)
end
return outline

/* replaceMultiIndices
 * replace a <!--index:indexable words--> tag with the indexable words
 * within a tex \index tag; here duplication is necessary
 * and the words are filtered from passing through 
 */  
replaceMultiIndices: procedure expose line
outline=''
do until line=''
  parse var line start '\%indexm\%' rest
  parse var rest ixwords '--\textgreater' rest
  if ixwords='' then do
    outline=outline||start
    leave
  end
  outline=outline||start||'\index{'ixwords'} '
  line=rest
end
return outline

replaceCites: procedure expose line
outline=''
do until line=''
  parse var line start '\%cite\%' rest '.'
  parse var rest '{[}'ixword'{]}'
  /* ixword=translate(ixword,'','[]{}') */
  /* ixword=strip(ixword) */
  if ixword='' then do
    outline=outline||start
    leave
  end
  outline=outline||start||'\cite{'ixword'}'
  line=subword(rest,2)
end -- do until
if pos('footnote',outline) >0 then return outline'}'
else return outline
return outline

replaceHyperlink: procedure expose line
outline=''
parse var line start '\hyperlink{'link'}{'text'}' rest
outline=start'\hyperlink{'link'}{'text'} on page \pageref{'link'}' rest
return outline

newer: procedure
arg origfile genfile
origfile=lower(origfile)'.md'
genfile=lower(genfile)'.md'
ts1 = stream(origfile,'c','QUERY TIMESTAMP')
ts2 = stream(genfile,'c','QUERY TIMESTAMP')
if ts2="" then return 1
if ts1 > ts2 then return 1
else return 0
