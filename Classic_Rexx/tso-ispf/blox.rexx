/* REXX    BLOX   create block letters from an input string.
                for each of eight lines
                   for each letter in string
                      get pattern for letter
                      get sub-pattern for this line
                      build slug
                      attach to line
                   write the line
 
                Written by Frank Clarke, Oldsmar, FL
 
*/
address TSO
signal on syntax
 
tv="" ; odsn=""                        /* ensure values              */
sav = ""
parse upper arg instr "((" parms       /* get parameters             */
if instr="" & parms="" then call HELP  /* no parms at all            */
parms = Strip(parms,T,")")             /* clip trailing paren        */
 
parse value  KEYWD("TRACE")  "O"  with  tv  .
odsn       = KEYWD("OUTPUT")           /* output to file ?           */
if Pos("(",odsn) > 0 then,             /* has a left banana          */
if Pos(")",odsn) = 0 then,             /* but no right banana        */
   odsn = Space(odsn")",0)             /* add one                    */
 
prompt     = \SWITCH("NOPROMPT")
diagnose   = SWITCH("DIAGNOSE")
instr      = Strip(instr)              /* clean the input            */
rc = Trace(tv)
 
if odsn <> "" then do                  /* was a value                */
   "ALLOC FI(BLOXDD) DA("odsn") SHR REU"
   if rc > 0 then do                   /* doesn't exist ?            */
      "ALLOC FI(BLOXDD) DA("odsn") NEW REU SPACE(1) TRACKS",
           " RECFM(V B) LRECL(121) BLKSIZE(1210) UNIT(SYSDA)"
      if rc > 0 then do                /* ...and couldn't create it! */
         say "Allocation failed for "odsn"."
         exit
         end                           /* alloc NEW                  */
      end                              /* alloc SHR                  */
   end                                 /* alloc dataset              */
else "ALLOC FI(BLOXDD) DA(*) SHR REU"  /* to the terminal            */
 
call SET_PATN                          /*                           -*/
if tv = "O" then "CLEAR"               /* clear screen               */
 
if instr = "" then do                  /* no input ?                 */
   say ":"                             /* initial prompt             */
   "NEWSTACK"
   pull instr
   "DELSTACK"
   end
 
do forever
   do while instr <> ""
      if length(instr) > 8 then do     /* too long                   */
         parse var instr instr 9 sav   /* save the excess            */
         end
 
      do i = 1 to 7                    /* for 7 lines                */
         outline=""                    /* clear it                   */
         do j = 1 to Length(instr)     /* for each letter            */
            ltr = Substr(instr,j,1)    /* isolate it                 */
            ltrpos = Pos(ltr,choices)  /* where in the array ?       */
            if ltrpos = 0 then ltrpos = 47 /* set to blank           */
            byte = Substr(patn.ltrpos,i*2-1,2)
            if diagnose then say ltr byte X2B(byte)
            slug = X2B(byte)           /* character-to-binary        */
            slug = Translate(slug," ","0") /* off -> blank           */
            slug = Translate(slug,ltr,"1") /* on -> letter           */
            outline = outline slug     /* splice to the line         */
         end                           /* j for length(instr)        */
         queue outline                 /* into the queue             */
      end                              /* i for 7 lines              */
      instr = ""
      queue " "                        /* blank line                 */
      queue " "                        /* blank line                 */
 
      rc = Trace("O")
      rc = Trace(tv)
      if sav <> "" then do             /* was there excess ?         */
         instr = sav                   /* restore it                 */
         sav = ""                      /* indicate "no excess"       */
         end
   end                                 /* while instr filled         */
 
   if prompt then,
   if instr = "" then do               /* no more input ?            */
      say ":"                          /* prompt for more            */
      "NEWSTACK"
      pull instr
      "DELSTACK"
      end
   if instr = "" then leave            /* prompt was refused         */
end                                    /* forever                    */
 
rc = Trace("O") ; rc = Trace(tv)
"EXECIO" queued() "DISKW BLOXDD (FINIS"  /* flush to output          */
"FREE  FI(BLOXDD)"
 
exit
/*
.  ----------------------------------------------------------------- */
SET_PATN:                              /*@                           */
   patn.=""                               /* storage for patterns       */
   patn.1  = "081422417F4141"   /*  A   */
   patn.2  = "7E41417E41417E"   /*  B   */
   patn.3  = "3E41404040413E"   /*  C   */
   patn.4  = "7C42414141427C"   /*  D   */
   patn.5  = "7F40407C40407F"   /*  E   */
   patn.6  = "7F40407C404040"   /*  F   */
   patn.7  = "7E41404047417E"   /*  G   */
   patn.8  = "4141417F414141"   /*  H   */
   patn.9  = "1C08080808081C"   /*  I   */
   patn.10 = "7F02020202423C"   /*  J   */
   patn.11 = "41424478444241"   /*  K   */
   patn.12 = "4040404040407F"   /*  L   */
   patn.13 = "41635549414141"   /*  M   */
   patn.14 = "41615149454341"   /*  N   */
   patn.15 = "3E41414141413E"   /*  O   */
   patn.16 = "7E41417E404040"   /*  P   */
   patn.17 = "3E41414145423D"   /*  Q   */
   patn.18 = "7E41417E444241"   /*  R   */
   patn.19 = "3E41403E01413E"   /*  S   */
   patn.20 = "7F080808080808"   /*  T   */
   patn.21 = "4141414141413E"   /*  U   */
   patn.22 = "41414141221408"   /*  V   */
   patn.23 = "41414141494936"   /*  W   */
   patn.24 = "41221408142241"   /*  X   */
   patn.25 = "41221408080808"   /*  Y   */
   patn.26 = "7F02040810207F"   /*  Z   */
   patn.27 = "3E43454951613E"   /*  0   */
   patn.28 = "0818080808083E"   /*  1   */
   patn.29 = "3E41020408103E"   /*  2   */
   patn.30 = "7F020C0201413E"   /*  3   */
   patn.31 = "2040487F080808"   /*  4   */
   patn.32 = "7F40407E01017E"   /*  5   */
   patn.33 = "0408103E41413E"   /*  6   */
   patn.34 = "7F020408080808"   /*  7   */
   patn.35 = "3E41413E41413E"   /*  8   */
   patn.36 = "3E41413E040810"   /*  9   */
   patn.37 = "22227F227F2222"   /*  #   */
   patn.38 = "143E403E013E14"   /*  $   */
   patn.39 = "21522408122542"   /*  %   */
   patn.40 = "0018241825423D"   /*  &   */
   patn.41 = "0022143E142200"   /*  *   */
   patn.42 = "04081010100804"   /*  (   */
   patn.43 = "10080404040810"   /*  )   */
   patn.44 = "0000003E000000"   /*  -   */
   patn.45 = "00181800181800"   /*  :   */
   patn.46 = "00000000000000"   /*blank */
   patn.47 = "00181800181808"   /*  ;   */
   patn.48 = "3E410104080008"   /*  ?   */
   choices ="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#$%&*()-: ;?"
return                                 /*@ SET_PATN                  */
/*
.  ----------------------------------------------------------------- */
HELP:                                  /*@                           */
"CLEAR"                                /* clear screen               */
say "                                                                 "
say " BLOX is a REXX routine which will build 8x7 block letters       "
say "   from text you specify.                                        "
say "                                                                 "
say " BLOX can handle strings to length=8 and will write either to    "
say "   the screen-face or to a file you name.  Syntax for BLOX is:   "
say "      BLOX <string>  <options>                                   "
say "                                                                 "
say "      <options>:  OUTPUT output-dsname                           "
say "                                                                 "
exit                                   /*@ HELP                      */
 
/*-------------------------------------------------------------------*/
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
 
/*-------------------------------------------------------------------*/
SWITCH:                                /*@                           */
arg kw .
sw_val  = Wordpos(value(kw),parms) > 0
if sw_val  then parms = Delword(parms,Wordpos(value(kw),parms),1)
return sw_val                          /*@ SWITCH                    */
 
/*-------------------------------------------------------------------*/
SYNTAX:                                /*@                           */
   errormsg = "REXX error" rc "in line" sigl":" errortext(rc)
   say errormsg
   say sourceline(sigl)
   Trace "?R"
   nop
exit                                   /*@ SYNTAX                    */
 
/*    Work area for creating new patterns:                           */
 
/*      .......                                                      */
/*      .......                                                      */
/*      .......                                                      */
/*      .......                                                      */
/*      .......                                                      */
/*      .......                                                      */
/*      .......                                                      */
/*      .......                                                      */
/*      .......                                                      */
 
