/* rexx return the markdown (*.md) files in the current directory    */
/* without their filename extension, as a string                     */
parse arg dir
outstem=''
outstring=''

address 'bash' 'ls -1 *.md' dir with output stem outstem.

do i=1 to outstem.0
  parse var outstem.i nm '.' .
  outstring=outstring nm
end
return strip(outstring,'b')
