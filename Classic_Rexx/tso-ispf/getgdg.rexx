/* REXX    GETGDG     locate the true name of a GDG generation
 
           Written by Frank Clarke,  Oldsmar  FL
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     950908 fxc upgraded to latest REXXSKEL
     20011210 fxc upgrade from v.950824 to v.200111..
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20010802      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc     = trace(tv)
info   = parms                         /* to enable parsing          */
 
nested = Sysvar("Sysnest") = "YES"
 
parse var parms basenm gen .           /* DT12345.TEST  -2, maybe    */
if gen = "" then gen = 0
 
rc = Outtrap("lc.")
"LISTC LVL("basenm")"
rc = Outtrap("off")
 
jj = 0                                 /* generation index           */
do ii = lc.0 to 1 by -1                /* bottom up                  */
   if Word(lc.ii,1) = "NONVSAM" then do
      parse var lc.ii . . gds .        /* dsname is 3rd word         */
      if gen = jj then do              /* found it                   */
         retname = "'"gds"'"
         if nested then return retname
                   else    say retname
         exit
         end
      else jj = jj -1                  /* decrement                  */
      end
end
 
retname = "<NOT FOUND>"
if nested then return(retname)
          else    say retname
exit                                   /*@                           */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR"
if helpmsg ^= "" then do
   say helpmsg; say ""; end
say "  GETGDG        finds a given generation of a GDGbase given the  "
say "                basename and relative generation.                "
say "                                                                 "
say "  Syntax:   GETGDG    GDGbasename <generation>                   "
say "                                                                 "
say "            GDGbasename must be quoted and adequately qualified. "
say "                                                                 "
say "            <generation> is optional and defaults to "0".  If    "
say "               specified, it must be zero or a negative integer. "
say "                                                                 "
say "                                                                 "
say "      NOTE: GETGDG is designed to be called from another REXX    "
say "            routine.  When so nested, GETGDG returns its result  "
say "            as a function:                                       "
say "               ds = GETGDG('HLQ.SECNDLVL' '-2')                  "
say "               say ds   /* 'HLQ.SECNDLVL.G0007V00' perhaps */    "
say "                                                                 "
say "            When called as a first-level routine, GETGDG         "
say "               'says' its result.                                "
pull
"CLEAR"
say "   Debugging tools provided include:"
say "                                                                 "
say "        MONITOR:  displays key information throughout processing."
say "                  Displays most paragraph names upon entry."
say "                                                                 "
say "        TRACE tv: will use value following TRACE to place"
say "                  the execution in REXX TRACE Mode."
say "                                                                 "
say "                                                                 "
say "   Debugging tools can be accessed in the following manner:"
say "                                                                 "
say "        TSO" exec_name"  parameters  ((  debug-options"
say "                                                                 "
say "   For example:"
say "                                                                 "
say "        TSO" exec_name " (( MONITOR TRACE ?R"
exit                                   /*@ HELP                      */
/*	REXXSKEL back-end removed for space                          */