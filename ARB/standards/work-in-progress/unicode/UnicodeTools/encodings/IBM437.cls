/** <h3>The <code>UTF-16</code> encoding class</h3>
 *
 *  <p>
 *    This classfile is part of
 *    <a href="https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools">the Unicode Tools for Rexx</a>.
 *
 *  <p>See
 *    <a href="https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/">
 *    https://github.com/RexxLA/rexx-repository/edit/master/ARB/standards/work-in-progress/unicode/UnicodeTools/
 *    </a>
 *    for more information.
 *
 *  <p>
 *    License: Apache License 2.0
 *    [<a href="https://www.apache.org/licenses/LICENSE-2.0">
 *    https://www.apache.org/licenses/LICENSE-2.0
 *    </a>]
 *
 *  <h4>Description</h4>
 *
 *  <p>
 *    The <code>CP437</code> class implements encoding/decoding from/to the CP437
 *    format.
 *
 *  <p>This is a subclass of <a href="Encoding.cls.html">the Encoding class</a>.
 *    Please refer to the documentation for <a href="Encoding.cls.html">that class</a>
 *    for additional details.
 *
 *  <h4>Version history</h4>
 *
 *  <table>
 *    <th><td><b>Ver.</b><td><b>Date</b><td>Aut.</td><td>Description
 *    <tr><td><b>1.0</b><td><b>20230817</b><td>RGF</td><td>Initial release.
 *    <tr><td><b>1.1</b><td><b>20230926</b><td>JMB</td><td>Change name to IBM437 as per IANA 
 *                                                         https://www.iana.org/assignments/character-sets/character-sets.xhtml
 *  </table>
 *
 *  @author &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;, 
 *    tables by Rony G. Flatscher &lt;rony.flatscher@wu.ac.at&lt;
 *  @version 1.0
 *  @see Encoding.cls
 *  @see https://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP437.TXT
 *
 */


.Encoding~register(.IBM437) -- Honor the contract with the .Encoding superclass

::Class IBM437 Subclass Encoding Public
::Constant name                  "IBM437"
::Constant aliases               "IBM-437 CP437 CP-437 437"
::Constant isFixedLength         1
::Constant bytesPerChar          1
::Constant maxBytesPerChar       1
::Constant endOfLine             "0A"X
::Constant alternateEndOfLine    "0D 0A"X
::Constant useAlternateEndOfLine ( .endOfLine == "0D0A"X )
::Constant endOfLineAlignment    1


/**
 * CP437 encoding will fail, unless the argument string contains
 * only characters that can be represented in CP437.
 */

::Method encode Class
  Expose encode. -- Built by the "activate" method

  Use Strict Arg string, option = ""

  utf32 = self~prepareEncode(string, option)

  If string == "" Then Return ""

  syntax = Upper(option) = "SYNTAX"

  res = .MutableBuffer~new -- Will hold the result
  Do i = 1 To Length(utf32) By 4
    code = Strip(C2X(utf32[i,4]),"L",0)
    If Length(code) < 4 Then code = Right(code,4,0)
    enc = encode.code
    If enc == "" Then
      If Syntax Then
        Raise Syntax 23.900 Additional("Cannot encode Unicode codepoint U+"code" to CP437")
      Else Return ""
    res~append( enc )
  End

  Return res~string

/**
 * CP437 decoding always succeeds (i.e., there is no such thing as a badly
 * encoded CP437 sequence).
 */
::Method decode Class
  Expose decode. -- Built by the "activate" method

  Use Strict Arg string, format = "", errorHandling = ""

  -- Check that the supplied arguments are OK, and raise a Syntax condition if not
  Parse Value self~checkDecodeOptions(format,errorHandling) With errorHandling returnUTF8 returnUTF32

  -- Null strings always decode to the null string.
  If string == "" Then Signal StringIsEmpty

  -- Will hold the utf8 value, if needed
  utf8  = .MutableBuffer~new

  -- Will hold the utf32 value, if needed
  utf32 = .MutableBuffer~new

  -- CP437 decoding always succeeds (i.e., there is no such thing as a badly
  -- encoded CP437 sequence).
  If \returnUTF8, \returnUTF32 Then Return 1

  length = Length(string)

  -- We want some real decoding after all
  Do i = 1 To length
    code = decode.[string[i]]
    If returnUTF8  Then Do
      n = X2D(code)
      b = X2B(code)
      Select
        When n <= 127   Then utf8~append( X2C(code[3,2]) )
        When n <= 2047  Then utf8~append( X2C(B2X("110"SubStr(b,6,5)"10"Right(b,6))) )
        Otherwise            utf8~append( X2C(B2X("1110"Left(b,4)"10"SubStr(b,5,6)"10"Right(b,6))) )
      End
    End
    If returnUTF32 Then utf32~append( Right(X2C(code),4,"00"X) )
  End

StringIsGood:
  If returnUTF8 Then
    If returnUTF32 Then Return utf8~string, utf32~string -- An array
    Else                Return utf8~string
  If returnUTF32   Then Return utf32~string
  -- Validate only
  Return 1

StringIsEmpty:
  If returnUTF8  Then Return ""
  If returnUTF32 Then Return ""
  Return 1

/**
 *  <p>The <code>activate</code> class method is automatically called at the end
 *  of the class construction. It creates two stems, <code>encode.</code> and
 *  <code>decode.</code>, that will be used by the <code>encode</code> and
 *  <code>decode</code> methods.
 *
 *  <p>See https://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP437.TXT
 *  for details.
 *
 */

::Method Activate        Class
  Expose encode. decode.

  encode. = ""
  decode. = ""
  Do i = 0 To 127
    decode.[i~d2x~x2c] = Right(i~d2x,4,0)
    encode.[Right(i~d2x,4,0)] = i~d2x~x2c
  End
decode.['00'X ] = '0000'; encode.['0000'] = '00'X
  decode.['01'X ] = '0001'; encode.['0001'] = '01'X
  decode.['02'X ] = '0002'; encode.['0002'] = '02'X
  decode.['03'X ] = '0003'; encode.['0003'] = '03'X
  decode.['04'X ] = '0004'; encode.['0004'] = '04'X
  decode.['05'X ] = '0005'; encode.['0005'] = '05'X
  decode.['06'X ] = '0006'; encode.['0006'] = '06'X
  decode.['07'X ] = '0007'; encode.['0007'] = '07'X
  decode.['08'X ] = '0008'; encode.['0008'] = '08'X
  decode.['09'X ] = '0009'; encode.['0009'] = '09'X
  decode.['0A'X ] = '000A'; encode.['000A'] = '0A'X
  decode.['0B'X ] = '000B'; encode.['000B'] = '0B'X
  decode.['0C'X ] = '000C'; encode.['000C'] = '0C'X
  decode.['0D'X ] = '000D'; encode.['000D'] = '0D'X
  decode.['0E'X ] = '000E'; encode.['000E'] = '0E'X
  decode.['0F'X ] = '000F'; encode.['000F'] = '0F'X
  decode.['10'X ] = '0010'; encode.['0010'] = '10'X
  decode.['11'X ] = '0011'; encode.['0011'] = '11'X
  decode.['12'X ] = '0012'; encode.['0012'] = '12'X
  decode.['13'X ] = '0013'; encode.['0013'] = '13'X
  decode.['14'X ] = '0014'; encode.['0014'] = '14'X
  decode.['15'X ] = '0015'; encode.['0015'] = '15'X
  decode.['16'X ] = '0016'; encode.['0016'] = '16'X
  decode.['17'X ] = '0017'; encode.['0017'] = '17'X
  decode.['18'X ] = '0018'; encode.['0018'] = '18'X
  decode.['19'X ] = '0019'; encode.['0019'] = '19'X
  decode.['1A'X ] = '001A'; encode.['001A'] = '1A'X
  decode.['1B'X ] = '001B'; encode.['001B'] = '1B'X
  decode.['1C'X ] = '001C'; encode.['001C'] = '1C'X
  decode.['1D'X ] = '001D'; encode.['001D'] = '1D'X
  decode.['1E'X ] = '001E'; encode.['001E'] = '1E'X
  decode.['1F'X ] = '001F'; encode.['001F'] = '1F'X
  decode.['20'X ] = '0020'; encode.['0020'] = '20'X
  decode.['21'X ] = '0021'; encode.['0021'] = '21'X
  decode.['22'X ] = '0022'; encode.['0022'] = '22'X
  decode.['23'X ] = '0023'; encode.['0023'] = '23'X
  decode.['24'X ] = '0024'; encode.['0024'] = '24'X
  decode.['25'X ] = '0025'; encode.['0025'] = '25'X
  decode.['26'X ] = '0026'; encode.['0026'] = '26'X
  decode.['27'X ] = '0027'; encode.['0027'] = '27'X
  decode.['28'X ] = '0028'; encode.['0028'] = '28'X
  decode.['29'X ] = '0029'; encode.['0029'] = '29'X
  decode.['2A'X ] = '002A'; encode.['002A'] = '2A'X
  decode.['2B'X ] = '002B'; encode.['002B'] = '2B'X
  decode.['2C'X ] = '002C'; encode.['002C'] = '2C'X
  decode.['2D'X ] = '002D'; encode.['002D'] = '2D'X
  decode.['2E'X ] = '002E'; encode.['002E'] = '2E'X
  decode.['2F'X ] = '002F'; encode.['002F'] = '2F'X
  decode.['30'X ] = '0030'; encode.['0030'] = '30'X
  decode.['31'X ] = '0031'; encode.['0031'] = '31'X
  decode.['32'X ] = '0032'; encode.['0032'] = '32'X
  decode.['33'X ] = '0033'; encode.['0033'] = '33'X
  decode.['34'X ] = '0034'; encode.['0034'] = '34'X
  decode.['35'X ] = '0035'; encode.['0035'] = '35'X
  decode.['36'X ] = '0036'; encode.['0036'] = '36'X
  decode.['37'X ] = '0037'; encode.['0037'] = '37'X
  decode.['38'X ] = '0038'; encode.['0038'] = '38'X
  decode.['39'X ] = '0039'; encode.['0039'] = '39'X
  decode.['3A'X ] = '003A'; encode.['003A'] = '3A'X
  decode.['3B'X ] = '003B'; encode.['003B'] = '3B'X
  decode.['3C'X ] = '003C'; encode.['003C'] = '3C'X
  decode.['3D'X ] = '003D'; encode.['003D'] = '3D'X
  decode.['3E'X ] = '003E'; encode.['003E'] = '3E'X
  decode.['3F'X ] = '003F'; encode.['003F'] = '3F'X
  decode.['40'X ] = '0040'; encode.['0040'] = '40'X
  decode.['41'X ] = '0041'; encode.['0041'] = '41'X
  decode.['42'X ] = '0042'; encode.['0042'] = '42'X
  decode.['43'X ] = '0043'; encode.['0043'] = '43'X
  decode.['44'X ] = '0044'; encode.['0044'] = '44'X
  decode.['45'X ] = '0045'; encode.['0045'] = '45'X
  decode.['46'X ] = '0046'; encode.['0046'] = '46'X
  decode.['47'X ] = '0047'; encode.['0047'] = '47'X
  decode.['48'X ] = '0048'; encode.['0048'] = '48'X
  decode.['49'X ] = '0049'; encode.['0049'] = '49'X
  decode.['4A'X ] = '004A'; encode.['004A'] = '4A'X
  decode.['4B'X ] = '004B'; encode.['004B'] = '4B'X
  decode.['4C'X ] = '004C'; encode.['004C'] = '4C'X
  decode.['4D'X ] = '004D'; encode.['004D'] = '4D'X
  decode.['4E'X ] = '004E'; encode.['004E'] = '4E'X
  decode.['4F'X ] = '004F'; encode.['004F'] = '4F'X
  decode.['50'X ] = '0050'; encode.['0050'] = '50'X
  decode.['51'X ] = '0051'; encode.['0051'] = '51'X
  decode.['52'X ] = '0052'; encode.['0052'] = '52'X
  decode.['53'X ] = '0053'; encode.['0053'] = '53'X
  decode.['54'X ] = '0054'; encode.['0054'] = '54'X
  decode.['55'X ] = '0055'; encode.['0055'] = '55'X
  decode.['56'X ] = '0056'; encode.['0056'] = '56'X
  decode.['57'X ] = '0057'; encode.['0057'] = '57'X
  decode.['58'X ] = '0058'; encode.['0058'] = '58'X
  decode.['59'X ] = '0059'; encode.['0059'] = '59'X
  decode.['5A'X ] = '005A'; encode.['005A'] = '5A'X
  decode.['5B'X ] = '005B'; encode.['005B'] = '5B'X
  decode.['5C'X ] = '005C'; encode.['005C'] = '5C'X
  decode.['5D'X ] = '005D'; encode.['005D'] = '5D'X
  decode.['5E'X ] = '005E'; encode.['005E'] = '5E'X
  decode.['5F'X ] = '005F'; encode.['005F'] = '5F'X
  decode.['60'X ] = '0060'; encode.['0060'] = '60'X
  decode.['61'X ] = '0061'; encode.['0061'] = '61'X
  decode.['62'X ] = '0062'; encode.['0062'] = '62'X
  decode.['63'X ] = '0063'; encode.['0063'] = '63'X
  decode.['64'X ] = '0064'; encode.['0064'] = '64'X
  decode.['65'X ] = '0065'; encode.['0065'] = '65'X
  decode.['66'X ] = '0066'; encode.['0066'] = '66'X
  decode.['67'X ] = '0067'; encode.['0067'] = '67'X
  decode.['68'X ] = '0068'; encode.['0068'] = '68'X
  decode.['69'X ] = '0069'; encode.['0069'] = '69'X
  decode.['6A'X ] = '006A'; encode.['006A'] = '6A'X
  decode.['6B'X ] = '006B'; encode.['006B'] = '6B'X
  decode.['6C'X ] = '006C'; encode.['006C'] = '6C'X
  decode.['6D'X ] = '006D'; encode.['006D'] = '6D'X
  decode.['6E'X ] = '006E'; encode.['006E'] = '6E'X
  decode.['6F'X ] = '006F'; encode.['006F'] = '6F'X
  decode.['70'X ] = '0070'; encode.['0070'] = '70'X
  decode.['71'X ] = '0071'; encode.['0071'] = '71'X
  decode.['72'X ] = '0072'; encode.['0072'] = '72'X
  decode.['73'X ] = '0073'; encode.['0073'] = '73'X
  decode.['74'X ] = '0074'; encode.['0074'] = '74'X
  decode.['75'X ] = '0075'; encode.['0075'] = '75'X
  decode.['76'X ] = '0076'; encode.['0076'] = '76'X
  decode.['77'X ] = '0077'; encode.['0077'] = '77'X
  decode.['78'X ] = '0078'; encode.['0078'] = '78'X
  decode.['79'X ] = '0079'; encode.['0079'] = '79'X
  decode.['7A'X ] = '007A'; encode.['007A'] = '7A'X
  decode.['7B'X ] = '007B'; encode.['007B'] = '7B'X
  decode.['7C'X ] = '007C'; encode.['007C'] = '7C'X
  decode.['7D'X ] = '007D'; encode.['007D'] = '7D'X
  decode.['7E'X ] = '007E'; encode.['007E'] = '7E'X
  decode.['7F'X ] = '007F'; encode.['007F'] = '7F'X
  decode.['80'X ] = '00C7'; encode.['00C7'] = '80'X
  decode.['81'X ] = '00FC'; encode.['00FC'] = '81'X
  decode.['82'X ] = '00E9'; encode.['00E9'] = '82'X
  decode.['83'X ] = '00E2'; encode.['00E2'] = '83'X
  decode.['84'X ] = '00E4'; encode.['00E4'] = '84'X
  decode.['85'X ] = '00E0'; encode.['00E0'] = '85'X
  decode.['86'X ] = '00E5'; encode.['00E5'] = '86'X
  decode.['87'X ] = '00E7'; encode.['00E7'] = '87'X
  decode.['88'X ] = '00EA'; encode.['00EA'] = '88'X
  decode.['89'X ] = '00EB'; encode.['00EB'] = '89'X
  decode.['8A'X ] = '00E8'; encode.['00E8'] = '8A'X
  decode.['8B'X ] = '00EF'; encode.['00EF'] = '8B'X
  decode.['8C'X ] = '00EE'; encode.['00EE'] = '8C'X
  decode.['8D'X ] = '00EC'; encode.['00EC'] = '8D'X
  decode.['8E'X ] = '00C4'; encode.['00C4'] = '8E'X
  decode.['8F'X ] = '00C5'; encode.['00C5'] = '8F'X
  decode.['90'X ] = '00C9'; encode.['00C9'] = '90'X
  decode.['91'X ] = '00E6'; encode.['00E6'] = '91'X
  decode.['92'X ] = '00C6'; encode.['00C6'] = '92'X
  decode.['93'X ] = '00F4'; encode.['00F4'] = '93'X
  decode.['94'X ] = '00F6'; encode.['00F6'] = '94'X
  decode.['95'X ] = '00F2'; encode.['00F2'] = '95'X
  decode.['96'X ] = '00FB'; encode.['00FB'] = '96'X
  decode.['97'X ] = '00F9'; encode.['00F9'] = '97'X
  decode.['98'X ] = '00FF'; encode.['00FF'] = '98'X
  decode.['99'X ] = '00D6'; encode.['00D6'] = '99'X
  decode.['9A'X ] = '00DC'; encode.['00DC'] = '9A'X
  decode.['9B'X ] = '00A2'; encode.['00A2'] = '9B'X
  decode.['9C'X ] = '00A3'; encode.['00A3'] = '9C'X
  decode.['9D'X ] = '00A5'; encode.['00A5'] = '9D'X
  decode.['9E'X ] = '20A7'; encode.['20A7'] = '9E'X
  decode.['9F'X ] = '0192'; encode.['0192'] = '9F'X
  decode.['A0'X ] = '00E1'; encode.['00E1'] = 'A0'X
  decode.['A1'X ] = '00ED'; encode.['00ED'] = 'A1'X
  decode.['A2'X ] = '00F3'; encode.['00F3'] = 'A2'X
  decode.['A3'X ] = '00FA'; encode.['00FA'] = 'A3'X
  decode.['A4'X ] = '00F1'; encode.['00F1'] = 'A4'X
  decode.['A5'X ] = '00D1'; encode.['00D1'] = 'A5'X
  decode.['A6'X ] = '00AA'; encode.['00AA'] = 'A6'X
  decode.['A7'X ] = '00BA'; encode.['00BA'] = 'A7'X
  decode.['A8'X ] = '00BF'; encode.['00BF'] = 'A8'X
  decode.['A9'X ] = '2310'; encode.['2310'] = 'A9'X
  decode.['AA'X ] = '00AC'; encode.['00AC'] = 'AA'X
  decode.['AB'X ] = '00BD'; encode.['00BD'] = 'AB'X
  decode.['AC'X ] = '00BC'; encode.['00BC'] = 'AC'X
  decode.['AD'X ] = '00A1'; encode.['00A1'] = 'AD'X
  decode.['AE'X ] = '00AB'; encode.['00AB'] = 'AE'X
  decode.['AF'X ] = '00BB'; encode.['00BB'] = 'AF'X
  decode.['B0'X ] = '2591'; encode.['2591'] = 'B0'X
  decode.['B1'X ] = '2592'; encode.['2592'] = 'B1'X
  decode.['B2'X ] = '2593'; encode.['2593'] = 'B2'X
  decode.['B3'X ] = '2502'; encode.['2502'] = 'B3'X
  decode.['B4'X ] = '2524'; encode.['2524'] = 'B4'X
  decode.['B5'X ] = '2561'; encode.['2561'] = 'B5'X
  decode.['B6'X ] = '2562'; encode.['2562'] = 'B6'X
  decode.['B7'X ] = '2556'; encode.['2556'] = 'B7'X
  decode.['B8'X ] = '2555'; encode.['2555'] = 'B8'X
  decode.['B9'X ] = '2563'; encode.['2563'] = 'B9'X
  decode.['BA'X ] = '2551'; encode.['2551'] = 'BA'X
  decode.['BB'X ] = '2557'; encode.['2557'] = 'BB'X
  decode.['BC'X ] = '255D'; encode.['255D'] = 'BC'X
  decode.['BD'X ] = '255C'; encode.['255C'] = 'BD'X
  decode.['BE'X ] = '255B'; encode.['255B'] = 'BE'X
  decode.['BF'X ] = '2510'; encode.['2510'] = 'BF'X
  decode.['C0'X ] = '2514'; encode.['2514'] = 'C0'X
  decode.['C1'X ] = '2534'; encode.['2534'] = 'C1'X
  decode.['C2'X ] = '252C'; encode.['252C'] = 'C2'X
  decode.['C3'X ] = '251C'; encode.['251C'] = 'C3'X
  decode.['C4'X ] = '2500'; encode.['2500'] = 'C4'X
  decode.['C5'X ] = '253C'; encode.['253C'] = 'C5'X
  decode.['C6'X ] = '255E'; encode.['255E'] = 'C6'X
  decode.['C7'X ] = '255F'; encode.['255F'] = 'C7'X
  decode.['C8'X ] = '255A'; encode.['255A'] = 'C8'X
  decode.['C9'X ] = '2554'; encode.['2554'] = 'C9'X
  decode.['CA'X ] = '2569'; encode.['2569'] = 'CA'X
  decode.['CB'X ] = '2566'; encode.['2566'] = 'CB'X
  decode.['CC'X ] = '2560'; encode.['2560'] = 'CC'X
  decode.['CD'X ] = '2550'; encode.['2550'] = 'CD'X
  decode.['CE'X ] = '256C'; encode.['256C'] = 'CE'X
  decode.['CF'X ] = '2567'; encode.['2567'] = 'CF'X
  decode.['D0'X ] = '2568'; encode.['2568'] = 'D0'X
  decode.['D1'X ] = '2564'; encode.['2564'] = 'D1'X
  decode.['D2'X ] = '2565'; encode.['2565'] = 'D2'X
  decode.['D3'X ] = '2559'; encode.['2559'] = 'D3'X
  decode.['D4'X ] = '2558'; encode.['2558'] = 'D4'X
  decode.['D5'X ] = '2552'; encode.['2552'] = 'D5'X
  decode.['D6'X ] = '2553'; encode.['2553'] = 'D6'X
  decode.['D7'X ] = '256B'; encode.['256B'] = 'D7'X
  decode.['D8'X ] = '256A'; encode.['256A'] = 'D8'X
  decode.['D9'X ] = '2518'; encode.['2518'] = 'D9'X
  decode.['DA'X ] = '250C'; encode.['250C'] = 'DA'X
  decode.['DB'X ] = '2588'; encode.['2588'] = 'DB'X
  decode.['DC'X ] = '2584'; encode.['2584'] = 'DC'X
  decode.['DD'X ] = '258C'; encode.['258C'] = 'DD'X
  decode.['DE'X ] = '2590'; encode.['2590'] = 'DE'X
  decode.['DF'X ] = '2580'; encode.['2580'] = 'DF'X
  decode.['E0'X ] = '03B1'; encode.['03B1'] = 'E0'X
  decode.['E1'X ] = '00DF'; encode.['00DF'] = 'E1'X
  decode.['E2'X ] = '0393'; encode.['0393'] = 'E2'X
  decode.['E3'X ] = '03C0'; encode.['03C0'] = 'E3'X
  decode.['E4'X ] = '03A3'; encode.['03A3'] = 'E4'X
  decode.['E5'X ] = '03C3'; encode.['03C3'] = 'E5'X
  decode.['E6'X ] = '00B5'; encode.['00B5'] = 'E6'X
  decode.['E7'X ] = '03C4'; encode.['03C4'] = 'E7'X
  decode.['E8'X ] = '03A6'; encode.['03A6'] = 'E8'X
  decode.['E9'X ] = '0398'; encode.['0398'] = 'E9'X
  decode.['EA'X ] = '03A9'; encode.['03A9'] = 'EA'X
  decode.['EB'X ] = '03B4'; encode.['03B4'] = 'EB'X
  decode.['EC'X ] = '221E'; encode.['221E'] = 'EC'X
  decode.['ED'X ] = '03C6'; encode.['03C6'] = 'ED'X
  decode.['EE'X ] = '03B5'; encode.['03B5'] = 'EE'X
  decode.['EF'X ] = '2229'; encode.['2229'] = 'EF'X
  decode.['F0'X ] = '2261'; encode.['2261'] = 'F0'X
  decode.['F1'X ] = '00B1'; encode.['00B1'] = 'F1'X
  decode.['F2'X ] = '2265'; encode.['2265'] = 'F2'X
  decode.['F3'X ] = '2264'; encode.['2264'] = 'F3'X
  decode.['F4'X ] = '2320'; encode.['2320'] = 'F4'X
  decode.['F5'X ] = '2321'; encode.['2321'] = 'F5'X
  decode.['F6'X ] = '00F7'; encode.['00F7'] = 'F6'X
  decode.['F7'X ] = '2248'; encode.['2248'] = 'F7'X
  decode.['F8'X ] = '00B0'; encode.['00B0'] = 'F8'X
  decode.['F9'X ] = '2219'; encode.['2219'] = 'F9'X
  decode.['FA'X ] = '00B7'; encode.['00B7'] = 'FA'X
  decode.['FB'X ] = '221A'; encode.['221A'] = 'FB'X
  decode.['FC'X ] = '207F'; encode.['207F'] = 'FC'X
  decode.['FD'X ] = '00B2'; encode.['00B2'] = 'FD'X
  decode.['FE'X ] = '25A0'; encode.['25A0'] = 'FE'X
  decode.['FF'X ] = '00A0'; encode.['00A0'] = 'FF'X