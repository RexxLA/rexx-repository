/* rexx build the standard pdf */

chapters = 'foreword introduction scope_purpose_and_application',
'normative_references definitions_and_document_notation conformance',
'configuration syntax_constructs evaluation directives instructions',
'built-in_functions built-in classes provided_classes rationale',
'incompatibilities to_be_processed annexb'

do i=1 to words(chapters)
  file=word(chapters,i)
  call eraseFiles file
  call preprocessMD(file'.md')
  'pandoc -f markdown -t latex --top-level-division=chapter 'file'.md -o' file'.texin'
  call preprocessTEX(file)
end

-- copy the charts for the latex compilation process
'mkdir -p charts'
'mkdir -p images'
'cp ../../bibliography.bib .'
'cp ../../charts/*.pdf ./charts'
'cp ../../images/*.pdf ./images'

-- build the document. at least 2 passes needed for coherence of contents and index
do i=1 to 2
  'xelatex -output-driver="xdvipdfmx -i dvipdfmx-unsafe.cfg -q -E" -shell-esc standard.tex'
  say 'Xelatex return code:' RC
  'makeindex standard'
  say 'makeindex return code:' RC
    'bibtex standard'
  say 'bibtex return code:' RC

end

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
  line=changestr('<!--cite-->',line,'%cite%')
  call lineout outfile,line
end
call lineout outfile
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
  ixpos=pos('\%cite\%',line)
  if ixpos>0 then line=replaceCites()
  call lineout outfile,line
end
call lineout outfile
return

eraseFiles: procedure
parse lower arg filename
'rm' filename'.md'
'rm' filename'.texin'
'rm' filename'.tex'
return

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

replaceCites: procedure expose line
outline=''
--line=translate(line,'','[]{}')
do until line=''
  parse var line start '\%cite\%' rest
  ixword=word(rest,1)
  ixword=translate(ixword,'','[]{}')
  ixword=strip(ixword)
  if ixword='' then do
    outline=outline||start
    leave
  end
  outline=outline||start||'\cite{'ixword'} '
  line=subword(rest,2)
end -- do until
if pos('footnote',outline) >0 then return outline'}'
else return outline
