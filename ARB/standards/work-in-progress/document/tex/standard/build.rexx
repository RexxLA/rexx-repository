/* rexx build the standard pdf */
'pandoc -f markdown -t latex --top-level-division=chapter ../../foreword.md -o foreword.tex'


/* build the document. at least 2 passes needed for coherence of contents and index */
do for 2
  'xelatex -output-driver="xdvipdfmx -i dvipdfmx-unsafe.cfg -q -E" -shell-esc standard.tex'
  say RC
  'makeindex standard'
  say RC
end