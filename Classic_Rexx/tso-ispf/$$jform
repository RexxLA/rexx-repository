/* REXX    $$JForm    Shape JCL into the following canonical form:
 
  //JOBNAME. JOB ..ACCTGINFO.STARTS.IN.16..,
  //             ..CONTINUED.JOBCARD.STARTS.IN.16..
  //*------1-----:------------                                       */
  //STEPNAM  EXEC PGM=..STEP.INFO.STARTS.IN.16
  //DDNAME    DD  DSN=...,
  //             .....CONT.IN.16...
  //*------1-----:------------                                       */
 
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
   |                                                                 |
   |          WARNING: EMBEDDED COMPONENTS.                          |
   |                      See text following TOOLKIT_INIT            |
   |                                                                 |
   |**-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-**|
 
     Impact Analysis
.    SYSEXEC   STRSORT
 
     Modification History
     20030218 fxc avoid shifting characters to uppercase during
                  processing.
     20030227 fxc run with CAPS ON and restore when finished;
     20030407 fxc run with CAPS OFF and restore when finished;
     20030625 fxc correct handling of long comments;
     20030819 fxc minor corrections;
     20041124 fxc enable PCOMM and ICOMM;
     20061015 fxc alignment parameters in the profile;
     20061115 fxc post-verb text cannot start after 16;
     20061127 fxc monitor;
     20061129 fxc update HELP-text;
     20061215 fxc correct processing for IF;
     20070202 fxc novalues on PT, PT., and PLC. ;
     20071116 fxc novalue on NOTETEXT;
     20080124 fxc rc(1) at exit;
     20080710 fxc allow text to col.36
     20081013 fxc when new job, wipe stepnamelist;
     20081218 fxc major redesign to accomodate multiple profiles;
                  establish profile var @jfprofs to name the list of
                  profiles (5-char names); establish "DEFLT" as first
                  entry; establish @jfdeflt containing standard
                  settings; allow users to "set prol" and provide
                  alternative settings to be stored as "@jfprol";
     20160422 fxc correct I/A w STRSORT
     20160929 fxc VIO or SYSDA
     20161018 fxc added call to FIND_ORIG
 
*/
address ISREDIT                        /* REXXSKEL ver.20020513      */
"MACRO (argline)"
upper argline
parse var argline  parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
info = parms
rc = Trace("O"); rc = Trace(tv)
 
call A_INIT                            /*                           -*/
     address TSO "NEWSTACK"
     if \sw.0ErrorFound then,
        call B_SCAN_JCL                /*                           -*/
     address TSO "DELSTACK"
 
if sw.0SaveLog then,
   call ZB_SAVELOG                     /*                           -*/
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit(1)                                /*@ $$JForm                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   parse value "16   16   16     0 0 0 0 0 0 0" with,
                pt   pt.  plc.   ,
                ct.   ,
               .
   parse value ""  with  ,
               steplist  dupsteplist.  ,
               jobnlist working  lastverb ,
               .
 
   call AA_SETUP_LOG                   /*                           -*/
   parse value   "DD     ELSE ENDIF  EXEC IF   INCLUDE",
                 "JCLLIB JOB  OUTPUT PEND PROC SET"      with,
                 $jfvalvb
   call AD_SET_DEFAULTS                /*                           -*/
   if sw.0ErrorFound then return
   call AK_KEYWDS                      /*                           -*/
 
   "(lastline) = LINENUM .zlast"
   "(origcaps) = CAPS"
   "CAPS OFF"
 
   "F FIRST P'^' 73 80"                /* numbered ?                 */
   if rc = 0 then do                   /* Yes                        */
      "RENUM"
      "UNNUM"
      "AUTOSAVE PROMPT"
      call ZL_LOGMSG("JCL was renumbered")
      end
   "F FIRST P'^'"
   "LABEL .zcsr = .JS 0"               /* mark JCL-start             */
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_SETUP_LOG:                          /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value "0" with,
               log#    log.
   parse value Date("S")  Time("S")  Time("N")  with,
               yyyymmdd   sssss      hhmmss  .
   parse var yyyymmdd  4 yrdigit 5 mm 7 dd          /* 9 12 14 maybe */
   if Pos(yrdigit,"13579") > 0 then mm = mm + 12       /* mm=24      */
   logtag = Substr("ABCDEFGHIJKLMNOPQRSTUVWX",mm,1)    /* logtag=X   */
   subid  = logtag""dd""Right(sssss,5,0)               /* X1423722 ? */
   vb4k.0    = "NEW CATALOG UNIT(SYSDA) SPACE(1 5) TRACKS",
               "RECFM(V B) LRECL(4096) BLKSIZE(0)"
   vb4k.1    = "SHR"                   /* if it already exists...    */
   logdsn = "@@LOG."exec_name"."subid".#CILIST"
 
   orig_ds = FIND_ORIGIN()
   call ZL_LOGMSG(exec_name "started by" Userid()  yyyymmdd  hhmmss)
   call ZL_LOGMSG("Running from" orig_ds )
   call ZL_LOGMSG("Arg:" argline)
 
return                                 /*@ AA_SETUP_LOG              */
/*
   Get alignment values from the user's profile.  If no values, set
   initial values and start the 'SETUP' dialog.
.  ----------------------------------------------------------------- */
AD_SET_DEFAULTS:                       /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   drop ($jfvalvb)              /* drops -values- of the valid verbs */
   ddnlist = ""
 
   "VGET @JFPROFS     PROFILE"         /* get list of sets           */
   if rc > 0 then,
      do                               /* create @JFPROFS & @JFDEFLT */
      call ADA_INIT_PROFS              /*                           -*/
      end
 
   "VGET  @JFDEFLT    PROFILE"
   parse value @JFDEFLT     with,      /* populate the screen        */
           $jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin,
           $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse,
           $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin,
           $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse,
           profnm
   if sw.0Setup then,                  /* Forced reset of PROFILE    */
      do
      call ADI_INIT_VARS               /* Init all the $JF.... vars -*/
      end
 
   call ADL_LOAD_VARS                  /* Load all the $JF.... vars -*/
   "VPUT @JFPROFS     PROFILE"         /* get list of sets           */
 
return                                 /*@ AD_SET_DEFAULTS           */
/*
   New user or first time using this version.
.  ----------------------------------------------------------------- */
ADA_INIT_PROFS:                        /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   sw.0Setup = 1                       /* force ADI_INIT_VARS        */
   @JFPROFS = "DEFLT"
   "VPUT @JFPROFS     PROFILE"
 
   parmlist = "$jfptdd $jfptel $jfpten $jfptex $jfptif $jfptin",
              "$jfptjc $jfptjo $jfptou $jfptpe $jfptpr $jfptse",
              "$jfpldd $jfplel $jfplen $jfplex $jfplif $jfplin",
              "$jfpljc $jfpljo $jfplou $jfplpe $jfplpr $jfplse"
   "VGET ("parmlist") PROFILE"
   if rc > 0 then,
      do                               /* first-time user            */
      parse value   "13 10 10 12 10  6    9 12  8 10 10  6",
                    "16 16 16 16 16 16   16 16 16 16 16 12" with,
                    $jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin,
                    $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse,
                    $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin,
                    $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse .
      @jfdeflt =    $jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin,
                    $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse,
                    $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin,
                    $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse,
                    "DEFLT"
      end                              /* first-time user            */
   else,                               /* current user               */
      "VERASE ("parmlist") PROFILE"    /* purge old data             */
   "VPUT @JFDEFLT     PROFILE"         /* load DEFLT to PROFILE      */
 
return                                 /*@ ADA_INIT_PROFS            */
/*
.  ----------------------------------------------------------------- */
ADI_INIT_VARS:                         /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if ddnlist = "" then,
      call DEIMBED                     /* extract ISPF assets       -*/
   @dd = ""
   do Words(ddnlist)                   /* each LIBDEF @DD            */
      parse value ddnlist @dd with  @dd ddnlist
      $ddn   = $ddn.@dd                /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"@dd "LIBRARY ID("$ddn") STACK"
   end
   ddnlist = ddnlist @dd
 
   call ADID_DISPLAY                   /*                           -*/
 
   @dd = ""
   do Words(ddnlist)                   /* each LIBDEF @DD            */
      parse value ddnlist @dd with  @dd ddnlist
      $ddn   = $ddn.@dd                /* PLIB322 <- PLIB            */
      "LIBDEF  ISP"@dd
      address TSO "FREE  FI("$ddn")"
   end
   ddnlist = ddnlist @dd
 
return                                 /*@ ADI_INIT_VARS             */
/*
.  ----------------------------------------------------------------- */
ADID_DISPLAY:                          /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   profs = @JFPROFS
   do forever
      "DISPLAY PANEL(PTINIT)"
      if rc > 0 then leave
      if zcmd <> '' then,
         do                            /* process the command        */
         parse var zcmd verb text      /* set prol, maybe            */
         if WordPos( verb,'PUT SET ' ) > 0 then,
            do                         /* store visible as (name)    */
            parse var text   name zcmd
            call ADIDC_CONFIRM_WRITE   /*                            */
            if sw.0Write = 0 then iterate
            profn = "@JF"name
            $rc = Value( profn,,       /* load values to (profn)     */
                    $jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin,
                    $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse,
                    $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin,
                    $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse,
                    name )
            "VPUT" profn "PROFILE"     /* save it                    */
            @jfdeflt =    $jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin,
                          $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse,
                          $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin,
                          $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse,
                          name
            "VPUT @JFDEFLT     PROFILE"         /* load current to DEFLT      */
            if WordPos( name,@JFPROFS ) = 0 then,
               do
               @JFPROFS = @JFPROFS name
               @JFPROFS = STRSORT( @JFPROFS )
               profs    = @JFPROFS
               end
            profnm  =  name
            end
         else,
         if WordPos( verb,'GET LOAD' ) > 0 then,
            do                         /* switch profiles            */
            parse var text   name zcmd
            profn = "@JF"name
            "VGET" profn "PROFILE"
            parse value Value(profn) with,
                    $jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin,
                    $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse,
                    $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin,
                    $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse,
                    .
            profnm  =  name            /* load name to panel         */
            @jfdeflt =    $jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin,
                          $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse,
                          $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin,
                          $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse,
                          name
            "VPUT @JFDEFLT     PROFILE"         /* load current to DEFLT      */
            end
         end
   end                                 /* forever                    */
   sw.0ErrorFound = rc > 0
 
return                                 /*@ ADID_DISPLAY              */
/*
   User is about to overwrite (name).  Set sw.0Write
.  ----------------------------------------------------------------- */
ADIDC_CONFIRM_WRITE:                   /*@                           */
   if branch then call BRANCH
   address ISPEXEC
 
   if WordPos( name,@JFPROFS ) > 0 then,
      do
      "VGET ZPFCTL"; save_zpf = zpfctl /* save current setting       */
         zpfctl = "OFF"; "VPUT ZPFCTL" /* PFSHOW OFF                 */
      "ADDPOP ROW(10) COLUMN(5)"
      "DISPLAY PANEL(OLCONFRM)"
      disp_rc = rc
      "REMPOP ALL"
         zpfctl = save_zpf; "VPUT ZPFCTL" /* restore                 */
      sw.0Write = confirm = "Y"
      end
   else,                               /* OK to write                */
      sw.0Write = 1
 
return                                 /*@ ADIDC_CONFIRM_WRITE       */
/*
   Load PROFILE variables to stems.
.  ----------------------------------------------------------------- */
ADL_LOAD_VARS:                         /*@                           */
   if branch then call BRANCH
   address TSO
 
   parse value  $jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin,
                $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse,
                $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin,
                $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse,
                $jfvalvb        with,
                pt.DD      pt.ELSE  pt.ENDIF   pt.EXEC  pt.IF    pt.INCLUDE,
                pt.JCLLIB  pt.JOB   pt.OUTPUT  pt.PEND  pt.PROC  pt.SET,
                plc.DD     plc.ELSE plc.ENDIF  plc.EXEC plc.IF   plc.INCLUDE,
                plc.JCLLIB plc.JOB  plc.OUTPUT plc.PEND plc.PROC plc.SET,
                valid_verbs
 
return                                 /*@ ADL_LOAD_VARS             */
/*
.  ----------------------------------------------------------------- */
AK_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO
 
   dfltpos    = "RIGHT"
   pcomm      = KEYWD("PCOMM")         /* PROC comments              */
   icomm      = KEYWD("ICOMM")         /* regular comments           */
   commpos    = KEYWD("COMMENTS")      /* RIGHT, TIGHT, or col#      */
   parse value commpos dfltpos with commpos  .
 
   /* Use PCOMM if specified, else COMMPOS if specified, else default*/
   parse value pcomm commpos  with pcomm .
   if Datatype(pcomm,"W") |,
      WordPos(pcomm,"RIGHT TIGHT") > 0 then nop
   else pcomm = "RIGHT"                /* PCOMM specified incorr     */
 
   /* Use ICOMM if specified, else COMMPOS if specified, else default*/
   parse value icomm commpos  with icomm .
   if Datatype(icomm,"W") |,
      WordPos(icomm,"RIGHT TIGHT") > 0 then nop
   else icomm = "RIGHT"                /* ICOMM specified incorr     */
 
   call ZL_LOGMSG("COMMENTS positioning set to" pcomm "for PROC",
                  "comments; set to" icomm "for JCL comments")
 
return                                 /*@ AK_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_SCAN_JCL:                            /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   zerrsm = "Using profile" profnm
   zerrlm = "The contents of the current profile indicated that",
            "profile" profnm "is being used." ,
            "For more information, command '$$JF (( SETUP'."
   address ISPEXEC "SETMSG MSG(ISRZ002)"
   do bx = 1 to lastline
      "(text) = LINE" bx               /* acquire line               */
      if sw.0Diagnose then do
         rc=Trace("O")
         say text
         address TSO "NEWSTACK"; pull trcreq; address TSO "DELSTACK"
         if trcreq <> "" then rc=Trace("?r")
         end                           /* Diagnose                   */
 
      if Left(text,2)  = "//"  &,
         Left(text,3) <> "//*"    then do     /* real JCL            */
 
         if Pos("'",text) > 0 then call B0_PACK          /*         -*/
         parse var text front verb back /* get verb                  */
         line = front
 
         if WordPos(verb,valid_verbs) > 0 then do
            lastverb = verb
            call BA_PLACE_VERB         /*                           -*/
            end                        /* valid verb                 */
         else do                       /* not valid verb             */
            comments = Strip(back)
            back     = verb
            verb     = ""
            end                        /* not valid verb             */
         call BF_FORM_LINE             /*                           -*/
 
         end                           /* real JCL                   */
 
      queue Strip(text,"T")
      call ZL_LOGMSG(text)
 
   end                                 /* bx                         */
 
   do queued()                         /* every stacked line         */
      parse pull line
      "LINE_BEFORE .JS = (line)"
   end                                 /* queued                     */
 
   "RESET"
   "X ALL   .JS  .ZL"                  /* exclude original           */
   "DEL ALL X"                         /* ...and delete              */
   "F FIRST P'^'"                      /* position to top            */
   "CAPS =" origcaps
 
   do Words( jobnlist )
      parse var jobnlist jobn jobnlist
      if dupsteplist.jobn <> "" then do
         notetxt = "Duplicate stepnames in JOB" jobn":" dupsteplist.jobn
         do while Length( notetxt ) > 72
            pt   = LastPos( " ",notetxt,70 )
            parse var notetxt slug =(pt) notetxt
            notetxt = "      " Strip( notetxt )
            push slug
         end
         push notetxt
 
         do queued()
            parse pull slug
            "LINE_AFTER 0 = NOTELINE (slug) "
         end                           /* queued                     */
         end                           /* dupsteplist                */
   end                                 /* jobnlist                   */
 
return                                 /*@ B_SCAN_JCL                */
/*
   'text' contains a quoted string.  To ensure it does not get split
   incorrectly, change all blanks within any such string to hex-3f.
.  ----------------------------------------------------------------- */
B0_PACK:                               /*@                           */
   if branch then call BRANCH
   address TSO
 
   start = 1
   origtext = text                     /* save original              */
   do forever
      qpt = Pos("'",text,start)
      if qpt = 0 then leave
      do forever
         qpt = qpt + 1                 /* next byte                  */
         if qpt > 71 then leave
         if Substr(text,qpt,1) = "'" then leave
         if Substr(text,qpt,1) = " " then do
            text = Overlay('3f'x,text,qpt,1)
            sw.0packed = 1
            end                        /*                            */
      end                              /* forever                    */
 
      if qpt > 71 then do
         text = origtext               /* restore                    */
         sw.0asis = 1                  /* leave it alone             */
         leave
         end
      start = qpt + 1
   end                                 /* forever                    */
 
return                                 /*@ B0_PACK                   */
/*
   Position the verb on LINE and set the location and length of the
   text which may follow.
.  ----------------------------------------------------------------- */
BA_PLACE_VERB:                         /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   if verb = "EXEC" then do
      parse var front "//" step .
      if WordPos( step,steplist ) > 0 then do
         ct.step = ct.step + 1
         if ct.step = 1 then,
            dupsteplist.jobn = step dupsteplist.jobn
         end
      else steplist = steplist step
      end
   else,
   if verb = "JOB" then do
      parse var front "//" jobn .
      jobnlist  = jobnlist jobn
      steplist  = ""
      end
 
   if Length(line) > pt.verb - 2 then,
      line = line verb
   else,
      line = Overlay(verb,line, pt.verb )
 
   pt   = Length(line)+2               /* insertion point            */
   if pt < plc.verb then,
      pt = plc.verb
 
   call ZL_LOGMSG("JCL pushed to" pt)
 
   if verb <> "IF" then,
      parse var back back comments
   else comments = ""
   comments = Strip(comments)
   back     = Strip(back)
 
return                                 /*@ BA_PLACE_VERB             */
/*
   Place variables 'back' and 'comments' on the line.
   Adjusted specification: place BACK on the line if it will fit, or
       split line if it will not.  Place comments on the line if it
       will fit, or split line if it will not.
.  ----------------------------------------------------------------- */
BF_FORM_LINE:                          /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   if sw.0asis   then do               /* set in B0_PACK             */
      sw.0asis = 0                     /* restore                    */
      return                           /* no processing              */
      end
 
   if sw.0packed then do
      comments = Strip(Translate(comments," ",'3f'x) )
      back     = Strip(Translate(back    ," ",'3f'x) )
      sw.0packed = 0
      end
 
   if lastverb = "PROC" then commpos = pcomm
                        else commpos = icomm
   bklen  = Length(back)
   cmlen  = Length(comments)
   sw.0TooLong = (bklen + cmlen +pt) > 71
   select
 
      when sw.0TooLong then,
         call BFS_SPLIT_LINE           /*                           -*/
 
      when commpos = "RIGHT" then do
         cmpt  = 72 - cmlen            /* start of comment           */
         line = Overlay(comments,line,cmpt)
         text = Overlay(back,line,pt)
         end                           /* RIGHT                      */
 
      when commpos = "TIGHT" then do
         back = Space(back comments,1) /* rejoin back and comments   */
         text = Overlay(back,line,pt)
         end                           /* TIGHT                      */
 
      otherwise do                     /* numeric                    */
         /* We already know the comment will fit on the line         */
         line = Overlay(back,line,pt)    /* place JCL                */
         if Length(Strip(line)) > commpos then,
            line = Strip(line) comments
         else,
            text = Overlay(comments,line,commpos)  /* place comments */
         end                           /* numeric                    */
 
   end                                 /* select                     */
   pt = Min(plc.lastverb,16)           /* set to standard indent     */
 
return                                 /*@ BF_FORM_LINE              */
/*
   The text won't all fit on one line.  Put the JCL on one line and the
   comments on the next.  Always leave 'text' ready because when we
   return, the regular flow will output this line.
.  ----------------------------------------------------------------- */
BFS_SPLIT_LINE:                        /*@                           */
   if branch then call BRANCH
   address ISREDIT
 
   if (bklen + pt) > 71 then do        /* it's already too long      */
      if Right(back,1) = "," then sw.0Comma = 1
 
      do bz = bklen-1 to 1 by -1,      /* find prior comma           */
         while Substr(back,bz,1) <> ","
      end                              /* bz                         */
 
      if bz = 0 then do                /* no commas ???              */
         text = Space(line back comments,1)    /* pack it tight      */
         end
      else do
         bz = bz + 1                   /*                            */
         parse var back  slug =(bz) back     /* snip after the comma */
         line = Overlay(slug,line,pt)
         queue Strip(line)
         line = "//"                   /* ordinary JCL line          */
         text = Overlay(back,line,plc.lastverb)
         end
      end                              /* JCL is too long            */
   else,
      text = Overlay(back,line,pt)
 
   if comments <> "" then do
      queue Strip(text)
      call ZL_LOGMSG(text)
      if WordPos(commpos,"RIGHT TIGHT") > 0 then,
         cmpt  = 72 - cmlen            /* start of comment           */
      else cmpt = commpos
      line = "//*"
      text = Overlay(comments,line,cmpt)
      end
 
return                                 /*@ BFS_SPLIT_LINE            */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.0Setup    = SWITCH("SETUP")
   if sw.0Setup        then do
      parse value   "DD     ELSE ENDIF  EXEC IF   INCLUDE",
                    "JCLLIB JOB  OUTPUT PEND PROC SET"      with,
                    $jfvalvb
      rc = Trace("O"); rc = Trace(tv)
      call AD_SET_DEFAULTS             /*                           -*/
      exit
      end
 
   sw.0Diagnose = SWITCH("DIAGNOSE")    /* shows each line of JCL before
            processing.  Respond with a non-blank to turn on trace.  */
   sw.0SaveLog  = SWITCH("SAVELOG")
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
   Parse out the embedded components at the back of the source code.
.  ----------------------------------------------------------------- */
DEIMBED: Procedure expose,             /*@                           */
   (tk_globalvars)  ddnlist  $ddn.
 
   address TSO
   zz = Msg('OFF')
   "ALLOC FI($TMP) NEW REU UNIT(VIO) SPACE(1) TRACKS RECFM(V B)",
     "LRECL(255) BLKSIZE(0)"
   if rc = 12 then alcunit = "SYSDA"
              else alcunit = "VIO"
   "FREE  FI($TMP)"
   zz = Msg(zz)
 
   fb80po.0  = "NEW UNIT("alcunit") SPACE(5 5) TRACKS DIR(40)",
                   "RECFM(F B) LRECL(80) BLKSIZE(0)"
   parse value ""   with  ddnlist $ddn.  daid.
 
   lastln   = sourceline()
   currln   = lastln                   /*                            */
   if Left(sourceline(currln),2) <> "*/" then return
 
   currln = currln - 1                 /* previous line              */
   "NEWSTACK"
   address ISPEXEC
   do while sourceline(currln) <> "/*"
      text = sourceline(currln)        /* save with a short name !   */
      if Left(text,3) = ")))" then do  /* package the queue          */
         parse var text ")))" ddn mbr .   /* PLIB PANL001  maybe     */
         if Pos(ddn,ddnlist) = 0 then do  /* doesn't exist           */
            ddnlist = ddnlist ddn      /* keep track                 */
            $ddn = ddn || Random(999)
            $ddn.ddn = $ddn
            address TSO "ALLOC FI("$ddn") REU" fb80po.0
            "LMINIT DATAID(DAID) DDNAME("$ddn")"
            daid.ddn = daid
            end
         daid = daid.ddn
         "LMOPEN DATAID("daid") OPTION(OUTPUT)"
         do queued()
            parse pull line
            "LMPUT DATAID("daid") MODE(INVAR) DATALOC(LINE) DATALEN(80)"
         end
         "LMMADD DATAID("daid") MEMBER("mbr")"
         "LMCLOSE DATAID("daid")"
         end                           /* package the queue          */
      else push text                   /* onto the top of the stack  */
      currln = currln - 1              /* previous line              */
   end                                 /* while                      */
   address TSO "DELSTACK"
 
return                                 /*@ DEIMBED                   */
/*
     Find where code was run from.  It assumes cataloged data sets.
 
     Original by Doug Nadel
     With SWA code lifted from Gilbert Saint-flour's SWAREQ exec
.  ----------------------------------------------------------------- */
FIND_ORIGIN: Procedure                 /*@                           */
answer="* UNKNOWN *"                   /* assume disaster            */
Parse Source . . name dd ds .          /* get known info             */
Call listdsi(dd "FILE")                /* get 1st ddname from file   */
Numeric digits 10                      /* allow up to 7FFFFFFF       */
If name = "?" Then                     /* if sequential exec         */
  answer="'"ds"'"                      /* use info from parse source */
Else                                   /* now test for members       */
  If sysdsn("'"sysdsname"("name")'")="OK" Then /* if in 1st ds       */
     answer="'"sysdsname"("name")'"    /* go no further              */
  Else                                 /* hooboy! Lets have some fun!*/
    Do                                 /* scan tiot for the ddname   */
      tiotptr=24+ptr(12+ptr(ptr(ptr(16)))) /* get ddname array       */
      tioelngh=c2d(stg(tiotptr,1))     /* nength of 1st entry        */
      Do Until tioelngh=0 | tioeddnm = dd /* scan until dd found     */
        tioeddnm=strip(stg(tiotptr+4,8)) /* get ddname from tiot     */
        If tioeddnm <> dd Then         /* if not a match             */
          tiotptr=tiotptr+tioelngh     /* advance to next entry      */
        tioelngh=c2d(stg(tiotptr,1))   /* length of next entry       */
      End
      If dd=tioeddnm Then,             /* if we found it, loop through
                                          the data sets doing an swareq
                                          for each one to get the
                                          dsname                     */
        Do Until tioelngh=0 | stg(4+tiotptr,1)<> " "
          tioejfcb=stg(tiotptr+12,3)
          jfcb=swareq(tioejfcb)        /* convert SVA to 31-bit addr */
          dsn=strip(stg(jfcb,44))      /* dsname JFCBDSNM            */
          vol=storage(d2x(jfcb+118),6) /* volser JFCBVOLS (not used) */
          If sysdsn("'"dsn"("name")'")='OK' Then,  /* found it?      */
            Leave                      /* we is some happy campers!  */
          tiotptr=tiotptr+tioelngh     /* get next entry             */
          tioelngh=c2d(stg(tiotptr,1)) /* get entry length           */
        End
      answer="'"dsn"("name")'"         /* assume we found it         */
    End
Return answer                          /*@ FIND_ORIGIN               */
/*
.  ----------------------------------------------------------------- */
ptr:  Return c2d(storage(d2x(Arg(1)),4))          /*@                */
/*
.  ----------------------------------------------------------------- */
stg:  Return storage(d2x(Arg(1)),Arg(2))          /*@                */
/*
.  ----------------------------------------------------------------- */
SWAREQ:  Procedure                     /*@                           */
If right(c2x(Arg(1)),1) \= 'F' Then    /* SWA=BELOW ?                */
  Return c2d(Arg(1))+16                /* yes, return sva+16         */
sva = c2d(Arg(1))                      /* convert to decimal         */
tcb = c2d(storage(21c,4))              /* TCB PSATOLD                */
tcb = ptr(540)                         /* TCB PSATOLD                */
jscb = ptr(tcb+180)                    /* JSCB TCBJSCB               */
qmpl = ptr(jscb+244)                   /* QMPL JSCBQMPI              */
qmat = ptr(qmpl+24)                    /* QMAT QMADD                 */
Do While sva>65536
  qmat = ptr(qmat+12)                  /* next QMAT QMAT+12          */
  sva=sva-65536                        /* 010006F -> 000006F         */
End
return ptr(qmat+sva+1)+16              /*@ SWAREQ                    */
/*
.  ----------------------------------------------------------------- */
ZB_SAVELOG:                            /*@                           */
   if branch then call BRANCH
   address TSO
 
   if Symbol("LOG#") = "LIT" then return          /* not yet set     */
 
   "ALLOC FI($LOG) DA("logdsn") REU" vb4k.0
   "EXECIO" log# "DISKW $LOG (STEM LOG. FINIS"
   "FREE  FI($LOG)"
 
return                                 /*@ ZB_SAVELOG                */
/*
.  ----------------------------------------------------------------- */
ZL_LOGMSG: Procedure expose,           /*@                           */
   (tk_globalvars)  log. log#
   rc = Trace("O")
   address TSO
 
   parse arg msgtext
   parse value  log#+1  msgtext     with,
                zz      log.zz    1  log#   .
 
   if monitor then say,
      msgtext
 
return                                 /*@ ZL_LOGMSG                 */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      is an ISPF edit macro which formats JCL to a predetermined"
say "                standard.  The 'standard' is held in the individual user's"
say "                ISPF profile.  When no profile information is found, the  "
say "                profile is seeded with default characteristics and the    "
say "                user is offered the chance to adjust them to the user's   "
say "                personal preference.                                      "
say "                                                                          "
say "  Syntax:   "ex_nam"  <PCOMM RIGHT | TIGHT | # >                          "
say "                      <ICOMM RIGHT | TIGHT | # >                          "
say "                '(('  <SAVELOG>                                           "
say "                      <SETUP>                                             "
say "                      <DIAGNOSE>                                          "
say "                                                                          "
say "            PCOMM      specifies the alignment for PROC comments          "
say "                                                                          "
say "            ICOMM      specifies the alignment for JCL comments           "
say "                                                                          "
say "                                                 more....                 "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "            PCOMM/ICOMM  may be                                           "
say "                                                                          "
say "                  --  RIGHT to align the comments flush against column 71,"
say "                      or                                                  "
say "                  --  TIGHT to cause comments to continue after the JCL   "
say "                      with one intervening space, or                      "
say "                  --  a column-number to align them in that column.       "
say "                                                                          "
say "                      If the indicated column causes the realigned JCL to "
say "                      overlay the comment, the comment will be written on "
say "                      a following line.                                   "
say "                                                                          "
say "            SAVELOG   orders the process-log to be written to DASD at     "
say "                      task-end.                                           "
say "                                                                          "
say "            SETUP     invokes a dialog to allow the caller to adjust      "
say "                      positioning preferences.  If SETUP is specified, no "
say "                      other processing is done.                           "
say "                                                                          "
say "            DIAGNOSE  is a special, heavy-diagnosis option which shows the"
say "                      caller each line of JCL as it is handled.           "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the             "
say "                  execution in REXX TRACE Mode.                           "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "                                                                          "
say "        "ex_nam"  parameters     ((  debug-options                        "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        "ex_nam"  PCOMM 45 (( SAVELOG                                     "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*
.  ----------------------------------------------------------------- */
BRANCH: Procedure expose,              /*@                           */
        sigl exec_name
   rc = trace("O")                     /* we do not want to see this */
   arg brparm .
 
   origin = sigl                       /* where was I called from ?  */
   do currln = origin to 1 by -1       /* inch backward to label     */
      if Right(Word(Sourceline(currln),1),1) = ":" then do
         parse value sourceline(currln) with pgfname ":" .  /* Label */
         leave ; end                   /*                name        */
   end                                 /* currln                     */
 
   select
      when brparm = "NAME" then return(pgfname) /* Return full name  */
      when brparm = "ID"      then do           /* wants the prefix  */
         parse var pgfname pgfpref "_" .        /* get the prefix    */
         return(pgfpref)
         end                           /* brparm = "ID"              */
      otherwise
         say left(sigl,6) left(pgfname,40) exec_name "Time:" time("L")
   end                                 /* select                     */
 
return                                 /*@ BRANCH                    */
/*
.  ----------------------------------------------------------------- */
DUMP_QUEUE:                            /*@ Take whatever is in stack */
   rc = trace("O")                     /*  and write to the screen   */
   address TSO
   arg mode .
 
   "QSTACK"                            /* how many stacks?           */
   stk2dump    = rc - tk_init_stacks   /* remaining stacks           */
   if stk2dump = 0 & queued() = 0 then return
   if mode <> "QUIET" then,
   say "Total Stacks" rc ,             /* rc = #of stacks            */
    "   Begin Stacks" tk_init_stacks , /* Stacks present at start    */
    "   Excess Stacks to dump" stk2dump
 
   do dd = rc to tk_init_stacks by -1  /* empty each one.            */
      if mode <> "QUIET" then,
      say "Processing Stack #" dd "   Total Lines:" queued()
      do queued();parse pull line;say line;end /* pump to the screen */
      "DELSTACK"                       /* remove stack               */
   end                                 /* dd = 1 to rc               */
 
return                                 /*@ DUMP_QUEUE                */
/* Handle CLIST-form keywords             added 20020513
.  ----------------------------------------------------------------- */
CLKWD: Procedure expose info           /*@ hide all except info      */
   arg kw
   kw = kw"("                          /* form is 'KEY(DATA)'        */
   kw_pos = Pos(kw,info)               /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   rtpt   = Pos(") ",info" ",kw_pos)   /* locate end-paren           */
   slug   = Substr(info,kw_pos,rtpt-kw_pos+1)     /* isolate         */
   info   = Delstr(info,kw_pos,rtpt-kw_pos+1)     /* excise          */
   parse var slug (kw)     slug        /* drop kw                    */
   slug   = Reverse(Substr(Reverse(Strip(slug)),2))
return slug                            /*@CLKWD                      */
/* Handle multi-word keys 20020513
.  ----------------------------------------------------------------- */
KEYWD: Procedure expose info           /*@ hide all vars, except info*/
   arg kw                              /* form is 'KEY DATA'         */
   kw_pos = wordpos(kw,info)           /* find where it is, maybe    */
   if kw_pos = 0 then return ""        /* send back a null, not found*/
   kw_val = word(info,kw_pos+Words(kw))/* get the next word          */
   info   = Delword(info,kw_pos,2)     /* remove both                */
return kw_val                          /*@ KEYWD                     */
/*
.  ----------------------------------------------------------------- */
KEYPHRS: Procedure expose,             /*@                           */
         info helpmsg exec_name        /*  except these three        */
   arg kp                              /* form is 'KEY ;: DATA ;:'   */
   wp    = wordpos(kp,info)            /* where is it?               */
   if wp = 0 then return ""            /* not found                  */
   front = subword(info,1,wp-1)        /* everything before kp       */
   back  = subword(info,wp+1)          /* everything after kp        */
   parse var back dlm back             /* 1st token must be 2 bytes  */
   if length(dlm) <> 2 then            /* Must be two bytes          */
      helpmsg = helpmsg "Invalid length for delimiter("dlm") with KEYPHRS("kp")"
   if wordpos(dlm,back) = 0 then       /* search for ending delimiter*/
      helpmsg = helpmsg "No matching second delimiter("dlm") with KEYPHRS("kp")"
   if helpmsg <> "" then call HELP     /* Something is wrong         */
   parse var back kpval (dlm) back     /* get everything b/w delim   */
   info =  front back                  /* restore remainder          */
return Strip(kpval)                    /*@ KEYPHRS                   */
/*
.  ----------------------------------------------------------------- */
NOVALUE:                               /*@                           */
   say exec_name "raised NOVALUE at line" sigl
   say " "
   say "The referenced variable is" condition("D")
   say " "
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ NOVALUE                   */
/*
.  ----------------------------------------------------------------- */
SHOW_SOURCE:                           /*@                           */
   call DUMP_QUEUE                     /* Spill contents of stacks  -*/
   if sourceline() <> "0" then         /* to screen                  */
      say sourceline(zsigl)
   rc =  trace("?R")
   nop
   exit                                /*@ SHOW_SOURCE               */
/*
.  ----------------------------------------------------------------- */
SS: Procedure                          /*@ Show Source               */
   arg  ssbeg  ssct   .                /* 'call ss 122 6' maybe      */
   if ssct  = "" then ssct  = 10
   if \datatype(ssbeg,"W") | \datatype(ssct,"W") then return
   ssend = ssbeg + ssct
   do ssii = ssbeg to ssend ; say Strip(sourceline(ssii),'T') ; end
return                                 /*@ SS                        */
/*
.  ----------------------------------------------------------------- */
SWITCH: Procedure expose info          /*@                           */
   arg kw                              /* form is 'KEY'              */
   sw_val = Wordpos(kw,info) > 0       /* exists = 1; not found = 0  */
   if sw_val then                      /* exists                     */
      info = Delword(info,Wordpos(kw,info),1) /* remove it           */
return sw_val                          /*@ SWITCH                    */
/*
.  ----------------------------------------------------------------- */
SYNTAX:                                /*@                           */
   errormsg = exec_name "encountered REXX error" rc "in line" sigl":",
                        errortext(rc)
   say errormsg
   zsigl = sigl
   signal SHOW_SOURCE                  /*@ SYNTAX                    */
/*
   Can call TRAPOUT.
.  ----------------------------------------------------------------- */
TOOLKIT_INIT:                          /*@                           */
   address TSO
   info = Strip(opts,"T",")")          /* clip trailing paren        */
 
   parse source  sys_id  how_invokt  exec_name  DD_nm  DS_nm,
                     as_invokt  cmd_env  addr_spc  usr_tokn
 
   parse value "" with  tv  helpmsg  .
   parse value 0   "ISR00000  YES"     "Error-Press PF1"    with,
               sw.  zerrhm    zerralrm  zerrsm
 
   if SWITCH("TRAPOUT") then do
      "TRAPOUT" exec_name parms "(( TRACE R" info
      exit
      end                              /* trapout                    */
 
   sw.nested    = sysvar("SYSNEST") = "YES"
   sw.batch     = sysvar("SYSENV")  = "BACK"
   sw.inispf    = sysvar("SYSISPF") = "ACTIVE"
 
   if Word(parms,1) = "?" then call HELP /* I won't be back          */
 
   "QSTACK" ; tk_init_stacks = rc      /* How many stacks?           */
 
   parse value SWITCH("BRANCH") SWITCH("MONITOR") SWITCH("NOUPDT") with,
               branch           monitor           noupdt    .
 
   parse value mvsvar("SYSNAME") sysvar("SYSNODE") with,
               #tk_cpu           node          .
 
   parse value KEYWD("TRACE")  "O"    with   tv  .
   tk_globalvars = "exec_name  tv  helpmsg  sw.  zerrhm  zerralrm ",
                   "zerrsm  zerrlm  tk_init_stacks  branch  monitor ",
                   "noupdt"
 
   call LOCAL_PREINIT                  /* for more opts             -*/
 
return                                 /*@ TOOLKIT_INIT              */
/*
)))PLIB PTINIT specify column values for formatting
)ATTR
  % TYPE(TEXT)   INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT)   INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT)  INTENS(LOW)
  # TYPE(INPUT)  INTENS(LOW) JUST(RIGHT)
  @ TYPE(TEXT)   INTENS(HIGH) COLOR(YELLOW)
  ! TYPE(INPUT)  INTENS(NON)
  ^ TYPE(OUTPUT) INTENS(HIGH)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
@|-|% Specify Alignment Columns @|-|
%COMMAND ===>_ZCMD
                                                             %SCROLL ===>_ZAMT+
+
+        Profile in use:_profnm+
+
         Preferred Columns for Verb-Alignment: (range: 1-20)
    DD     #z +     ELSE   #z +     ENDIF  #z +     EXEC   #z +
    IF     #z +     INCLUDE#z +     JCLLIB #z +     JOB    #z +
    OUTPUT #z +     PEND   #z +     PROC   #z +     SET    #z +
 
         Preferred Columns for Text-Alignment-after-Verb: (range: 1-36)
    DD     #z +     ELSE   #z +     ENDIF  #z +     EXEC   #z +
    IF     #z +     INCLUDE#z +     JCLLIB #z +     JOB    #z +
    OUTPUT #z +     PEND   #z +     PROC   #z +     SET    #z +
 
    Press ENTER to complete setting values.  Press END to quit.
 
    Known profiles:^PROFS
 
+
)INIT
  .HELP = HLPARMH
  .ZVARS = '($jfptdd $jfptel $jfpten  $jfptex $jfptif $jfptin +
             $jfptjc $jfptjo $jfptou  $jfptpe $jfptpr $jfptse +
             $jfpldd $jfplel $jfplen  $jfplex $jfplif $jfplin +
             $jfpljc $jfpljo $jfplou  $jfplpe $jfplpr $jfplse)'
)PROC
    VER (&$jfptdd,RANGE,1,20)
    VER (&$jfptel,RANGE,1,20)
    VER (&$jfpten,RANGE,1,20)
    VER (&$jfptex,RANGE,1,20)
    VER (&$jfptif,RANGE,1,20)
    VER (&$jfptin,RANGE,1,20)
    VER (&$jfptjc,RANGE,1,20)
    VER (&$jfptjo,RANGE,1,20)
    VER (&$jfptou,RANGE,1,20)
    VER (&$jfptpe,RANGE,1,20)
    VER (&$jfptpr,RANGE,1,20)
    VER (&$jfptse,RANGE,1,20)
    VER (&$jfpldd,RANGE,1,36)
    VER (&$jfplel,RANGE,1,36)
    VER (&$jfplen,RANGE,1,36)
    VER (&$jfplex,RANGE,1,36)
    VER (&$jfplif,RANGE,1,36)
    VER (&$jfplin,RANGE,1,36)
    VER (&$jfpljc,RANGE,1,36)
    VER (&$jfpljo,RANGE,1,36)
    VER (&$jfplou,RANGE,1,36)
    VER (&$jfplpe,RANGE,1,36)
    VER (&$jfplpr,RANGE,1,36)
    VER (&$jfplse,RANGE,1,36)
)END
)))PLIB HLPARMH parameter HELP
)ATTR DEFAULT(%{_)
  % TYPE(TEXT)   INTENS(HIGH)  SKIP(ON)
  { TYPE(TEXT)   INTENS(LOW)   SKIP(ON)
  _ TYPE(INPUT)  INTENS(HIGH)
  ! TYPE(OUTPUT) INTENS(HIGH)  SKIP(ON)
  @ TYPE(OUTPUT) INTENS(LOW)   SKIP(ON)
  } AREA(SCRL) EXTEND(ON)
)BODY EXPAND(||) WIDTH(&ZSCREENW)
%TUTORIAL |-| Specify Alignment Columns |-| TUTORIAL
%Next Selection ===>_ZCMD
 
}hlptxt                                                                        }
)AREA HLPTXT
{   The name of the profile currently in use is displayed at the top of the
{   displayed data.  You may use primary commands%SET{and%LOAD{to access
{   alternative profiles. %"LOAD name"{loads the values stored under "name"
{   onto the display and sets them as the current default. %"SET name"{stores
{   the currently-displayed values under the specified name.  A%SET{is only
{   needed if the values were changed manually.
{
{   Specify the columns into which each verb (JOB, EXEC, DD, etc) will be moved
{   (if possible) and the columns where the text of the remainder of the JCL
{   statement (DSN, UNIT, PGM, etc) will be aligned.  For example:
{
{     ----+----1----+----2----+----3----+----4----+----5----+----6
{     //JOBNAME  JOB (ACCNT),....,
{     //             TYPRUN=SCAN
{     //STEP0001 EXEC PGM=IEFBR14,
{     //             TIME=1
{     //SYSUDATA  DD DSN=......,
{     //             DISP=SHR
{     ----+----1----+----2----+----3----+----4----+----5----+----6
{
{   In this example, 'JOB' is aligned in 12 and the remainder ('(ACCNT)',
{   'TYPRUN=SCAN') in 16.  'EXEC' may have been requested in 11 but cannot be
{   placed there because of an over-long STEPNAME; it has therefore been pushed
{   to 12 and PGM= appears in 17.  The remainder ('TIME=1') was requested in
{   16.  'DD' has been aligned in 13, and the remainder in column 16 ('DSN=',
{   'DISP=SHR')
)PROC
)END
)))PLIB OLCONFRM confirm intent to overlay
)ATTR
  % TYPE(TEXT) INTENS(HIGH) SKIP(ON)
  + TYPE(TEXT) INTENS(LOW) SKIP(ON)
  _ TYPE(INPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT) PAD('_') SKIP(OFF)
  @ TYPE(OUTPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
  $ TYPE(INPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT)
)BODY WINDOW(45,7)
+
+You are about to overwrite profile@name    +
+
+   Is this what you intended ?
+
+         ==> _Z+ (Yes/No)
+
)INIT
  .ZVARS = '(CONFIRM)'
  .CURSOR = CONFIRM
  &CONFIRM = 'N'
)END
*/
