/* REXX    QIO        Find and count all the files by type (input,
                      output, update).
*/
address ISREDIT
"MACRO (opts)"
signal on syntax
upper opts
parse var opts "TRACE" tv .
parse value tv "N" with tv .
parse value "1        0     0    0 0 0" with,
             lastckpt sw.   ct.    .
parse value ""          with,
            filelist.    filelist  slug     .
rc = Trace("O"); rc = Trace(tv)
 
call C_CHECK_LRECL                     /*                            */
"RESET"
"X ALL"
"F ALL ' FILE '    "
"F ALL ' FILE;'    "
"F NX ' FILE'        FIRST"            /* init                       */
do forever
   if rc > 0 then leave                /* not found                  */
   "(text) = LINE .zcsr"               /* acquire text               */
   "(l#)   = LINENUM .zcsr"
   ln_stack = l#                       /* init to primary line #     */
   text = Strip(Substr(text,txton,txtlen))
   upper text
   if WordPos("DCL",text) = 0 then do
      call A_FIND_DCL                  /*                            */
      end
   if Pos(";",text) = 0 then do
      call B_FIND_SCOLON               /*                            */
      end
   lastckpt = l#
 
   slug  = Space(text,1)
   slug  = Strip( slug , "T" , ";")  ";"
   dclpt = Wordpos("DCL",slug)
   filpt = Wordpos("FILE",slug)
 
   if dclpt = 1 & filpt > 2 then do
      upper slug
      call ZC_ZAPCOMM                  /* excise comments           -*/
      filept = Wordpos("FILE",slug)
 
      part = SubWord(slug,3)           /* exclude 2 words            */
 
      do forever                       /*                            */
         commapt = Pos(",",part)
         if commapt = 0 then
            commapt = Pos(";",part)
         if filept > 2 then do
            mode = "ANY"               /* default                    */
            filename = Word(slug,2)
            /* Examine words 3-n as far as the first comma/semicolon */
            /* Covers "DCL X INPUT FILE, Y STREAM FILE OUTPUT; */
            if Wordpos("INPUT" ,Left(part,commapt)) > 0 then do
               mode = "INPUT"
               end ; else ,
            if Wordpos("OUTPUT" ,Left(part,commapt)) > 0 then do
               mode = "OUTPUT"
               end ; else ,
            if Wordpos("PRINT" ,Left(part,commapt)) > 0 then do
               mode = "OUTPUT"
               end ; else ,
            if Wordpos("VARIABLE" ,Left(part,commapt)) > 0 then do
               mode = "VAR"
               end ; else ,
            if Wordpos("UPDATE" ,Left(part,commapt)) > 0 then do
               mode = "UPDATE"
               end
            if WordPos(filename,filelist.mode) = 0 then do
               ct.mode = ct.mode   + 1
               filelist.mode = filelist.mode filename
               end                     /* unknown filename           */
            if Pos(",",part) > 0 then do /* excise                   */
               /* part is "INPUT FILE, Y STRE....                    */
               /* Pos("," , part) is -11-                            */
               part = DelStr( part , 1 , Pos(",",part) )
               /* part is now " Y STREAM FILE OUTPUT;"               */
               slug = SubWord(slug,1,1) Strip(part)
               /* slug is now "DCL Y STREAM FILE OUTPUT;"            */
               iterate
               end
            end
         else call D_EXCLUDE           /*                            */
         leave
      end                              /* forever                    */
 
      ln_stack = ""                    /* leave everything exposed   */
      end                              /* DCLPT                      */
   else do                             /* dclpt is zero              */
      call D_EXCLUDE                   /*                            */
      end                              /* dclpt is zero              */
 
   slug = ""
   sw.=0
   "F NX ' FILE'  NEXT"                /* next                       */
end                                    /* forever                    */
                                       rc = Trace("O"); rc = Trace(tv)
 
call R_REPORT                          /*                            */
 
"UP MAX"
 
exit(1)                                /*@ QIO                       */
/*
   The text doesn't have a DCL.  Read backwards until the DCL is
   found.
.  ----------------------------------------------------------------- */
A_FIND_DCL:                            /*@                           */
   address ISREDIT
 
   slug = text                         /* save text                  */
   pl# = l#
   do until WordPos("DCL",slug) > 0    /* until found                */
      pl# = pl# - 1                    /* prev line                  */
      if pl# < lastckpt then leave     /*                            */
      "(xst) = XSTATUS" pl#
      if xst = "X" then do
         "XSTATUS" pl# "= NX"
         ln_stack = pl# ln_stack
         end
      "(text) = LINE" pl#              /* acquire text               */
      text = Strip(Substr(text,txton,txtlen))
      if Pos(";",text) > 0 then do
         parse var text . ";" text
         slug = text slug              /* prepend                    */
         leave                         /* force a halt               */
         end
      slug = text slug                 /* prepend                    */
      upper slug
   end                                 /* until                      */
   text = slug                         /* restore                    */
 
   if WordPos("DCL",slug) = 0 then do  /* forced out                 */
      parse value "; ;" with slug text
      call D_EXCLUDE                   /*                            */
      end                              /* forced out                 */
 
return                                 /*@ A_FIND_DCL                */
/*
   The text doesn't have a semicolon.  Read forward until a semicolon
   is found.
.  ----------------------------------------------------------------- */
B_FIND_SCOLON:                         /*@                           */
   address ISREDIT
 
   slug = Strip(text)                  /* save text                  */
   do until Pos(";",slug) > 0          /* until found                */
      l# = l# + 1                      /* prev line                  */
      "(xst) = XSTATUS" l#
      if xst = "X" then do
         "XSTATUS" l#  "= NX"
         ln_stack = ln_stack l#
         end
      "(text) = LINE" l#               /* acquire text               */
      text = Strip(Substr(text,txton,txtlen))
      if Pos(";",text) > 0 then,
         text = Substr( text , 1 , Pos(";",text) )
      slug = slug Strip(text)          /* append                     */
      upper slug
   end                                 /* until                      */
   text = slug                         /* reload                     */
 
return                                 /*@ B_FIND_SCOLON             */
/*
.  ----------------------------------------------------------------- */
C_CHECK_LRECL:                         /*@                           */
   address ISREDIT
 
   "(lr)  = LRECL"
   if lr = 80 then do                  /* source                     */
      parse value "2 71" with txton txtlen .
      return                           /*                            */
      end
 
   "F '1' 1 "                          /*                            */
   if rc > 0 then,                     /* source                     */
      parse value "2 71" with txton txtlen .
   else do                             /* what is it?                */
      "(text) = LINE .zcsr"            /* acquire text               */
      parse var text 2 data .
      if data = "5655-H31" then,       /* Enterprise                 */
         parse value "33 71 " with txton txtlen .
      else,
      if data = "5668-910" then,       /* Optimizer                  */
         parse value "20 71 " with txton txtlen .
      else do
         say "Unknown text type"
         parse value "1" lr   with txton txtlen .
         end
      end
 
return                                 /*@ C_CHECK_LRECL             */
/*
.  ----------------------------------------------------------------- */
D_EXCLUDE:                             /*@                           */
   address ISREDIT
 
   do Words(ln_stack)
      parse var ln_stack   l#  ln_stack
      "XSTATUS" l# "= X"
   end                                 /* words in ln_stack          */
 
return                                 /*@ D_EXCLUDE                 */
/*
.  ----------------------------------------------------------------- */
R_REPORT:                              /*@                           */
   address ISREDIT
 
   indent = 12
   rmarg  = 70
 
   if filelist.input <> "" then do
      filelist.input = STRSORT(filelist.input )
      ct = Left(ct.input "Input :",indent) filelist.input
      do while Length(ct) > rmarg
         pt = Lastpos(" ",ct,rmarg)
         parse var ct slug =(pt) ct
         "LINE_BEFORE 1 = NOTELINE (slug)"
         ct = Left(" ",indent) Strip(ct)
      end                              /* > rmarg                    */
      "LINE_BEFORE 1 = NOTELINE (ct)"
   end                                 /* INPUT                      */
 
   if filelist.output <> "" then do
      filelist.output = STRSORT(filelist.output)
      ct = Left(ct.output "Output:",indent) filelist.output
      do while Length(ct) > rmarg
         pt = Lastpos(" ",ct,rmarg)
         parse var ct slug =(pt) ct
         "LINE_BEFORE 1 = NOTELINE (slug)"
         ct = Left(" ",indent) Strip(ct)
      end                              /* > rmarg                    */
      "LINE_BEFORE 1 = NOTELINE (ct)"
   end                                 /* OUTPUT                     */
 
   if filelist.update <> "" then do
      filelist.update = STRSORT(filelist.update)
      ct = Left(ct.update "Update:",indent) filelist.update
      do while Length(ct) > rmarg
         pt = Lastpos(" ",ct,rmarg)
         parse var ct slug =(pt) ct
         "LINE_BEFORE 1 = NOTELINE (slug)"
         ct = Left(" ",indent) Strip(ct)
      end                              /* > rmarg                    */
      "LINE_BEFORE 1 = NOTELINE (ct)"
   end                                 /* UPDATE                     */
 
   if filelist.any <> "" then do
      filelist.any = STRSORT(filelist.any   )
      ct = Left(ct.any "Any:",indent) filelist.any
      do while Length(ct) > rmarg
         pt = Lastpos(" ",ct,rmarg)
         parse var ct slug =(pt) ct
         "LINE_BEFORE 1 = NOTELINE (slug)"
         ct = Left(" ",indent) Strip(ct)
      end                              /* > rmarg                    */
      "LINE_BEFORE 1 = NOTELINE (ct)"
   end                                 /* ANY                        */
 
   if filelist.var <> "" then do
      filelist.var = STRSORT(filelist.var   )
      ct = Left(ct.var "Variable:",indent) filelist.var
      do while Length(ct) > rmarg
         pt = Lastpos(" ",ct,rmarg)
         parse var ct slug =(pt) ct
         "LINE_BEFORE 1 = NOTELINE (slug)"
         ct = Left(" ",indent) Strip(ct)
      end                              /* > rmarg                    */
      "LINE_BEFORE 1 = NOTELINE (ct)"
   end                                 /* VAR                        */
 
return                                 /*@ R_REPORT                  */
/*
   Only present this routine with a complete statement.
.  ----------------------------------------------------------------- */
ZC_ZAPCOMM:                            /*@                           */
 
   endcomm  = Pos("*/",slug)
   strtcomm = Pos("/*",slug)
   if endcomm > 0 then,
      if strtcomm > 0 then,
         if endcomm > strtcomm  then do  /* internal complete comment */
            slug = Delstr(slug, strtcomm, endcomm-strtcomm+2)
            call ZC_ZAPCOMM
            end                        /*                            */
         else do                       /* incomplete at start        */
            slug = Delstr(slug,1,endcomm +1)
            call ZC_ZAPCOMM
            end                        /*                            */
      else,                            /* incomplete at end          */
         slug = Delstr(slug,1,endcomm +1)
   else,                               /*                            */
   if Pos("/*",slug) > 0 then,         /* comment-start only         */
      slug = Delstr(slug, strtcomm)
 
   slug = Space(slug,1)                /* squeeze                    */
 
   qtpt = Pos( "'" , slug )
   if qtpt > 0 then do
      qtpt2 = Pos( "'" , slug , qtpt+1) /* second quote              */
      if qtpt2 > 0 then do             /* two quotes                 */
         slug = Delstr(slug , qtpt , qtpt2-qtpt+1 )
         end
      end                              /* qtpt present               */
 
return                                 /*@ ZC_ZAPCOMM                */
/*
.  ----------------------------------------------------------------- */
SYNTAX:                                /*@                           */
   errormsg = exec_name "encountered REXX error" rc "in line" sigl":",
                        errortext(rc)
   say errormsg
   zsigl = sigl
   if sourceline() <> "0" then
      say sourceline(zsigl)
   rc = trace("O")
   rc =  trace("?R")
   nop
exit                                   /*@ SYNTAX                    */
