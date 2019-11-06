/* REXX    MEMBERS    Produce a concise member-list for a PO dataset.
                      MEMBERS will return its output to the terminal
                      (by default), or via the stack (option STACK)
                      either as a vertical list (option LIST) or as a
                      single line (option LINE).

           Written by Frank Clarke, Oldsmar, FL

     Impact Analysis
.    SYSPROC   TRAPOUT

     Modification History
     19941026 FXC a dataset with no members should return the string
                  "(EMPTY)"; current version fails by sending the
                  message "Invalid DSName".
     19960410 fxc upgrade to REXXSKEL; handle aliases: if "ALIAS" is
                  specified in [opts] aliasnames are returned in the
                  same way as the main membernames and immediately
                  following their main member, and have "(*)"
                  appended;
     19970820 bab upgrade to REXXSKEL from ver.960119 to ver.970818;
                  correct problem when Alias Names exists w/o true
                  names.
     19971108 fxc upgrade from ver.970818 to v.19971030; y2k
                  compliance; decomm; restore in-line HELP text;
                  minor cosmetics;
     19991111 fxc upgrade from ver.19971030 to v.19991109;

*/ arg argline
address TSO                            /* REXXSKEL ver.19991109      */
arg parms "((" opts

signal on syntax
signal on novalue

call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */

if info = "" then call HELP            /*                           -*/

call A_INIT                            /*                           -*/
                                   if \sw.0error_found then,
call B_LISTD                           /*                           -*/
                                   if \sw.0error_found then,
call C_BUILD                           /*                           -*/

if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ MEMBERS                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO

   if sw.0list + sw.0line <> 1 then,
      parse value "0 1" with sw.0list sw.0line
   parse var info  dsname info
   parse value "0" with sw.0error_found .

return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_LISTD:                               /*@                           */
   if branch then call BRANCH
   address TSO

   trc = Outtrap("L.")
   "LISTD" dsname "M"
   trc = Outtrap("OFF")
   if l.0 < 7 then,
   if sw.0stack then queue "(EMPTY)"   /* no members !               */
   else do
      say "No members in" dsname
      exit
      end

   do ii = 1 to l.0 until Word(l.ii,1) = "--MEMBERS--"
   end

   /*
      Process the memberlist bottom-up.  [slug] is formed of "anything
      accumulated so far" preceeded by the line above it.  When the
      first 3 bytes of [slug] is blank, it's part of an aliaslist;
      keep it.  When the first three bytes are NOT blank, a member
      name has been found; push the accumulated data onto the stack
      and reinitialize [slug].
   */
   slug = ""
   do bx = L.0 to ii+1  by  -1
      slug = L.bx Strip(slug)
      if Left(slug,3) <> "" then do; push slug; slug = ""; end
   end

return                                 /*@ B_LISTD                   */
/*
   The memberlist has been pushed onto the stack.
.  ----------------------------------------------------------------- */
C_BUILD:                               /*@                           */
   if branch then call BRANCH
   address TSO

   parse value 0               with ,
               no_more_q  stak .

/*  The phrase "THE FOLLOWING ALIAS NAMES EXIST WITHOUT TRUE NAMES"
    indicates aliases are in the PDS without true member names to match
    on.  Skip this line and remaining lines in queue for member names
                                           Change add on 970820, BAB */
   do queued()
      pull full_qline
      if no_more_q then iterate        /* Clear the queue out        */
      if POS("THE FOLLOWING ALIAS NAMES",full_qline) > 0 then do
         no_more_q = 1 ; iterate
         end
      parse var full_qline mbr . "ALIAS(" aliaslist ")"
      call CA_STORE                    /* put the mbr on the list   -*/

      if sw.0alias then,
      if aliaslist <> "" then do
         /* diagnose here */           /*                            */
         aliaslist = Translate(aliaslist , " " , ",")
         do while aliaslist  <> ""
            parse var aliaslist mbr aliaslist
            mbr = mbr"(*)"
            call CA_STORE              /*                           -*/
         end                           /* while aliaslist not blank  */
         end
   end

   if stak <> "" then,                 /* we loaded it               */
      if sw.0stack then,
         queue stak
      else,
         say stak

return                                 /*@ C_BUILD                   */
/*
   Given: [mbr] and [aliaslist]
.  ----------------------------------------------------------------- */
CA_STORE:                              /*@                           */
   if branch then call BRANCH
   address TSO

   if sw.0line then,                   /* LINE                       */
      stak = stak mbr
   else,                               /* LIST vertically            */
      if sw.0stack then,               /* sw.0list & sw.0stack       */
         queue    mbr
      else,                            /* sw.0list & \sw.0stack      */
         say      mbr

return                                 /*@ CA_STORE                  */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   if branch then call BRANCH
   address TSO

   sw.0alias = SWITCH("ALIAS")         /* show aliases               */
   sw.0stack = SWITCH("STACK")         /* return via the stack       */
   sw.0list  = SWITCH("LIST")          /* arrange in a vertical list */
   sw.0line  = SWITCH("LINE")          /* arrange on one line        */

return                                 /*@ LOCAL_PREINIT             */

/*-------------------------------------------------------------------*/
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
say "  "ex_nam"      Produces a concise member-list for a PO dataset.  MEMBERS "
say "                will return its output to the terminal (by default), or   "
say "                via the stack (option STACK) either as a vertical list    "
say "                (option LIST) or as a single line (option LINE),          "
say "                default=LINE.                                             "
say "                                                                          "
say "  Syntax:   "ex_nam"  [dsname]                                            "
say "                  ((  [options]                                           "
say "                      [options] are separated from [dsname] by a double   "
say "                      open parenthesis '(('.                              "
say "                                                                          "
say "                                                    ...more               "
pull
"CLEAR"
say "            [STACK]   causes the resultant member list to be returned via "
say "                      the stack.  If STACK is not specified, return is to "
say "                      the terminal.                                       "
say "                                                                          "
say "            [LIST]    causes the returned value(s) to be presented one    "
say "                      member per line (a vertical list).                  "
say "                                                                          "
say "            [LINE]    causes the returned value(s) to be presented as a   "
say "                      single string containing all the members in order.  "
say "                                                                          "
say "            [ALIAS]   requests that alias entries also be returned.       "
say "                      MEMBERS ignores aliases by default.  Alias entries  "
say "                      returned by MEMBERS will have '(*)' appended to the "
say "                      aliasname.                                          "
pull
"CLEAR"
say "   Debugging tools provided include:                                      "
say "                                                                          "
say "        BRANCH:   show all paragraph entries.                             "
say "                                                                          "
say "        TRACE tv: will use value following TRACE to place the execution   "
say "                  in REXX TRACE Mode.                                     "
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