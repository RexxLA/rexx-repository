/* REXX     LA  v.3    LISTA ST into a stack for one DDName or to screen
                       (with or without DCB info) for one DDName or all
                       of them.

                Written by Frank Clarke, Oldsmar, FL

     Impact Analysis
.    SYSPROC   TRAPOUT

     Modification History
     19980605 fxc standardized; added REXXSKEL v.19980225; DECOMM;
                  version 2 will deliver all dsnames for any or all
                  ddnames;
     19991117 fxc upgrade from v.19980225 to v.19991109;
     20010612 fxc v.3; WIDEHELP and general spiffing;

*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts

signal on syntax
signal on novalue

call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */

call A_INIT                            /*                           -*/
call B_DDN_LIST                        /*                           -*/
call C_FIND_DSNS                       /*                           -*/

if sw.0stack + sw.0list = 0 then exit
if \sw.0list  then,
   if dsnstr <> "" then push dsnstr    /* load stack                 */
if queued() = 0 then,
   if sw.0list then
      push ddname": (empty)"
   else,
      push "(empty)"

if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@                           */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO

   call AA_KEYWDS                      /*                           -*/
   parse value "" with,
         dsnstr  dc.  ln.  start.  end.  ddn.
   parse value "0 0 0 0 0 0 0 0 0 0 0" with,
         ii   ddnx  ddn#   dsnx  .
   if \sw.nested then sw.0stack = "0"

   parse var parms ddname
   ddname = Space(ddname,1)

   rc = Outtrap("ln.")                 /* open trap                  */
   "LISTA ST"
   rc = Outtrap("OFF")                 /* close trap                 */

return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
AA_KEYWDS:                             /*@                           */
   if branch then call BRANCH
   address TSO


return                                 /*@ AA_KEYWDS                 */
/*
.  ----------------------------------------------------------------- */
B_DDN_LIST:                            /*@                           */
   if branch then call BRANCH
   address TSO
                                       /* Build DDName stack         */
   do trapx = 1 to ln.0                /* for each trapped line      */

      if Left(ln.trapx,1) <> "" then,  /* DSName                     */
         iterate                       /* pick it up later           */

      if Substr(ln.trapx,3,1) <> " " then do /* new DDName           */
         ddn#       = ddn# + 1         /* DDName index               */
         ddn.ddn#   = Word(ln.trapx,1) /* save DDName                */
         start.ddn# = trapx - 1        /* 1st dsn on previous line   */
         end.ddn#   = trapx - 1        /* ...maybe the last one, too */
         end
      else if Left(ln.trapx,1) = " " then,    /* concatenated DSName */
         end.ddn#   = trapx - 1        /* new end-point              */

   end                                 /* trapx                      */

return                                 /*@ B_DDN_LIST                */
/*
.  Given: array of DDNames (ddn.), the location of the 1st DSName
   for the DDName (start.) and the last DSName (end.); produce the
   requested output.
.  ----------------------------------------------------------------- */
C_FIND_DSNS:                           /*@                           */
   if branch then call BRANCH
   address TSO

   if \sw.nested then "CLEAR"

   do ddnx = 1 to ddn#                 /* for all ddnames            */
      if Wordpos(ddn.ddnx,ddname) > 0 |, /* target DDName ?          */
         ddname = "" then do           /*   or none specified        */
         wrkddn = ddn.ddnx             /* save for printing          */

         do dsnx = start.ddnx to end.ddnx by 2 /* for each DSName    */
            if sw.0stack then do       /* STACK requested            */
               if sw.0detail then queue Left(wrkddn,8) ln.dsnx; else,
               dsnstr = dsnstr ln.dsnx /* form one-line list         */
               end
            else,
            if sw.0list then do        /* LIST requested             */
               dsnstr = dsnstr ln.dsnx /* form one-line list         */
               end
            else,
            if sw.0dcb then do         /* DCB requested              */
               rc = Outtrap("dc.")     /* open trap                  */
               "LISTD '"ln.dsnx"'"     /* LISTD to trap              */
               parse var dc.3,         /* delivered DCB              */
                         recfm,
                         lrecl,
                         blksize,
                         dsorg .       /* ...and clip off the rest.  */
               slug = Left(recfm,3),   /* must all be equal          */
                      Right(lrecl,4),  /* must all be equal          */
                      Right(blksize,7), /* right-justify             */
                      dsorg            /* must all be equal          */
               say Left(Left(wrkddn,10), /* DDName                   */
                        ln.dsnx,50),   /* DSName                     */
                   slug                /* DCB                        */
               rc = Outtrap("off")     /* close trap                 */
               end
            else,                      /* not STACK, not DCB         */
               say Left(Left(wrkddn,10), /* DDName                   */
                        ln.dsnx,50)    /* DSName                     */
            wrkddn=""                  /* group-indicate             */
         end                           /* dsnx                       */
         if sw.0list then do
            queue ddn.ddnx":" dsnstr
            dsnstr = ""
            end

         end                           /* ddn = ddname               */
   end                                 /* ddnx                       */

return                                 /*@ C_FIND_DSNS               */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO

   sw.0dcb     = SWITCH("DCB")
   sw.0detail  = SWITCH("DETAIL")
   sw.0stack   = SWITCH("STACK")
   sw.0list    = SWITCH("LIST")

return                                 /*@ LOCAL_PREINIT             */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO "CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"  (v.3) Allocation List to stack or display                     "
say "                                                                          "
say "  Syntax:   "ex_nam"  [ddname-list]  ((  [options]                        "
say "                                                                          "
say "            [options]   may contain any of:                               "
say "                        DCB    STACK    DETAIL   LIST                     "
say "                                                                          "
say "            DCB       produces a list of DSNames + DCBs.  DCB is only     "
say "                      appropriate for DISPLAY (that is, not STACK).       "
say "                                                                          "
say "            STACK     returns information to a calling routine via the    "
say "                      data stack.  The format depends on other options.   "
say "                      STACK is ignored unless invocation is via an        "
say "                      independent caller.                                 "
say "                                                                          "
say "            STACK and DCB are mutually exclusive.                         "
say "                                                                          "
say "                                                    more....              "
pull
"CLEAR"
say "            DETAIL   If present, this requests the output be returned in  "
say "                      two-column format with the first column being a     "
say "                      group-indicated DDName and the second column the    "
say "                      DSName.                                             "
say "                     If not present, the output is returned as a string   "
say "                      containing the fully-qualified, unquoted list of    "
say "                      DSNames allocated to the specified DDName.          "
say "                                                                          "
say "            LIST     If present, this requests the output be returned one "
say "                      line per DDName in the format                       "
say "                          [ddn]: [dsnlist]                                "
say "                      The DSNames are unquoted fully-qualified.           "
say "                                                                          "
say "            DETAIL and LIST are mutually exclusive.                       "
say "                                                                          "
say "                                                    more....              "
pull
"CLEAR"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        MONITOR:  displays key information throughout processing.         "
say "                  Displays most paragraph names upon entry.               "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution in"
say "                  REXX TRACE Mode.                                        "
say "                                                                          "
say "                                                                          "
say "   Debugging tools can be accessed in the following manner:               "
say "                                                                          "
say "        TSO" exec_name"  parameters  ((  debug-options                    "
say "                                                                          "
say "   For example:                                                           "
say "                                                                          "
say "        TSO" exec_name " (( MONITOR TRACE ?R                              "
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/****** REXXSKEL back-end removed to save space.   *******/