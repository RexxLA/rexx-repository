/* REXX    ELEMLEN    This demonstration program will calculate the
                      length of storage required for a PL/I declared
                      variable.
                      This rtn has few diagnostic features and is meant
                      to be called only by another REXX rtn.
 
           Written by Frank Clarke 20010514
 
     Impact Analysis
.    SYSPROC   TRAPOUT
 
     Modification History
     20021119 fxc upgrade from v.19991109 to v.20021008;
 
*/ arg argline
address TSO                            /* REXXSKEL ver.20021008      */
arg parms "((" opts
 
signal on syntax
signal on novalue
 
call TOOLKIT_INIT                      /* conventional start-up     -*/
rc = Trace("O"); rc = Trace(tv)
info   = parms                         /* to enable parsing          */
 
call A_INIT                            /*                           -*/
call B_ANALYZE                         /*                           -*/
push argline response
 
if \sw.nested then call DUMP_QUEUE     /*                           -*/
exit                                   /*@ ELEMLEN                   */
/*
.  ----------------------------------------------------------------- */
A_INIT:                                /*@                           */
   address TSO
 
   parse value "0 0 0 0 0 0 0 0 0 0 0 0" with,
                stg_len ,
                .
   parse value "" with t1 t2,
                       varn arrspec arrlim ,
                       response ,
                       .
 
return                                 /*@ A_INIT                    */
/*
.  ----------------------------------------------------------------- */
B_ANALYZE:                             /*@                           */
   address TSO
 
   call BA_GET_VARNAME                 /*                           -*/
   call BB_WHAT_TYPE                   /*                           -*/
        if sw.0nodata then return      /* no data type               */
   call BC_CALC_SPACE                  /*                           -*/
 
   if sw.0baseelem then do
      response = "Align on" baseelem
      return                           /*                            */
      end                              /* BASED                      */
 
   if sw.0baseptr  then do
      response = "Pointer aligned"
      return                           /*                            */
      end                              /* BASED                      */
 
   if arrlim = "Indet" then,
      stg_tot = "Indet"
   else,
      stg_tot = stg_len * arrlim
   response = "Length" stg_len  "Depth" arrlim  "Total" stg_tot
 
return                                 /*@ B_ANALYZE                 */
/*
   Parse the variable name from the input.  Is it an array-spec?
.  ----------------------------------------------------------------- */
BA_GET_VARNAME:                        /*@                           */
   address TSO
 
   parse var info t1 info              /* first token                */
   if Datatype(t1,"W") then,           /* whole number               */
      parse var info t1 info           /* variable name              */
   varn = t1
 
   if Left(info,1) = "(" then,         /* separated arrayspec        */
      parse var info "(" arrspec ")" info
 
   if arrspec <> "" then,
      varn = varn"("Space(arrspec,0)")"
 
   parse var varn "("  arrspec ")"     /* maybe was original         */
 
   if arrspec = "" then arrlim = 1     /* not an array               */
   else,
   if Pos(":",arrspec) > 0 then do     /* range                      */
      parse var arrspec lolim ":" hilim
      if Datatype(hilim,"W") + Datatype(lolim,"W") < 2 then,
         arrlim = "Indet"
      else,
         arrlim = hilim - lolim + 1    /* 3:5 = 5-3+1=3              */
      end
   else arrlim = arrspec
   if Datatype(arrlim,"W") = 0 then arrlim = "Indet"
 
return                                 /*@ BA_GET_VARNAME            */
/*
   Determine type: BIN, DEC, CHAR, PIC, PTR.   What else?
.  ----------------------------------------------------------------- */
BB_WHAT_TYPE:                          /*@                           */
   address TSO
 
   slug = Space(info,0)                /* squeeze all spaces out     */
   if slug = "" then do
      sw.0nodata = "1"
      response = "Group of" arrlim
      return                           /* has no type                */
      end
 
   info = Space(info,1)                /* compress                   */
   reserve = ""
   do while info <> ""
      if Left(info,3) = "DEC" then do
         if Left(info,7) = "DECIMAL" then L = 7 ; else L = 3
         info = Delstr(info,1,L)
         sw.0decimal = "1"
         call BBP_SNIP_PAREN           /*                           -*/
         end                           /* DEC                        */
      else,
      if Left(info,3) = "PIC" then do
         if Left(info,7) = "PICTURE" then L = 7 ; else L = 3
         info = Delstr(info,1,L)
         sw.0pic     = "1"
         call BBQ_SNIP_QUOTE           /*                           -*/
         end                           /* PIC                        */
      else,
      if Left(info,3) = "BIN" then do
         if Left(info,6) = "BINARY" then L = 6 ; else L = 3
         info = Delstr(info,1,L)
         sw.0binary  = "1"
         call BBP_SNIP_PAREN           /*                           -*/
         end                           /* BIN                        */
      else,
      if Left(info,3) = "BIT" then do
         info = Delstr(info,1,3)
         sw.0bit     = "1"
         call BBP_SNIP_PAREN           /*                           -*/
         end                           /* BIT                        */
      else,
      if Left(info,4) = "CHAR" then do
         if Left(info,9) = "CHARACTER" then L = 9 ; else L = 4
         info = Delstr(info,1,L)
         sw.0char    = "1"
         call BBP_SNIP_PAREN           /*                           -*/
         end                           /* CHAR                       */
      else,
      if Left(info,3) = "VAR" then do
         if Left(info,7) = "VARYING" then L = 7 ; else L = 3
         info = Strip(Delstr(info,1,L))
         sw.0varchar = "1"
         end                           /* VAR                        */
      else,
      if Left(info,5) = "BASED" then do
         info = Strip(Delstr(info,1,5))
         if Left(info,5) = "(ADDR" then do
            parse var info "(" . "(" baseelem "))" info
            info = Space(info,1)       /* compress                   */
            sw.0baseelem = "1"
            end                        /* ADDR                       */
         else do
            parse var info "(" baseptr  ")" info
            info = Space(info,1)       /* compress                   */
            sw.0baseptr = "1"
            end                        /*                            */
         end                           /* BASED                      */
      else,
      if Left(info,3) = "PTR" then do
         L = 3
         info = Delstr(info,1,L)
         info = Space(info,1)          /* compress                   */
         sw.0ptr     = "1"
         end                           /* PTR                        */
      else,
      if Left(info,7) = "POINTER" then do
         L = 7
         info = Delstr(info,1,L)
         info = Space(info,1)          /* compress                   */
         sw.0ptr     = "1"
         end                           /* POINTER                    */
      else,
      if Left(info,5) = "FLOAT"   then do
         L = 5
         info = Delstr(info,1,L)
         info = Space(info,1)          /* compress                   */
         sw.0float   = "1"
         call BBP_SNIP_PAREN           /*                           -*/
         end                           /* FLOAT                      */
      else,
      if Left(info,5) = "FIXED"   then do
         L = 5
         info = Delstr(info,1,L)
         info = Space(info,1)          /* compress                   */
         sw.0fixed   = "1"
         call BBP_SNIP_PAREN           /*                           -*/
         end                           /* FIXED                      */
      else,
         do
         parse var info badt info
         say "Unrecognized token:" badt
         end
   end                                 /* while info <> empty        */
 
return                                 /*@ BB_WHAT_TYPE              */
/*
   For CHAR, DEC, and BIN, bounded by bananas.
.  ----------------------------------------------------------------- */
BBP_SNIP_PAREN:                        /*@                           */
   address TSO
 
   info = Strip(info)
   if Left(info,1) <> "(" then return
 
   parse var info slug ")" info
   reserve = reserve slug")"
   info = Space(info,1)
 
return                                 /*@ BBP_SNIP_PAREN            */
/*
   For PIC, what's between the quotes?
.  ----------------------------------------------------------------- */
BBQ_SNIP_QUOTE:                        /*@                           */
   address TSO
 
   info = Strip(info)
   if Left(info,1) <> "'" then return
 
   parse var info "'"slug "'" info
   reserve = reserve "'"slug"'"
   info = Space(info,1)
 
return                                 /*@ BBQ_SNIP_QUOTE            */
/*
   How much storage is implied by the dataspec?
.  ----------------------------------------------------------------- */
BC_CALC_SPACE:                         /*@                           */
   address TSO
 
   if sw.0fixed | sw.0float then,
   if sw.0decimal + sw.0binary = 0 then,
      sw.0decimal = 1
 
   if sw.0decimal then do
      parse var reserve "(" dataspec ")" reserve
      parse var dataspec  dataspec ","
      stg_len = (dataspec+2)%2         /* 5+2 %2 = 3                 */
      end ; else,                      /* DEC                        */
   if sw.0binary  then do
      parse var reserve "(" dataspec ")" reserve
      parse var dataspec  dataspec ","
      if dataspec < 16 then stg_len = 2 ; else,
      if dataspec < 32 then stg_len = 4 ; else,
      if dataspec < 64 then stg_len = 8
      end ; else,                      /* BIN                        */
   if sw.0bit     then do
      parse var reserve "(" dataspec ")" reserve
      stg_len = (dataspec + 7) % 8
      end ; else,                      /* BIN                        */
   if sw.0char    then do
      parse var reserve "(" dataspec ")" reserve
      stg_len = dataspec
      if sw.0varchar then stg_len = stg_len + 2
      end ; else,                      /* CHAR                       */
   if sw.0ptr     then do
      stg_len = 4
      end ; else,                      /* PTR                        */
   if sw.0baseelem then do
      stg_len = 0
      end ; else,                      /* BASEELEM                   */
   if sw.0baseptr  then do
      stg_len = 0
      end ; else,                      /* BASEPTR                    */
   if sw.0pic     then do
      parse var reserve "'" dataspec "'" reserve
      pt = Pos(")",dataspec)
      if pt <> 0 then do               /* multiplier...              */
         multspec = Substr(Dataspec,1,pt+1)
         dataspec = Delstr(Dataspec,1,pt+1)
         parse var multspec "(" factor ")"
         end ; else factor = 0         /* pt <> 0                    */
      dataspec = Translate(dataspec," ","V")
      dataspec = Space(dataspec,0)     /* squeeze                    */
      stg_len = Length(dataspec) + factor
      end                              /* PIC                        */
 
return                                 /*@ BC_CALC_SPACE             */
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
if helpmsg <> "" then do ; say helpmsg; say ""; end
ex_nam = Left(exec_name,8)             /* predictable size           */
 
say "  "ex_nam"      demonstrates how to calculate the storage occupied"
say "                by a PL/I variable by examining the declaration.  "
say "                                                                  "
say "  Syntax:   "ex_nam"  <text>                                      "
say "                                                                  "
say "            text      a single PL/I data declaration.  The process"
say "                      does not respond well to embedded comments. "
say "                      The routine will determine whether this is  "
say "                      an array and whether it is binary, decimal, "
say "                      character or picture.  If picture, the spec "
say "                      is checked for a repetition spec and this   "
say "                      length is included in the total length.     "
"NEWSTACK"; pull ; "CLEAR" ; "DELSTACK"
say "   Debugging tools provided include:                              "
say "                                                                  "
say "        MONITOR:  displays key information throughout processing. "
say "                                                                  "
say "        TRACE tv: will use value following TRACE to place the     "
say "                  execution in REXX TRACE Mode.                   "
say "                                                                  "
say "                                                                  "
say "   Debugging tools can be accessed in the following manner:       "
say "                                                                  "
say "        TSO "ex_nam"  parameters     ((  debug-options            "
say "                                                                  "
say "   For example:                                                   "
say "                                                                  "
say "        TSO "ex_nam"  (( MONITOR TRACE ?R                         "
 
address ISPEXEC "CONTROL DISPLAY REFRESH"
exit                                   /*@ HELP                      */
/*      REXXSKEL back-end removed for space                          */
