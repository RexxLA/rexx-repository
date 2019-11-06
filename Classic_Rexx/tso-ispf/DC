/*  REXX          DC - Dot command (David A. Visage)
 
          Revised 970417 by Frank Clarke
                  010727 fxc activate .LST and .LSTL
                  020705 fxc LINE/REFRESH for .USER
*/
 
address ISREDIT
"MACRO (MacParm)"
if rc > 0 then do; say zerrsm; say zerrlm; exit; end
tv = ""
parse upper var MacParm UsrParm . "((" "TRACE" tv . ")"
if tv ^= ""  then rc = trace(tv)
 
address ISPEXEC "CONTROL ERRORS RETURN"
 
if UsrParm = "?"  then do
   call HELPME                         /*                           -*/
   exit
   end
 
"LOCATE LABEL FIRST"                   /*  Find the first label      */
/*"CAPS OFF" */
RetCode = rc
 
valid_lbls1 = ".BR .COPY .DCB .DEL .DIR .ED .EDL .IMP .LC .LST .LSTL"
valid_lbls2 = ".SPC .TYPE .USER .VW"
do forever
   "(topline) = DISPLAY_LINES"         /* which line was LOCATEd ?   */
   "(labname) = LABEL" topline         /* which LABEL did it have ?  */
   "CURSOR =" topline                  /* position the cursor        */
   "(Buffer)  = LINE .ZCSR"
   "(LineNum) = LINENUM .ZCSR"
   call PERFORM LabName                /*                           -*/
   if Msg.0 > 0 then
      do i = Msg.0 to 1 by -1
         "LINE_AFTER .ZCSR = MSGLINE '"Msg.i"'"
      end                              /* msg.                       */
   "LABEL" LabName "= '' 0"
   "LOCATE LABEL NEXT"
   if rc > 0 then leave
end                                    /* forever                    */
 
exit                                   /*@ DC                        */
/*
.  ----------------------------------------------------------------- */
PERFORM:                               /*@                           */
   arg Label .
   address ISPEXEC
   Msg.0 = 0                        /*  ReINITialize                 */
 
   call GETDSN                    /*  Extract dataset name from JCL -*/
 
   if Msg.0 > 0    then return
 
   "CONTROL DISPLAY SAVE"
   select
      when Label = ".BR"   then call BROWSE                       /* -*/
      when Label = ".VW"   then call BROWSE("V")                  /* -*/
      when Label = ".COPY" then call COPY                         /* -*/
      when Label = ".DCB"  then do
         call MESSG Center("RECFM" ,6),
                    Center("LRECL" ,6),
                    Center("BLKSIZE" ,8),
                    Center("DSORG ",6),
                    Center("VOLUME ",6)
         call MESSG Center(sysrecfm,6),
                    Center(syslrecl,6),
                    Center(sysblksize,8),
                    Center(sysdsorg,6),
                    Center(sysvolume,6)
         end
      when Label = ".DEL"  then call TSOCMD "DELETE" QualDS       /* -*/
      when Label = ".DIR"  then call DIR                          /* -*/
      when Label = ".ED"   then call EDIT QualDs  /* with membername -*/
      when Label = ".EDL"  then call EDIT "'"DataSet"'" /* full dset -*/
      when Label = ".IMP"  then call IMPORT                       /* -*/
      when Label = ".LC"   then call TSOCMD "LISTC ENT("QualDS") VOL"
      when Label = ".LST"  then call PRINTDS                      /* -*/
      when Label = ".LSTL" then call PRINTDS  "LAND"              /* -*/
      when Label = ".SPC"  then call SPACE                        /* -*/
      when Label = ".TYPE" then call TYPE                         /* -*/
      when Label = ".USER" then do
         "CONTROL DISPLAY LINE"
         address TSO UsrParm QualDS
         "CONTROL DISPLAY REFRESH"
         end                           /* .USER                      */
      when Label = ".BRF"  then nop
      when Label = ".EDF"  then nop
      otherwise do
         call MESSG "Invalid or unknown command: '"label"'"
         call MESSG "Valid options:" valid_lbls1
         call MESSG "              " valid_lbls2
         end
   end                                 /* select label               */
   "CONTROL DISPLAY RESTORE"
 
return                                 /*@ PERFORM                   */
/*
   Extract dataset and possible member/GDG.  The following global
   variables are set :
 
   (A) DSN     - Unchanged dataset name from JCL
 
   (B) QualDS  - For GDG, quoted DSN with G0000V00 number
                 For other datasets, same as DSN with quotes
 
   (C) MbrGDG  - Blank     : Not a PDS or GDG
       MbrGDG  - Numeric   : G0000V00 number
       MbrGDG  - Alpabetic : Member name
 
   (D) DataSet - For GDG, qualified name with G0000V00
       DataSet - For PDS with member name, PDS name (no member)
       DataSet - For other datasets, same as DSN
 
   (E) DD - DDNAME of the dataset - includes 'DD' keyword
.  ----------------------------------------------------------------- */
GETDSN:                                /*@                           */
 
   parse var Buffer "DSN=" DSN "," 1  "DSNAME=" DSNA "," .
   parse value dsn dsna  with dsn  .
   if DSN = ""  then do
      call MESSG "GETDSN: Could not find DSN= or DSNAME= on input line"
      return
      end
 
   QualDS = "'"DSN"'"
 
   parse var DSN DataSet "(" MbrGDG ")" .
 
   if DATATYPE(MbrGDG,"N")  then do    /*  G0000V00 number?          */
      call GETGDG MbrGDG               /*                           -*/
      if Msg.0 > 0    then return
      end
 
   if label = ".EDL" then              /*                            */
      Msg = SYSDSN("'"Dataset"'")           /*  Does dataset exist?  */
   else,                               /*                            */
      Msg = SYSDSN(QualDS)                  /*  Does dataset exist?  */
 
   if Msg ^= "OK"  then do
      call MESSG "GETDSN: ("Qualds")" Msg
      return
      end
 
   X = LISTDSI(QualDS "DIRECTORY")     /*  Get DCB attributes        */
 
return                                 /*@ GETDSN                    */
/*
   Extract G0000V00 information
.  ----------------------------------------------------------------- */
GETGDG:                                /*@                           */
   arg Num
 
   if SIGN(Num) > 0  then do
      call MESSG "GETGDG: Generation number must be zero or negative"
      return
      end
 
   x = OUTTRAP("Sysout.")
   address TSO "LISTCAT LEVEL ("DataSet")"
   x = OUTTRAP("OFF")
 
   if rc ^= 0  then do
      call MESSG "GETGDG: Base not defined for generation dataset"
      return
      end
 
   Count = 0
   FoundGDG = "0"
 
   do i = Sysout.0 to 1 by -1
      if WORD(Sysout.i,1) = "NONVSAM"  then do
         if Count = Num  then do
            Dataset = STRIP(WORD(Sysout.i,3))
            QualDS = "'"DataSet"'"
            FoundGDG = "1"
            leave i
            end
         Count = Count - 1
         end                           /* NONVSAM                    */
   end                                 /* i                          */
 
   if FoundGDG  then do
      call MESSG "GETGDG: Generation number of GDG was not found"
      return
      end
 
return                                 /*@ GETGDG                    */
/*
.  ----------------------------------------------------------------- */
PRINTDS:                               /*@                           */
   address TSO
   arg options
 
   "%PRINTME {"dsn    "{ { { {"options
 
return                                 /*@ PRINTDS                   */
/*
   show DASD utilization
.  ----------------------------------------------------------------- */
SPACE:                                 /*@                           */
   call MESSG Center("Units"   ,8),
              Center("Alloc"   ,7),
              Center("Used"    ,7),
              Center("1-ry"    ,5),
              Center("2-ry"    ,7),
              Center("Ext"     ,5),
              Center("Dir-Alc" ,7),
              Center("Dir-Usd" ,7)
   call MESSG Center(SYSUNITS  ,8),
              Center(SYSALLOC  ,7),
              Center(SYSUSED   ,7),
              Center(SYSPRIMARY,5),
              Center(SYSSECONDS,7),
              Center(SYSEXTENTS,5),
              Center(SYSADIRBLK,7),
              Center(SYSUDIRBLK,7)
return                                 /*@ SPACE                     */
/*
   IMPORT dataset into EDIT dataset
.  ----------------------------------------------------------------- */
IMPORT:                                /*@                           */
   address TSO
 
   "NEWSTACK"
   "ALLOC DDNAME(IFILE) DSNAME("QualDS") SHR REU"
   "EXECIO * DISKR IFILE (FINIS"
   "FREE DDNAME(IFILE)"
 
   address ISREDIT
 
   "(LineNum) = LINENUM .ZCSR"
   OldLine = INSERT("*",Buffer,2)      /*  Change DD to comment      */
   "LINE" LineNum "= '"OldLine"'"
 
   NewLine = "// DD *"                 /*  Create instream DD        */
   "LINE_AFTER" LineNum "= '"NewLine"'"
 
   do QUEUED()
     pull Line
      LineNum = LineNum + 1
     "LINE_AFTER"  LineNum "= '"Line"'"
   end                                 /* queued()                   */
   address TSO "DELSTACK"
 
return                                 /*@ IMPORT                    */
/*
   Display dataset contents
.  ----------------------------------------------------------------- */
TYPE:                                  /*@                           */
 
   select
      when SYSDSORG = "PO" then do
         if MbrGdg = ""  then do
            call MESSG "TYPE: Invalid dataset organization"
            return
            end
         end
      when SYSDSORG = "PS" then do
         nop
         end
      otherwise do
         call MESSG "TYPE: Invalid dataset organization"
         return
         end
   end                                 /* select                     */
 
   address TSO "LIST"  QualDS
 
return                                 /*@ TYPE                      */
/*
.  ----------------------------------------------------------------- */
COPY:                                  /*@                           */
   parse var DataSet HLQ "." NonQual   /*  Get HLQ and remainder     */
 
   User = USERID()
 
   if HLQ = User  then do
      call MESSG "COPY: First qualifier same as TSO user ID"
      return
      end
 
   OldDS = QualDS
   NewDS = "'"User"."NonQual"'"
 
   if SYSDSN(NewDS) = "OK"  then do
      address TSO "DELETE " NewDS
      end
 
   address TSO
   "ALLOC FI(F1) DA("NewDS") LIKE("OldDS") NEW CATALOG"
   "FREE FILE(F1)"
   "SMCOPY FDS("OldDS") TDS("NewDS")"
   address ISREDIT
 
   "C " OldDS    NewDS  " ALL"
 
return                                 /*@ COPY                      */
/*
   List members of a PDS
.  ----------------------------------------------------------------- */
DIR:                                   /*@                           */
 
   if SYSDSORG ^= "PO"  then do
      call MESSG "DIR: Dataset must be PDS for this function"
      return
      end
 
   if MbrGDG ^= ""  then do
      call MESSG "DIR: A member name must not be specified"
      return
      end
 
   call TSOCMD "LISTDS " QualDS " MEMBERS"
 
return                                 /*@ DIR                       */
/*
   PERFORM .BR operation
.  ----------------------------------------------------------------- */
BROWSE:                                /*@                           */
   arg browse_or_view .
   if Left(browse_or_view,1) = "V" then func = "VIEW"
                                   else func = "BROWSE"
 
   address ISPEXEC func "DATASET("QualDS")"
 
   if rc > 4  then
      call MESSG func":" ZERRLM
 
return                                 /*@ BROWSE                    */
/*
   PERFORM .ED and .EDL operations
.  ----------------------------------------------------------------- */
EDIT:                                  /*@                           */
   arg ed_dsn  .
 
   address ISPEXEC "EDIT DATASET ("ed_dsn")"
 
   if rc > 4  then,
      call MESSG "EDIT:" ZERRLM
 
return                                 /*@ EDIT                      */
/*
   Execute TSO commands
.  ----------------------------------------------------------------- */
TSOCMD:                                /*@                           */
   arg CmdStr
 
   x = OUTTRAP("Msg.")
   address TSO CmdStr
   x = OUTTRAP("OFF")
 
   if rc = 0  then do                  /*  Display results if rc = 0  */
      do i = 1 to Msg.0
         say Strip(Msg.i)
      end
      Msg.0 = 0                        /*  Indicate good return code  */
      end
 
return                                 /*@ TSOCMD                    */
/*
.  ----------------------------------------------------------------- */
MESSG:                                 /*@                           */
   parse arg ErrStr
 
   parse value Msg.0+1 errstr    with,
               errct     Msg.errct     1  Msg.0    .
 
return                                 /*@ MESSG                     */
/*
.  ----------------------------------------------------------------- */
HELPME:                                /*@                           */
 
   say "Available commands :"
   say " "
   say ".BR     -  BROWSE dataset"
/* say ".BRF    -  File Aid BROWSE" */
   say ".COPY   -  Duplicate dataset"
   say ".DCB    -  List DCB information"
   say ".DEL    -  Delete dataset"
   say ".DIR    -  PDS DIRectory"
   say ".ED     -  EDIT dataset(member)"
/* say ".EDF    -  File Aid EDIT" */
   say ".EDL    -  EDIT dataset"
   say ".IMP    -  IMPORT dataset contents"
   say ".LC     -  List catalog information"
   say ".LST    -  Print dataset"
   say ".LSTL   -  Print dataset Landscape"
   say ".SPC    -  Display DASD utilization"
   say ".TYPE   -  List sequential dataset"
   say ".USER   -  Run user EXEC (CLIST or REXX)"
   say ".VW     -  VIEW dataset"
 
return                                 /*@ HELPME                    */
