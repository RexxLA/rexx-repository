<html>
<font face="Verdana, Arial, Helvetica" size="3">
<head>
<title>
FXCTOOLS - Intro
</title>
</head>

<body>
<h4>
Requirements for using FXCTools:
</h4>
<ol>
<li>Your own SYSEXEC dataset concatenated FIRST.
<li>Your own ISPTLIB dataset concatenated FIRST.          
<li>A method of customizing your environment.
</ol>

<hr>
<p><p>
<ol>
<li>Your own SYSEXEC dataset concatenated FIRST.
<p align="justify">
To get your own SYSEXEC dataset (if you don't already have one)
follow these steps:
<ol>
<li>go to the ISPF Primary Option Menu and find the fields 
"<font face="Courier New">TSO Logon</font>"
and 
"<font face="Courier New">TSO Prefix</font>"       

<li>if your TSO Logon is also a member in 
<font face="Courier New">NTIN.TS.D822.LIB.EXEC</font> you
may continue; otherwise STOP -- you're not supported.

<li>execute that member from 
<font face="Courier New">NTIN.TS.D822.LIB.EXEC</font> with your TSO
Prefix as the parameter.

<li>RECEIVE the file that was sent to you.&nbsp  
Do not redirect the file -- it knows where to go.

<li>LOGON to get a clean environment.
</ol>
<p align="justify">
If you started out already having a SYSEXEC dataset, just do
steps (3) and (4).
<p align="justify">
You now have a user-owned dataset at the head of the SYSEXEC
concatenation and it contains member INSTALL.&nbsp  
You can use this to install drivers for many FXCTools; 
this is the preferred method for obtaining such tools; 
having your own copy of any tool means not getting any upgrades or fixes.           
<p align="justify">
[TSO] INSTALL [toolname] will place a driver into your SYSEXEC
dataset.&nbsp  
You should immediately install ATTACH, ADDCMDS, DUP,
FIRSTIME, JOBCARDS, MEMBERS, PDSCOPYD, and SQUASH.&nbsp  
You can do this with one command: [TSO] INSTALL SIGNUP
<p align="justify">
<li>
<p align="justify">
Your own ISPTLIB dataset concatenated FIRST.&nbsp  
(This is not strictly a "requirement" 
but some tools will not work properly unless  
invoked via a command table.)       
<p>
To get your own command table, follow these steps:
<ol>
<li>using whatever method is most comfortable for you, build a dataset
like DTAFXC.@@.ISPTLIB.&nbsp  
If you have installed DUP, you may use
that to allocate your own dataset.        
<li>copy member TMPCMDS from DTAFXC to your new ISPTLIB.&nbsp  
Many of the commands in TMPCMDS will not operate 
because the software has not been installed, 
but all of the software is installable.     
</ol>
<p>
<li>A method of customizing your environment.
<p align="justify">
You must customize your environment to get your table library where
it can be used.&nbsp  
You may also wish to connect additional libraries
or to disconnect others which you are unlikely to use.
<p align="justify">
For obvious reasons, I recommend ATTACH.&nbsp  
ATTACH requires you to have a dataset called 
<font face="Courier New">[uid].ISPF.PROFILE</font> 
and a member START in that
dataset.&nbsp  
START contains the customizing instructions which ATTACH
will use to shape your environment to your needs.       
<p align="justify">
NMR's supported logon routines can be used to invoke this code at
each LOGON.&nbsp  
If the dataset created for you in (1.4) has a 
<font face="Courier New">LOGON</font>
member, it will be executed at LOGON time.  
If that 
<font face="Courier New">LOGON</font> 
member calls 
<font face="Courier New">ATTACH</font>, 
your environment will be customized as specified in
<font face="Courier New">ISPF.PROFILE(START)</font>.
<p align="justify">
At a minimum, START should direct your table library to be
allocated (a) at the head of ISPTLIB:
<p>
<pre>
        ATTACH    ISPTLIB    [uid].@@.ISPTLIB    AHEAD
</pre>
<p>
     and (b) as the ONLY dataset in ISPTABL:
<pre>
        ATTACH    ISPTABL    [uid].@@.ISPTLIB    UNIQUE
</pre>
<p align="justify">
Once your table library is connected to your environment 
it can be made "active".&nbsp  
ADDCMDS performs this function by inserting the
contents of ISPTLIB(TMPCMDS) 
into the in-storage copy of ISPCMDS.&nbsp
This is a temporary change; 
leaving ISPF or suffering a dialog   
error will cause your table settings to 
revert to base and you will
have to run ADDCMDS again to reload them.&nbsp  
For this reason it is a
good idea to assign a PFKey with the string "TSO ADDCMDS" 
so that
the command table can be reloaded with a single keystroke.      

</body>
</html>