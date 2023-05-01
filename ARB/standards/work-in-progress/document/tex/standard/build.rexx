/* rexx build the standard pdf */
'pandoc -f markdown -t latex --top-level-division=chapter ../../foreword.md -o foreword.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../introduction.md -o introduction.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../scope_purpose_and_application.md -o scope_purpose_and_application.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../normative_references.md -o normative_references.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../definitions_and_document_notation.md -o definitions_and_document_notation.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../conformance.md -o conformance.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../configuration.md -o configuration.tex'

/* build the document. at least 2 passes needed for coherence of contents and index */
do i=1 to 2
  'xelatex -output-driver="xdvipdfmx -i dvipdfmx-unsafe.cfg -q -E" -shell-esc standard.tex'
  say RC
  'makeindex standard'
  say RC
end