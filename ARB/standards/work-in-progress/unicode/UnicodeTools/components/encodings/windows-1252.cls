/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/


/** <h3>The <code>UTF-16</code> encoding class</h3>
 *
 *  <p>
 *    The <code>CP1252</code> class implements encoding/decoding from/to the CP1252
 *    format.
 *
 *  <p><b>Note:</b> From <a href="https://en.wikipedia.org/wiki/Windows-1252">https://en.wikipedia.org/wiki/Windows-1252</a>:
 *    "According to the information on Microsoft's and the Unicode Consortium's websites, 
 *     positions 81, 8D, 8F, 90, and 9D are unused; however, the Windows API MultiByteToWideChar 
 *     maps these to the corresponding C1 control codes. The 'best fit' mapping documents this behavior, too."
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
 *    <tr><td><b>1.1</b><td><b>20230926</b><td>JMB</td><td>Change name to Windows-1252 as per IANA 
 *                                                         https://www.iana.org/assignments/character-sets/character-sets.xhtml 
 *  </table>
 *
 *  @author &copy; 2023, Josep Maria Blasco &lt;josep.maria.blasco@epbcn.com&gt;  
 *    tables by Rony G. Flatscher &lt;rony.flatscher@wu.ac.at&lt;
 *  @see https://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP1252.TXT
 *
 */

.Encoding~register(.Windows1252) -- Honor the contract with the .Encoding superclass

::Class Windows1252 Subclass Encoding Public
::Constant name                  "Windows-1252"
::Constant aliases               "Windows1252 CP1252 CP-1252 1252"
::Constant isFixedLength         1
::Constant bytesPerChar          1
::Constant maxBytesPerChar       1
::Constant endOfLine             "0A"X
::Constant alternateEndOfLine    "0D 0A"X
::Constant useAlternateEndOfLine ( .endOfLine == "0D0A"X )
::Constant endOfLineAlignment    1


/**
 * CP1252 encoding will fail, unless the argument string contains
 * only characters that can be represented in CP1252.
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
        Raise Syntax 23.900 Additional("Cannot encode Unicode codepoint U+"code" to CP1252")
      Else Return ""
    res~append( enc )
  End

  Return res~string

/**
 * CP1252 decoding always succeeds (i.e., there is no such thing as a badly
 * encoded CP1252 sequence).
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

  -- CP1252 decoding always succeeds (i.e., there is no such thing as a badly
  -- encoded CP1252 sequence).
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
  If returnUTF8 , returnUTF32  Then Do
    -- Several targets. Return a stem.
    s. = .Stem~new()
    s.["UTF8"]  = utf8  ~string
    s.["UTF32"] = utf32 ~string
    Return s.
  End
  If returnUTF8  Then Return utf8 ~string
  If returnUTF32 Then Return utf32~string
  -- Validation only
  Return 1

StringIsEmpty:  
  If returnUTF8 , returnUTF32  Then Do
    -- Several targets. Return a stem.
    s. = .Stem~new()
    s.["UTF8"]  = ""
    s.["UTF32"] = ""
    Return s.
  End
  If returnUTF8 | returnUTF32  Then Return ""
  -- Validation only
  Return 1  

/**
 *  <p>The <code>activate</code> class method is automatically called at the end
 *  of the class construction. It creates two stems, <code>encode.</code> and
 *  <code>decode.</code>, that will be used by the <code>encode</code> and
 *  <code>decode</code> methods.
 *
 *  <p>See https://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/CP1252.TXT
 *  for details.
 *
 */

::Method Activate        Class
  Expose encode. decode.

  encode. = ""
  decode. = ""
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
  decode.['80'X ] = '20AC'; encode.['20AC'] = '80'X
  decode.['81'X ] = '0081'; encode.['0081'] = '81'X
  decode.['82'X ] = '201A'; encode.['201A'] = '82'X
  decode.['83'X ] = '0192'; encode.['0192'] = '83'X
  decode.['84'X ] = '201E'; encode.['201E'] = '84'X
  decode.['85'X ] = '2026'; encode.['2026'] = '85'X
  decode.['86'X ] = '2020'; encode.['2020'] = '86'X
  decode.['87'X ] = '2021'; encode.['2021'] = '87'X
  decode.['88'X ] = '02C6'; encode.['02C6'] = '88'X
  decode.['89'X ] = '2030'; encode.['2030'] = '89'X
  decode.['8A'X ] = '0160'; encode.['0160'] = '8A'X
  decode.['8B'X ] = '2039'; encode.['2039'] = '8B'X
  decode.['8C'X ] = '0152'; encode.['0152'] = '8C'X
  decode.['8D'X ] = '008D'; encode.['008D'] = '8D'X
  decode.['8E'X ] = '017D'; encode.['017D'] = '8E'X
  decode.['8F'X ] = '008F'; encode.['008F'] = '8F'X
  decode.['90'X ] = '0090'; encode.['0090'] = '90'X
  decode.['91'X ] = '2018'; encode.['2018'] = '91'X
  decode.['92'X ] = '2019'; encode.['2019'] = '92'X
  decode.['93'X ] = '201C'; encode.['201C'] = '93'X
  decode.['94'X ] = '201D'; encode.['201D'] = '94'X
  decode.['95'X ] = '2022'; encode.['2022'] = '95'X
  decode.['96'X ] = '2013'; encode.['2013'] = '96'X
  decode.['97'X ] = '2014'; encode.['2014'] = '97'X
  decode.['98'X ] = '02DC'; encode.['02DC'] = '98'X
  decode.['99'X ] = '2122'; encode.['2122'] = '99'X
  decode.['9A'X ] = '0161'; encode.['0161'] = '9A'X
  decode.['9B'X ] = '203A'; encode.['203A'] = '9B'X
  decode.['9C'X ] = '0153'; encode.['0153'] = '9C'X
  decode.['9D'X ] = '009D'; encode.['009D'] = '9D'X
  decode.['9E'X ] = '017E'; encode.['017E'] = '9E'X
  decode.['9F'X ] = '0178'; encode.['0178'] = '9F'X
  decode.['A0'X ] = '00A0'; encode.['00A0'] = 'A0'X
  decode.['A1'X ] = '00A1'; encode.['00A1'] = 'A1'X
  decode.['A2'X ] = '00A2'; encode.['00A2'] = 'A2'X
  decode.['A3'X ] = '00A3'; encode.['00A3'] = 'A3'X
  decode.['A4'X ] = '00A4'; encode.['00A4'] = 'A4'X
  decode.['A5'X ] = '00A5'; encode.['00A5'] = 'A5'X
  decode.['A6'X ] = '00A6'; encode.['00A6'] = 'A6'X
  decode.['A7'X ] = '00A7'; encode.['00A7'] = 'A7'X
  decode.['A8'X ] = '00A8'; encode.['00A8'] = 'A8'X
  decode.['A9'X ] = '00A9'; encode.['00A9'] = 'A9'X
  decode.['AA'X ] = '00AA'; encode.['00AA'] = 'AA'X
  decode.['AB'X ] = '00AB'; encode.['00AB'] = 'AB'X
  decode.['AC'X ] = '00AC'; encode.['00AC'] = 'AC'X
  decode.['AD'X ] = '00AD'; encode.['00AD'] = 'AD'X
  decode.['AE'X ] = '00AE'; encode.['00AE'] = 'AE'X
  decode.['AF'X ] = '00AF'; encode.['00AF'] = 'AF'X
  decode.['B0'X ] = '00B0'; encode.['00B0'] = 'B0'X
  decode.['B1'X ] = '00B1'; encode.['00B1'] = 'B1'X
  decode.['B2'X ] = '00B2'; encode.['00B2'] = 'B2'X
  decode.['B3'X ] = '00B3'; encode.['00B3'] = 'B3'X
  decode.['B4'X ] = '00B4'; encode.['00B4'] = 'B4'X
  decode.['B5'X ] = '00B5'; encode.['00B5'] = 'B5'X
  decode.['B6'X ] = '00B6'; encode.['00B6'] = 'B6'X
  decode.['B7'X ] = '00B7'; encode.['00B7'] = 'B7'X
  decode.['B8'X ] = '00B8'; encode.['00B8'] = 'B8'X
  decode.['B9'X ] = '00B9'; encode.['00B9'] = 'B9'X
  decode.['BA'X ] = '00BA'; encode.['00BA'] = 'BA'X
  decode.['BB'X ] = '00BB'; encode.['00BB'] = 'BB'X
  decode.['BC'X ] = '00BC'; encode.['00BC'] = 'BC'X
  decode.['BD'X ] = '00BD'; encode.['00BD'] = 'BD'X
  decode.['BE'X ] = '00BE'; encode.['00BE'] = 'BE'X
  decode.['BF'X ] = '00BF'; encode.['00BF'] = 'BF'X
  decode.['C0'X ] = '00C0'; encode.['00C0'] = 'C0'X
  decode.['C1'X ] = '00C1'; encode.['00C1'] = 'C1'X
  decode.['C2'X ] = '00C2'; encode.['00C2'] = 'C2'X
  decode.['C3'X ] = '00C3'; encode.['00C3'] = 'C3'X
  decode.['C4'X ] = '00C4'; encode.['00C4'] = 'C4'X
  decode.['C5'X ] = '00C5'; encode.['00C5'] = 'C5'X
  decode.['C6'X ] = '00C6'; encode.['00C6'] = 'C6'X
  decode.['C7'X ] = '00C7'; encode.['00C7'] = 'C7'X
  decode.['C8'X ] = '00C8'; encode.['00C8'] = 'C8'X
  decode.['C9'X ] = '00C9'; encode.['00C9'] = 'C9'X
  decode.['CA'X ] = '00CA'; encode.['00CA'] = 'CA'X
  decode.['CB'X ] = '00CB'; encode.['00CB'] = 'CB'X
  decode.['CC'X ] = '00CC'; encode.['00CC'] = 'CC'X
  decode.['CD'X ] = '00CD'; encode.['00CD'] = 'CD'X
  decode.['CE'X ] = '00CE'; encode.['00CE'] = 'CE'X
  decode.['CF'X ] = '00CF'; encode.['00CF'] = 'CF'X
  decode.['D0'X ] = '00D0'; encode.['00D0'] = 'D0'X
  decode.['D1'X ] = '00D1'; encode.['00D1'] = 'D1'X
  decode.['D2'X ] = '00D2'; encode.['00D2'] = 'D2'X
  decode.['D3'X ] = '00D3'; encode.['00D3'] = 'D3'X
  decode.['D4'X ] = '00D4'; encode.['00D4'] = 'D4'X
  decode.['D5'X ] = '00D5'; encode.['00D5'] = 'D5'X
  decode.['D6'X ] = '00D6'; encode.['00D6'] = 'D6'X
  decode.['D7'X ] = '00D7'; encode.['00D7'] = 'D7'X
  decode.['D8'X ] = '00D8'; encode.['00D8'] = 'D8'X
  decode.['D9'X ] = '00D9'; encode.['00D9'] = 'D9'X
  decode.['DA'X ] = '00DA'; encode.['00DA'] = 'DA'X
  decode.['DB'X ] = '00DB'; encode.['00DB'] = 'DB'X
  decode.['DC'X ] = '00DC'; encode.['00DC'] = 'DC'X
  decode.['DD'X ] = '00DD'; encode.['00DD'] = 'DD'X
  decode.['DE'X ] = '00DE'; encode.['00DE'] = 'DE'X
  decode.['DF'X ] = '00DF'; encode.['00DF'] = 'DF'X
  decode.['E0'X ] = '00E0'; encode.['00E0'] = 'E0'X
  decode.['E1'X ] = '00E1'; encode.['00E1'] = 'E1'X
  decode.['E2'X ] = '00E2'; encode.['00E2'] = 'E2'X
  decode.['E3'X ] = '00E3'; encode.['00E3'] = 'E3'X
  decode.['E4'X ] = '00E4'; encode.['00E4'] = 'E4'X
  decode.['E5'X ] = '00E5'; encode.['00E5'] = 'E5'X
  decode.['E6'X ] = '00E6'; encode.['00E6'] = 'E6'X
  decode.['E7'X ] = '00E7'; encode.['00E7'] = 'E7'X
  decode.['E8'X ] = '00E8'; encode.['00E8'] = 'E8'X
  decode.['E9'X ] = '00E9'; encode.['00E9'] = 'E9'X
  decode.['EA'X ] = '00EA'; encode.['00EA'] = 'EA'X
  decode.['EB'X ] = '00EB'; encode.['00EB'] = 'EB'X
  decode.['EC'X ] = '00EC'; encode.['00EC'] = 'EC'X
  decode.['ED'X ] = '00ED'; encode.['00ED'] = 'ED'X
  decode.['EE'X ] = '00EE'; encode.['00EE'] = 'EE'X
  decode.['EF'X ] = '00EF'; encode.['00EF'] = 'EF'X
  decode.['F0'X ] = '00F0'; encode.['00F0'] = 'F0'X
  decode.['F1'X ] = '00F1'; encode.['00F1'] = 'F1'X
  decode.['F2'X ] = '00F2'; encode.['00F2'] = 'F2'X
  decode.['F3'X ] = '00F3'; encode.['00F3'] = 'F3'X
  decode.['F4'X ] = '00F4'; encode.['00F4'] = 'F4'X
  decode.['F5'X ] = '00F5'; encode.['00F5'] = 'F5'X
  decode.['F6'X ] = '00F6'; encode.['00F6'] = 'F6'X
  decode.['F7'X ] = '00F7'; encode.['00F7'] = 'F7'X
  decode.['F8'X ] = '00F8'; encode.['00F8'] = 'F8'X
  decode.['F9'X ] = '00F9'; encode.['00F9'] = 'F9'X
  decode.['FA'X ] = '00FA'; encode.['00FA'] = 'FA'X
  decode.['FB'X ] = '00FB'; encode.['00FB'] = 'FB'X
  decode.['FC'X ] = '00FC'; encode.['00FC'] = 'FC'X
  decode.['FD'X ] = '00FD'; encode.['00FD'] = 'FD'X
  decode.['FE'X ] = '00FE'; encode.['00FE'] = 'FE'X
  decode.['FF'X ] = '00FF'; encode.['00FF'] = 'FF'X