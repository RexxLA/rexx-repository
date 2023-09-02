/**
 *
 *  <h2><code>inspect.rex</code></h2>
 *                        
 *<pre><code>   This file is part of <a href="https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools">the Unicode Tools Of Rexx</a> (TUTOR). 
 *   See <a href="https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/">https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/</a> for more information.
 *   Copyright &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;.
 *   License: Apache License 2.0 (<a href="https://www.apache.org/licenses/LICENSE-2.0">https://www.apache.org/licenses/LICENSE-2.0</a>).</code></pre> 
 *
 * <p><code>inspect.rex</code> is a sample program for the Rexx Tokenizer. It tokenizes a file,
 *   and prints the tokenization. By default it uses full, detailed tokenization, but this
 *   can be changed.
 *
 *  <h4>Version history</h4>
 *  
 *  <table class="table table-bordered">
 *    <tr><th>Ver.  <th>Aut.<th>Date    <th>Description
 *    <tr><td>00.4  <td>JMB <td>20230901<td>Initial release
 *  </table>
 *
 */

Parse Arg infile
quote = infile[1]
If Pos(quote,"""'") > 0 Then Parse Arg (quote)inFile(quote)

If Stream(inFile,"C","Query exists") == "" Then Do
  Say "File '"inFile"' not found."
  Exit 1
End

size = Stream(infile,"c","q size") -- This
array = CharIn(inFile,,size)~makeArray

t = .ooRexx.Unicode.Tokenizer~new(array,1)

Call Time "R"

Do i = 1 By 1
  x = t~getFullToken
  --If x[location] = "35 48 35 48" Then Trace ?a
If x[class] == "F" | x[class] == "E" Then Leave; Else

  Say i"["||X[location]"]: '"||X["VALUE"]"' ("||X[class] X[subclass]")"
  If x~hasIndex(absorbed) Then Do
    cloning = x[cloneIndex]
    Say "    ---> Absorbed:"
    Do j = 1 To x[absorbed]~items
      Say "    "j"["||x[absorbed][j][location]"] ("||X[absorbed][j][class] X[absorbed][j][subClass]"): '"||x[absorbed][j][value]"'" Copies("<==",j = cloning)
      If x[absorbed][j]~hasIndex(absorbed) Then Say "::::::::::" j
    End
  End

End

If x[class] == "E" Then Do
  Say
  Say "Syntax error" x[number] "on line" x[line]":" x[message]
  Say x[secondaryMessage]
End

Say Time("E")

::Requires Rexx.Tokenizer.cls
