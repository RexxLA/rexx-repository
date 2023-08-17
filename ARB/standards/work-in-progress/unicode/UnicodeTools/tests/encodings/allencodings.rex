/**
 * 
 *  <h2>The <code>allEncodings</code> test</h2>
 *                                                                           
 *<pre><code>   This file is part of <a href="https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools">the Unicode Tools Of Rexx</a> (TUTOR). 
 *   See <a href="https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/">https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/</a> for more information.
 *   Copyright &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;.
 *   License: Apache License 2.0 (<a href="https://www.apache.org/licenses/LICENSE-2.0">https://www.apache.org/licenses/LICENSE-2.0</a>).</code></pre>
 *                                                                           
 *  <p>Runs all encoding tests. Returns 0 if everything ok, and 1 otherwise. Will take a couple minutes.
 *                                                                           
 *  <h4>Version history</h4>
 *  
 *  <table>
 *    <tr><td><b>1.0</b><td><b>20230811</b><td>Initial release.
 *  </table>
 * 
 *  @author &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;  
 *  @version 1.0
 */

Call Time "R"

myName = "[Testing all encodings]"

Call Tick "Testing all encodings"
Call Tick "====================="
Say

Call Tick "Testing the CP-437 encoding..."
Call Tick ""
If "cp437"()     > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the CP-850 encoding..."
Call Tick ""
If "cp850"()     > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the CP-1252 encoding..."
Call Tick ""
If "cp1252"()    > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the ISO-8859-1 encoding..."
Call Tick ""
If "iso8859-1"() > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the UTF-8 encoding..."
Call Tick ""
If "utf8"()      > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the UTF-16 encoding..."
Call Tick ""
If "utf16"()     > 0 Then Exit 1

Call Tick ""
Call Tick "All tests for all encodings PASSED!"
Exit 0

Tick:
  Parse Value Time("E") WIth l"."r
  If r == "" Then t = "0.000"  
  Else            t = l"."Left(r,3)
  Say Right(t,10) myName Arg(1)
Return  
