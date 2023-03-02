/* rexx test replacing a bif in standard classic rexx */
/* swap translate for a version that returns lowercase with empty tables */
/* cf William Schindler, Down to Earth REXX, Perfect Niche Software, 2000 pp 243 */
/* works on OS/2 Classic, z/VM, ooRexx */

say translate('AAP NOOT MIES')

exit

Translate: procedure
parse arg inString, oTable, iTable
if oTable='' & iTable='' then
  do
    otable=xrange('a','z')
    itable=xrange('A','Z')
  end
s = 'TRANSLATE'(inString,oTable,iTable)
return s
