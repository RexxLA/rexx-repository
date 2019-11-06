<html>
<font face="Verdana, Arial, Helvetica, Sans-serif" size="3">
<head>
<title>
How to REXXSKEL
</title>
</head>        

<body>
<h3>
How to REXXSKEL
</h3>          

<p align="justify"> 
 
 <font face="Courier New">REXXSKEL</font> 
 is the kernel around which all of my tools are built. &nbsp              
 Some minimal understanding of what 
 <font face="Courier New">REXXSKEL</font> 
 is and what it does is a           
 prerequisite for understanding or maintaining the code
 you'll find here.                        

<p align="justify"> 
 <font face="Courier New">REXXSKEL</font>, 
 unfortunately, is not a static entity. &nbsp
 It changes over              
 time, and it is normal to find a dozen different versions in current           
 use throughout the codebase. &nbsp
 I try very hard to            
 keep 
 <font face="Courier New">REXXSKEL</font> 
 'backward-compatible' so that retrofitting does not              
 become necessary but I have no compunctions about improving it
 when and as necessary. &nbsp
 The current version is '20020513'.

<p align="justify"> 
 All code which has been fitted for 
 <font face="Courier New">REXXSKEL</font> 
 exhibits a certain 
 behavior: 
<ol type="a">
<li> if the first argument passed to the routine is a 
 question mark ("?"), any available HELP-text is displayed and the 
 routine ends; 
<li> arguments passed to these routines are logically 
 divided by the presence of a double open parenthesis ("<b>((</b>") into 
 "parms" before the "<b>((</b>" and "opts" after. &nbsp
 These may be thought of, 
 respectively, as "what shall we do" and "how shall we do it". 
</ol>

<p>
<center>
<hr width="35%">
</center>
<p>  
<h4>
 KEYWD and SWITCH
</h4>

<p align="justify">  
 Key to the operation of 
 <font face="Courier New">REXXSKEL</font> 
 and independently usable by the               
 application code itself are two internal subroutines: 
 <font face="Courier New">KEYWD</font> and                
 <font face="Courier New">SWITCH</font>. &nbsp
 Both of these subroutines examine the contents of variable            
 "info" which must be populated prior to calling either of them.                

<p align="justify"> 
 <font face="Courier New"> <b>KEYWD</b> </font> 
 examines "info" for the presence of the token which has been             
 passed as its sole argument. &nbsp
 (The 'token' may actually be more than one word, 
 but spacing between words then becomes significant.) &nbsp
 If that token exists in "info", the              
 token which follows it immediately (in the string of "info") is                
 returned as the function value, and both tokens are removed from               
 "info" to prevent duplicate processing.                                        

<p align="justify"> 
 <font face="Courier New"> <b>SWITCH</b> </font> 
 examines "info" for the presence of the token which has been            
 passed as its sole argument. &nbsp
 If that token exists in "info", a '1'            
 bit is returned as the function value and the token is removed from            
 "info" to prevent duplicate processing; if the token does not exist,           
 a '0' bit is returned.                                                         

<p align="justify"> 
 <font face="Courier New"> <b>TOOLKIT_INIT</b> </font> 
 establishes "info" by loading "opts", so that 
 <font face="Courier New">TV</font>,                 
 <font face="Courier New">TRAPOUT</font>, 
 <font face="Courier New">BRANCH</font>,  
 <font face="Courier New">MONITOR</font>, and 
 <font face="Courier New">NOUPDT</font> 
 (the items parsed-out in 
 <font face="Courier New">TOOLKIT_INIT</font>)
 are all derived by default           
 from "opts", the portion of the argument following the "((".&nbsp
 Before           
 it returns control to the mainline, 
 <font face="Courier New">TOOLKIT_INIT</font> calls 
 <font face="Courier New">LOCAL_PREINIT</font>,
 a stub routine which may be used by the application programmer to              
 process any locally-defined opts-values. &nbsp
 (<font face="Courier New">LOCAL_PREINIT</font> 
 is placed             
 before <font face="Courier New">HELP</font> in the standard 
 <font face="Courier New">REXXSKEL</font> 
 to indicate that it is not                
 intended to be replaced when upgrading to a more recent version.) 

<p align="justify"> 
 On return from 
 <font face="Courier New">TOOLKIT_INIT</font> 
 (into the mainline), 
 "info" is refreshed from 
 "parms", so that all other switches and keyword values will be                 
 determined from that portion of the argument preceeding the "((".              

<p>
<center>
<hr width="35%">
</center>
<p>

<h4>
 KEYPHRS
</h4>

<p align="justify">
 This variant of 
 <font face="Courier New">KEYWD</font> 
 exists for passing multiple values. &nbsp
 Naturally,          
 the syntax of <font face="Courier New">KEYPHRS</font> 
 is a little different than 
 <font face="Courier New">KEYWD</font>:  
 <font face="Courier New">KEYPHRS</font>               
 expects to find a 2-character marker immediately following the 
 <font face="Courier New">KEYPHRS</font> 
 argument in "info"; it also expects to find this same marker 
 further along in info. &nbsp
 The text <u>between the markers</u> is returned as 
 the function.&nbsp
 The marker can be any two characters except, obviously, '40'x.  

<p align="justify">
 A parameter might include the string
<br>
<center>
 <font face="Courier New"> TEXT :{ this is text to be parsed :{
 </font> 
</center>
 which would be parsed out by 
<center>
 <font face="Courier New"> text_phrase = KEYPHRS("TEXT")
 </font> 
</center>
<br>

<p>
<center>
<hr width="35%">
</center>
<p>

<h4>
 CLKWD
</h4>

<p align="justify">
 Just recently I have had to add <u>another</u> variant of 
 <font face="Courier New">KEYWD</font> 
 to handle parameters passed as for CLISTs. &nbsp


<p align="justify">
 A parameter might include the string
<br>
<center>
 <font face="Courier New"> TEXT(this is text to be parsed)
 </font> 
</center>
 which would be parsed out by 
<center>
 <font face="Courier New"> text_phrase = CLKWD("TEXT")
 </font> 
</center>
<br>

<p>
<center>
<hr width="35%">
</center>
<p>

<h4>
 HELP
</h4> 

<p align="justify"> 
 A pro-forma <font face="Courier New">HELP</font> 
 paragraph is provided as a guide. &nbsp
 Most of it is              
 commented out; the only section which is active in the unaltered 
 <font face="Courier New">REXXSKEL</font> 
 writes "helpmsg" if it is not blank. &nbsp
 Pro-forma blocks are provided for functional description, syntax, and
 parameters,
 and the nature and uses of the standard diagnostic parameters is
 also covered.
  
<p>
<center>
<hr width="35%">
</center>
<p>

<h4> 
 SYNTAX  
</h4>

<p align="justify"> 
    
 Debugging tools can be accessed in the following manner: 
<pre> 
 TSO exec_name  parameters  ((  debug-options 
  
                                BRANCH
                                MONITOR
                                NOUPDT
                                TRACE tv
                                TRAPOUT
                                'exec specific'
</pre>
   
<p>
<center>
<hr width="35%">
</center>
<p>      
   
<h4>
 OPERANDS 
</h4>

<table>

<tr>
<td width="25%" valign="top" align="right">
<font face="Courier New">BRANCH</font> 
</td>
<td width="3%"></td><td>
 an indicator that causes the name of any internal
            subroutine to be printed as control is transferred 
            to it; 
</td> 
</tr>
     
     
<tr>
<td width="25%" valign="top" align="right"> 
<font face="Courier New">MONITOR</font> 
</td>
<td width="3%"></td><td>
 an indicator which may be used by the application 
            code to control the display of diagnostic messages 
            and progress notes during execution;      
</td> 
</tr>
     
<tr>
<td width="25%" valign="top" align="right"> 
<font face="Courier New">NOUPDT</font>
</td>
<td width="3%"></td><td>
an indicator which may be used by the application 
            code to suppress WRITE operations to its outputs;    
</td> 
</tr>
     
<tr>
<td width="25%" valign="top" align="right"> 
<font face="Courier New">TRAPOUT</font> 
</td>
<td width="3%"></td><td>
 an indicator that routine 
    <font face="Courier New">TRAPOUT</font> 
    is to be started  
    as a shell around this routine; 
    <font face="Courier New">TRAPOUT</font> will 
            produce a dataset under the caller's ID containing 
            "TRACE R" output;      
</td> 
</tr>
     
<tr>
<td width="25%" valign="top" align="right">
<font face="Courier New">tv</font>  
</td>
<td width="3%"></td><td>
 a value used by the application code to set up  
            tracing; specifying (e.g.)  "TRACE ?R" will cause  
            the called routine to begin tracing in  
            'interactive-results' mode immediately after its 
            return from 
            <font face="Courier New">TOOLKIT_INIT</font> 
</td> 
</tr>
     
<tr>
<td width="25%" valign="top" align="right">
exec-specific 
</td>
<td width="3%"></td><td>
 Programmer-provided facilities designed to be 
                  customized debugging features. 
</td> 
</tr>

</table>

<p>
<center>
<hr width="35%">
</center>
<p>
<h4>
Philosophy
</h4>

<p align="justify">
 <font face="Courier New">REXXSKEL</font> 
 developed over a long period starting, as you might expect, 
 as a very simple, straight-forward cluster of diagnostic and parsing
 subroutines. &nbsp
 Various people have contributed various improvements as it evolved
 and I am indebted to them for their innovations. &nbsp
 But always the thrust has been to provide a compact package of 
 easily understood and broadly-useful routines
 that will enable the application programmer to quickly generate
 and easily debug
 routines of any arbitrary complexity. &nbsp
 Naturally, this requires a certain discipline.

<p align="justify">
 While REXX itself allows the programmer 
 to "get away with" many shortcuts,
 a complex or elaborate program will quickly grow fragile if such
 shortcuts are tolerated. &nbsp
 <font face="Courier New">REXXSKEL</font>, 
 therefore, begins with a "signal on novalue"; that is: 
 uninitialized variables are not permitted. &nbsp
 Real programmers don't rely on defaults. &nbsp
 It also issues a "signal on syntax" to trap the odd development
 error. &nbsp
 Both 
 <font face="Courier New">NOSYNTAX</font> and 
 <font face="Courier New">NOVALUE</font> invoke 
 <font face="Courier New">SHOW_SOURCE</font> 
 to display the failing 
 line. &nbsp
 <font face="Courier New">SHOW_SOURCE</font> 
 calls 
 <font face="Courier New">DUMP_QUEUE</font> 
 to clear any outstanding stacks. &nbsp
 These filigrees are not absolutely necessary, but their inclusion
 as part of 
 <font face="Courier New">REXXSKEL</font> 
 means the programmer doesn't have to write them
 and, more importantly, 
 doesn't have to worry about leaving them out. &nbsp

<p align="justify">
 It is better to have and not need than to need and not have.&nbsp
 That, in a nutshell, is the basic philosophy of 
 <font face="Courier New">REXXSKEL</font>.



</body>
</html> 
