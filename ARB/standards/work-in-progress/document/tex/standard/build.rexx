/* rexx build the standard pdf */
'pandoc -f markdown -t latex --top-level-division=chapter ../../foreword.md -o foreword.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../introduction.md -o introduction.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../scope_purpose_and_application.md -o scope_purpose_and_application.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../normative_references.md -o normative_references.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../definitions_and_document_notation.md -o definitions_and_document_notation.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../conformance.md -o conformance.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../configuration.md -o configuration.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../syntax_constructs.md -o syntax_constructs.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../evaluation.md -o evaluation.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../directives.md -o directives.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../instructions.md -o instructions.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../built-in_functions.md -o built-in_functions.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../built-in_classes.md -o built-in_classes.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../provided_classes.md -o provided_classes.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../rationale.md -o rationale.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../incompatibilities.md -o incompatibilities.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../to_be_processed.md -o to_be_processed.tex'
'pandoc -f markdown -t latex --top-level-division=chapter ../../annexb.md -o annexb.tex'

/* build the document. at least 2 passes needed for coherence of contents and index */
do i=1 to 2
  'xelatex -output-driver="xdvipdfmx -i dvipdfmx-unsafe.cfg -q -E" -shell-esc standard.tex'
  say RC
  'makeindex standard'
  say RC
end