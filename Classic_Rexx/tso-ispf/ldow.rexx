/* REXX    LDOW       determine n-th weekday of the month
 
           Written by Frank Clarke 20031002
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20040120 fxc REXXSKEL to v.20040120;
     20050110 fxc correct error message;
     20050125 fxc enable STACK
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20040120      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call B_CALC                            /*                           -*/
retdate = result
 
if retdate = 0 then,
   if \sw.0terse then,
   msg = "There is no matching date in" ccyy"/"monum
   else msg = 0
else do
                /* Example using 3TU200307                           */
   cardinal = WordPos(seq,"1 2 3 4 5 L")       /* 3 (for 3rd)        */
   ordinal  = Word(ordlist,cardinal)   /* rd                         */
   daypoint = WordPos(dow,daylist)     /* 3 (TU)                     */
   dayname  = Word(daynames,daypoint)  /* Tuesday                    */
   parse var mo ccyy 5 monum .         /* 2003 07                    */
   mthname  = Word(mthlist,monum)      /* July (7th month)           */
   msg      = "The" seq""ordinal dayname "of" mthname"," ccyy,
              "is" ccyy"-"monum"-"Right(result,2,0)
   if sw.0terse then ,
      msg = ccyy"-"monum"-"Right(result,2,0)
   end
 
push msg                               /*                            */
 
if \sw.stack_ret then call DUMP_QUEUE("QUIET")   /*                 -*/
exit                                   /*@ LDOW                      */
/*
   Initialization
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   result   = 0
   ordlist  = "st nd rd th th ast"
   daylist  = "SU MO TU WE TH FR SA SU MO TU WE TH FR SA"
   daynames = "Sunday Monday Tuesday Wednesday Thursday Friday",
              "Saturday"
   mthlist  = "January February March April May June",
              "July August September October November December"
 
   days.   = 31                        /* jan mar may jul aug oct dec*/
   days.02 = 28                        /* feb                        */
   days.04 = 30                        /* apr                        */
   days.06 = 30                        /* jun                        */
   days.09 = 30                        /* sep                        */
   days.11 = 30                        /* nov                        */
 
   sw.0Terse    = SWITCH("TERSE")
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_CALC:                                /*@                           */
   if branch then call BRANCH
   address TSO
 
   today = Date("S")                   /* 20030923                   */
   parse var today ccyy 5  mm 7 dd .
 
   parse var info      tag .           /* 3TH200308                  */
   parse var tag      seq 2 dow 4 mo . /* 3 TH 200308                */
   if WordPos(seq,"1 2 3 4 5 L") = 0 then do
      helpmsg =,
          "The 1st character of the parm must be 1 through 5 or L",
          "designating the n-th or Last weekday of the month."
      call HELP                        /* ...and don't come back     */
      end                              /* bad seq                    */
 
   if Length(mo) = 6 then do           /* req for specific year      */
      end
   else,
   if Length(mo) = 2 then do           /* req for this year          */
      if mm > mo then ccyy = ccyy + 1  /* calc for next year         */
      mo = ccyy""mo
      end
   else do                             /* not 2 or 6                 */
      helpmsg =,
          "Parm must be either 5 or 9 characters consisting of",
          "a single digit (or L) plus a two-character day",
          "plus an optional 4-digit year",
          "plus a 2-digit month."
      call HELP                        /* ...and don't come back     */
      end
   monum = Right(mo,2)
 
   days.02    = 28 + (ccyy//4=0) - (ccyy//100=0) + (ccyy//400=0)
   base_start = Date("B",mo""01,"S")
   day_start  = Left( Date("W",base_start,"B") ,2)
   upper day_start
 
   point  = WordPos(day_start,daylist) /* starting point             */
   target = WordPos(dow,daylist,point)
   offset = target - point             /* could be zero to 6         */
 
   datelist = ""
   date = 1 + offset                   /* date of 1st xxxday         */
   do while(date <= days.monum)
      datelist = datelist date
      date = date + 7
   end                                 /* date                       */
   /* datelist now contains the dates of all the xxxdays in the month*/
   if seq = "L" then,                  /* Last                       */
      date = Word(datelist,Words(datelist))
   else,
      if seq > Words(datelist) then date = 0
   else,
      date = Word(datelist,seq)
 
return(date)                           /*@ B_CALC                    */
/*
.  ----------------------------------------------------------------- */
LOCAL_PREINIT:                         /*@ customize opts            */
   address TSO
 
   sw.stack_ret = SWITCH("STACK")
 
return                                 /*@ LOCAL_PREINIT             */
/*   subroutines below LOCAL_PREINIT are not selected by SHOWFLOW    */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
address TSO;"CLEAR" ; say ""
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      calculates the n-th day of a given month.              "
say "                                                                       "
say "  Syntax:   "ex_nam"  <identifier>                                     "
say "                      <TERSE>                                             "
say "                   (( <STACK>                                             "
say "                                                                          "
say "            identifier   specifies the answer to be returned.  It is in   "
say "                         the form:  #DDyyyyMM where:                      "
say "                 #       is the week of the month: 1 2 3 4 5 or L (last)  "
say "                 DD      is the day-abbreviation: SU MO TU WE TH FR SA    "
say "                 yyyy    is an optional 4-digit year                      "
say "                 MM      is the 2-digit month, 01-12                      "
say "                                                                          "
say "                Thus, 3TU200306 is the 3rd Tuesday of June, 2003.         "
say "                      LFR12 is the last Friday of the December to come    "
say "                      (or this month if called in December).              "
say "                                                                          "
say "            TERSE     returns only the ISO-date for the identifier.  If no"
say "                      date qualifies, '0' is returned.                    "
say "                                                                          "
say "            STACK     causes" exec_name "to return its answer by pushing  "
say "                      it onto the stack.                                  "
say "                                                                          "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "                                                                          "
say "   Debugging tools provided include:                                   "
say "                                                                       "
say "        BRANCH:   show all paragraph entries.                          "
say "                                                                       "
say "        TRACE tv: will use value following TRACE to place the          "
say "                  execution in REXX TRACE Mode.                        "
say "                                                                       "
say "                                                                       "
say "   Debugging tools can be accessed in the following manner:            "
say "                                                                       "
say "        TSO "ex_nam"  parameters     ((  debug-options                 "
say "                                                                       "
say "   For example:                                                        "
say "                                                                       "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                              "
 
if sw.inispf then,
   address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*		REXXSKEL back-end removed to save space              */
