/* REXX       SEGMENT     Label the sections of a PL/I compiler listing.
 
     Impact Analysis
.    SYSEXEC   COMPSTAT
 
     Modification History
     20040727 fxc implement .LIST and .ESD; identify unreferenced
                  variables to their subprocedure; COMPSTAT ASIS;
 
*/ arg argline                         /* pro-forma quick-start      */
address ISREDIT
"MACRO (opts)"
 
upper opts
parse var opts "TRACE" tv .
parse value tv "N" with tv .
rc = Trace("O"); rc = Trace(tv)
 
parse value "" with lbllist .
parse value "0" with sw.  .
sw.0Lbls  = WordPos("LABELS",opts) > 0 /* only return LBLLIST        */
sw.0Terse = WordPos("TERSE",opts) > 0  /* start with 'X ALL'         */
 
"CAPS OFF"                             /* allow lower case messages  */
"F p'^' FIRST"
"(text) = LINE .zcsr"
if Left(text,9) = "15655-H31" then,    /* Enterprise                 */
   call E_ENT                          /*                           -*/
else,
if Left(text,9) = "15668-910" then,    /* Optimizer                  */
   call O_OPT                          /*                           -*/
else do
   call Q_COMP                         /*                            */
   end                                 /*                            */
 
lbllist = Space(lbllist,1)
address ISPEXEC "VPUT LBLLIST SHARED"
 
"L 0"
return                                 /*@ SEGMENT                   */
/* ------  Subroutines below  -------------------------------------- */
/*
   Set
       .CICS (start of CICS language translator)
       .SRC  (start of compiler listing)
       .ATTR (Attribute/cross-reference table)
       .UNRF (Unreferenced Identifiers)
       .AGR  (Aggregate Length Table)
       .BLK  (Block Name List)
       .LIST (Pseudo Assembly Listing)
       .ESD  (External Symbol Dictionary)
       .EXT  (External Symbol Xref)
       .MAP  (Variable Storage Map)
       .OFF  (Offset Table)
       .DIAG (Compiler diagnostic section)
       .LINK (start of Linkage Editor listing)
.  ----------------------------------------------------------------- */
E_ENT:                                 /*@                           */
   bb_tv = trace()                     /* what setting at entry ?    */
   address ISREDIT
 
   if sw.0Terse then "RESET"
   if sw.0Terse then "X ALL"
 
   "F FIRST 'COMMAND LANGUAGE TR'"
   if rc = 0 then do
      "F  'SOURCE LISTING'"            /* translator source          */
      if \sw.0Lbls then,
      "LABEL .zcsr = .CICS 0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".CICS" l#
      helpmsg = "Start of CICS Source at .CICS "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 3 'Compiler Source' "
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .SRC 0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".SRC " l#
      helpmsg = Left("Start of Source at",27) ".SRC "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 22 'Attribute/Xref Table' "
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .ATTR 0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".ATTR" l#
      helpmsg = Left("Attribute/XREF at",27) ".ATTR"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 21 'Unreferenced Identif' "
   if rc = 0 then do
      sw.0_UNRF = 1                    /* found                      */
      if \sw.0Lbls then,
      "LABEL .zcsr = .UNRF 0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".UNRF" l#
      helpmsg = Left("Unreferenced Identifiers at",27) ".UNRF"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 22 'Aggregate Length Table'"
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .AGR  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".AGR " l#
      helpmsg = Left("Aggregate Length Table at",27) ".AGR "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 23 'Block Name List'"
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .BLK  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".BLK " l#
      helpmsg = Left("Block Name List at",27) ".BLK "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 45 'P S E U D O  '    "
   if rc = 0 then do
      if \sw.0Lbls then,
         "LABEL .zcsr = .LIST 0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".LIST" l#
      helpmsg = Left("Pseudo-Assembler List at",27) ".LIST"
      if \sw.0Lbls then,
         "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 47 'N A L   S Y M'    "
   if rc = 0 then do
      if \sw.0Lbls then,
         "LABEL .zcsr = .ESD  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".ESD " l#
      helpmsg = Left("External Symbol Dict at",27) ".ESD "
      if \sw.0Lbls then,
         "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 55 'B O L   C R'    "
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .EXT  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".EXT " l#
      helpmsg = Left("External Symbol Xref at",27) ".EXT "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 54 'A G E   O F F S E T   L I'"
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .MAP  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".MAP " l#
      helpmsg = Left("Variable Storage Map at",27) ".MAP "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 16 'TABLES OF OFFSETS'      "
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .OFF  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".OFF " l#
      helpmsg = Left("Offset Table at",27) ".OFF "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F  3 'Compiler Messages'      "
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .DIAG 0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".DIAG" l#
      helpmsg = Left("Compiler Diagnostics at",27) ".DIAG"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F  3 'File Reference Ta'      "
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .CNFG 0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".CNFG" l#
      helpmsg = Left("Configuration Components at",27) ".CNFG"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F  3 'End of compilation'     "
   if rc = 0 then do
      "F '1' 1"
      if rc = 0 then do
         if \sw.0Lbls then,
         "LABEL .zcsr = .LINK 0"
         "(l#) = LINENUM .zcsr"
         lbllist = lbllist ".LINK" l#
         helpmsg = Left("Linkage Editor listing at",27) ".LINK"
         if \sw.0Lbls then,
         "LINE_BEFORE 1 = NOTELINE (helpmsg)"
         end
      end
                                     rc = Trace("O"); rc = trace(bb_tv)
   if sw.0Lbls then return             /* lbllist only               */
   if sw.0_UNRF then call EA_UNRF      /* label unrefs               */
 
return                                 /*@ E_ENT                     */
/*
.  ----------------------------------------------------------------- */
EA_UNRF:                               /*@                           */
   address ISREDIT
 
   call EAA_SET_LIMITS                 /*                           -*/
   call EAB_LIST_STMTS                 /*                           -*/
   call EAC_FIND_PROCS                 /*                           -*/
   call EAD_TAG_UNRF                   /*                           -*/
 
   if sw.0Terse then do
      "X ALL .SRC" end_src
      "L .SRC"
      "L" end_src
      end
 
   "COMPSTAT" "ASIS"                   /* restore statistics
                                          but no SHORTPG             */
 
return                                 /*@ EA_UNRF                   */
/*
.  ----------------------------------------------------------------- */
EAA_SET_LIMITS:                        /*@                           */
   address ISREDIT
 
   pt = WordPos(".SRC",lbllist)
   end_src = Word(lbllist,pt+2)
 
   pt = WordPos(".UNRF",lbllist)
   start_unrf = Word(lbllist,pt+1)
   end_unrf   = Word(lbllist,pt+3)
 
return                                 /*@ EAA_SET_LIMITS            */
/*
.  ----------------------------------------------------------------- */
EAB_LIST_STMTS:                        /*@                           */
   address ISREDIT
 
   stmtlist = ""
   do ex = start_unrf to end_unrf
      "(text) = LINE" ex
      parse var text 2 blank 8 stmt# 14
      if blank <> "" then iterate
      if WordPos(stmt#,stmtlist) > 0 then iterate
      stmtlist = stmt# stmtlist
   end                                 /* ex                         */
 
return                                 /*@ EAB_LIST_STMTS            */
/*
.  ----------------------------------------------------------------- */
EAC_FIND_PROCS:                        /*@                           */
   address ISREDIT
 
   "F ALL WORD PROC      .SRC" end_src
   "F ALL WORD PROCEDURE .SRC" end_src
 
   tag. = "?"
   pos = "LAST"
   stmt# = ""
   do Words(stmtlist)
      parse value stmtlist stmt#  with   stmt# stmtlist
      "F '"stmt#"' 18 24 LAST WORD .SRC" end_src
      if rc > 0 then iterate
      call EACA_FIND_PROC              /*                           -*/
      tag.stmt# = Strip(label)
   end                                 /* stmtlist                   */
   stmtlist = stmtlist stmt#           /* save last                  */
 
return                                 /*@ EAC_FIND_PROCS            */
/*
.  ----------------------------------------------------------------- */
EACA_FIND_PROC:                        /*@                           */
   address ISREDIT
 
   label = ""
   do while label = ""                 /* find label                 */
      "F 'PROC' NX PREV"
      if rc = 4 then do
         label = "main"
         leave
         end
 
      "(text) = LINE" .zcsr
      parse var text 33 text
      parse var text label ":" back  .
      if Words(label) <> 1 then do
         label = ""
         iterate
         end
      if Left(back,4) = "PROC" then leave     /* found it            */
 
      if Left(Word(text,1),4) = "PROC" then,  /* label on prev       */
         do while label = ""
            "F P'=' 33 88 PREV"
            "(text) = LINE" .zcsr
            parse var text 33 text
            parse var text label ":" back
            if Words(label) = 1 then leave
         end                           /*                            */
   end                                 /* label                      */
 
return                                 /*@ EACA_FIND_PROC            */
/*
.  ----------------------------------------------------------------- */
EAD_TAG_UNRF:                          /*@                           */
   address ISREDIT
 
   do ex = start_unrf to end_unrf
      "(text) = LINE" ex
      parse var text 2 blank 7 stmt# 14
      if blank <> "" then iterate
      stmt# = Strip(stmt#)
      if WordPos(stmt#,stmtlist) = 0 then iterate
 
      tagline = "in" tag.stmt#
      text    = Overlay(tagline,text,48)
      "LINE" ex  " = (text)"
   end                                 /* ex                         */
 
return                                 /*@ EAD_TAG_UNRF              */
/*
   Set .CICS (start of CICS source)
       .SRC  (start of compiler listing)
       .ATTR (Attribute/cross-reference table)
       .AGR  (Aggregate Length Table)
       .MAP  (Variable Storage Map)
       .OFF  (Offset Table)
       .DIAG (Compiler diagnostic section)
       .LINK (start of Linkage Editor listing)
.  ----------------------------------------------------------------- */
O_OPT:                                 /*@                           */
   address ISREDIT
 
   if sw.0Terse then "X ALL"
 
   "F FIRST 'COMMAND LANGUAGE TR'"
   if rc = 0 then do
      "F  'SOURCE LISTING'"            /* translator source          */
      if \sw.0Lbls then,
      "LABEL .zcsr = .CICS 0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".CICS" l#
      helpmsg = "Start of CICS Source at .CICS "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 2     '5668-910'  FIRST"         /* PL/I compiler              */
   if rc > 0 then do
      helpmsg = "Couldn't find the start of the Compiler Listing."
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      helpmsg = "Is this a PL/I compiler listing?"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      return
      end
   "F       'SOURCE LISTING'"          /* after preprocessor source  */
   if rc > 0 then do
      helpmsg = "Couldn't find the start of the Source Listing."
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      helpmsg = "Is this a PL/I compiler listing?"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      return
      end
   if \sw.0Lbls then,
   "LABEL .zcsr = .SRC 0"
   "(l#) = LINENUM .zcsr"
   lbllist = lbllist ".SRC " l#
   helpmsg = "Start of Source at .SRC "
   if \sw.0Lbls then,
   "LINE_BEFORE 1 = NOTELINE (helpmsg)"
 
   "F FIRST 'ATTRIBUTES AND REFERENCES'" /* start of xref section    */
   if rc > 0 then do
      helpmsg = "Couldn't find the Attribute and Cross-reference section. "
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      helpmsg = "Is this a PL/I compiler listing?"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      return
      end
   if \sw.0Lbls then,
   "LABEL .zcsr = .ATTR 0"
   "(l#) = LINENUM .zcsr"
   lbllist = lbllist ".ATTR" l#
   helpmsg = "Attribute/XREF at .ATTR"
   if \sw.0Lbls then,
   "LINE_BEFORE 1 = NOTELINE (helpmsg)"
 
   "F FIRST 'AGGREGATE LENGTH TABLE'"
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .AGR  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".AGR " l#
      helpmsg = "Aggregate Length Table at .AGR"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F FIRST 'VARIABLE STORAGE MAP'"
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .MAP  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".MAP " l#
      helpmsg = "Variable Storage Map at .MAP"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F FIRST 'TABLES OF OFFSETS'"
   if rc = 0 then do
      if \sw.0Lbls then,
      "LABEL .zcsr = .OFF  0"
      "(l#) = LINENUM .zcsr"
      lbllist = lbllist ".OFF " l#
      helpmsg = "Offset Table at .OFF"
      if \sw.0Lbls then,
      "LINE_BEFORE 1 = NOTELINE (helpmsg)"
      end
 
   "F 2 'COMPILER DIAGNOSTIC' FIRST "  /* end of xref section        */
   if rc > 0 then do
      "F 2 'NO MESSAGES PRODUCED' FIRST " /* end of xref section     */
      if rc > 0 then do
         "F 2 'NO MESSAGES OF SEVER' FIRST " /* end of xref section  */
         if rc > 0 then do
            helpmsg = "Couldn't find the Diagnostic Messages section. "
            if \sw.0Lbls then,
            "LINE_BEFORE 1 = NOTELINE (helpmsg)"
            helpmsg = "Is this a PL/I compiler listing?"
            if \sw.0Lbls then,
            "LINE_BEFORE 1 = NOTELINE (helpmsg)"
            return
            end
         end
      end
   if \sw.0Lbls then,
   "LABEL .zcsr = .DIAG 0"
   "(l#) = LINENUM .zcsr"
   lbllist = lbllist ".DIAG" l#
   "(lastline ignore) = CURSOR"
   helpmsg = "Compiler Diagnostics at .DIAG"
   if \sw.0Lbls then,
   "LINE_BEFORE 1 = NOTELINE (helpmsg)"
 
   "F 'END OF COMPILATION' 2"
   if rc = 0 then do
      "F '1'  1"
      if rc = 0 then do
         if \sw.0Lbls then,
         "LABEL .zcsr = .LINK 0"
         "(l#) = LINENUM .zcsr"
         lbllist = lbllist ".LINK" l#
         helpmsg = "Linkedit Listing at .LINK"
         if \sw.0Lbls then,
         "LINE_BEFORE 1 = NOTELINE (helpmsg)"
         end
      end
 
return                                 /*@ O_OPT                     */
/*
   First line is not compiler-specific.  See if there are any such
   lines.
.  ----------------------------------------------------------------- */
Q_COMP:                                /*@                           */
   address ISREDIT
 
   "F FIRST       '15668-910' 1"       /* Optimizer                  */
   if rc = 0 then do
      call O_OPT                       /*                           -*/
      return
      end
 
   "F FIRST       '15655-H31' 1"       /* Enterprise                 */
   if rc = 0 then do
      call E_ENT                       /*                           -*/
      return
      end
 
   zerrhm    = "ISR00001"
   zerralrm  = "YES"
   zerrsm    = "Which compiler?"
   zerrlm    = "I don't recognize the compiler."
   address ISPEXEC "SETMSG MSG(ISRZ002)"
 
return                                 /*@ Q_COMP                    */
