/* ACQ     REXX working-section for ACQUIRE command
           Input parameters are:
           (required:)    DDNAME
                          MEMBER
           (optional:)    AS newmember
                          REPLACE
                          INTO alternatedsn
  -------------------------------------------------------------------
   Process: derive dsnames in ddname
            verify that  dsname1(member) does NOT exist
               if it does, certify that user wishes to replace
            find (for 2 to n) first occurrence of dsname(member)
            setup IEBCOPY allocations to copy from n to 1
            invoke IEBCOPY
 
                    Written by Frank Clarke, HAS, Inc.
*/
address TSO
signal on syntax
tv = ""
arg parms "((" opts
opts = Strip(opts,T,")")               /* clip trailing paren        */
 
parse var opts "TRACE" tv .
parse value tv "N"  with  tv  .
rc = Trace(tv)
 
newmbr   = KEYWD("AS")
alt_dsn  = KEYWD("INTO")
repl     = SWITCH("REPLACE")
 
if parms = "" then call HELP
if Word(parms,1) = "?" then call HELP
 
errmsg = ""
arg ddname member .                    /* get input parms            */
if member = "" then call HELP
 
"LA"    ddname "((STACK"               /* get dsnames                */
pull dsnames
if alt_dsn <> "" then do
   if Substr(alt_dsn,1,1) <> "'" then,
      alt_dsn = Userid()"."alt_dsn
   else alt_dsn = Strip(alt_dsn,b,"'")
   dsnames = alt_dsn dsnames
   end
 
dsn.=""                                /* setup array                */
dsn.0 = Words(dsnames)                 /* how many DSNames ?         */
 
exists = ""
do i = 1 to dsn.0                      /* for each                   */
   dsn.i = Word(dsnames,i)             /* load stem                  */
   target = "'"dsn.i"("member")'"      /* compose name for Sysdsn    */
   if sysdsn(target)="OK" then,        /* member exists in dsn ?     */
      exists = exists i                /* add index to list          */
end                                    /* i                          */
 
if exists = "" then do
   say "No source:" member "does not exist in" ddname
   exit(4)
   end
if Word(exists,1) = "1" then do        /* in target position         */
   if Words(exists) < 2 then do        /* no source                  */
      say "No source:" member "does not exist in a source position."
      exit(4)
      end
   source = Word(exists,2)             /* set source                 */
   if repl then nop
   else do
      say member "exists in a target position and REPLACE was not",
          "specified."                 /* warn the user              */
      say "Do you wish to over-write the copy in" dsn.1
      say "                   with the copy from" dsn.source "?"
      "NEWSTACK"
      pull response                    /* get answer                 */
      "DELSTACK"
      if Left(Strip(response),1) = "Y" then nop
      else exit 8                      /* user said 'no'             */
      end
   end
else,
   source = Word(exists,1)             /* first available            */
 
address TSO
"ALLOC FI(SYSUT2) DA('"dsn.1"')   SHR REU"
"ALLOC FI(SYSUT1) DA('"dsn.source"')    SHR REU"
"ALLOC FI(SYSIN) NEW TRACKS SPACE(1) UNIT(SYSDA)",
        "LRECL(80) BLKSIZE(800) RECFM(F B) REU"
"ALLOC FI(SYSPRINT) DUMMY REUSE"
"NEWSTACK"
queue "   COPY INDD=SYSUT1,OUTDD=SYSUT2"
queue "   SELECT MEMBER=(("member","newmbr",R))"
"EXECIO" queued() "DISKW SYSIN (FINIS"
"DELSTACK"
mstat = Msg("off")
"CALL *(IEBCOPY)"
"FREE  FI(SYSUT1 SYSUT2)"
rc = Msg(mstat)
 
exit
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO "CLEAR"
say "                                                                 "
say "  ACQ              (acquires) brings a member of a partitioned   "
say "        dataset forward to the first dataset of the              "
say "        concatenation.  It does this by invoking IEBCOPY, thus   "
say "        saving the original member's statistics.                 "
say "                                                                 "
say "        Syntax:                                                  "
say "          ACQ       <ddname> <member> <options>                  "
say "                                                                 "
say "            options are:                                         "
say "                                                                 "
say "               AS(new-membername)      causes the target member  "
say "                   to be renamed as it is IEBCOPY'd.             "
say "                                                                 "
say "               INTO(altern-dsname)     specifies a dataset other "
say "                   than the first in the concatenation.          "
say "                                                                 "
say "               REPLACE                   allows replacement of an"
say "                   existing member in the first dataset by a     "
say "                   member below it in the concatenation.  If     "
say "                   REPLACE is not specified and <member> is      "
say "                   discovered in a target position, you will be  "
say "                   prompted for permission to over-write it.     "
say "                                                                 "
exit                                   /*@ HELP                      */
/*
.  ----------------------------------------------------------------- */
KEYWD: Procedure expose,               /*@                           */
       kw parms
arg kw .
if Wordpos(kw,parms) = 0 then,
   kw_val = ""
else,
if Wordpos(kw,parms) = 1 then,
   kwa = kw" "
else kwa = " "kw" "
parse var parms . value(kwa)  kw_val .
if kw_val <> "" then parms = Delword(parms,Wordpos(value(kw),parms),2)
return kw_val                          /*@ KEYWD                     */
/*
.  ----------------------------------------------------------------- */
SWITCH:                                /*@                           */
arg kw .
sw_val  = Wordpos(value(kw),parms) > 0
if sw_val  then parms = Delword(parms,Wordpos(value(kw),parms),1)
return sw_val                          /*@ SWITCH                    */
/*
.  ----------------------------------------------------------------- */
SYNTAX:                                /*@                           */
   errormsg = "REXX error" rc "in line" sigl":" errortext(rc)
   say errormsg
   say sourceline(sigl)
   trace "?r"
   nop
exit                                   /*@ SYNTAX                    */
