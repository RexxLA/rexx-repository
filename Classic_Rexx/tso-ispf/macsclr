/* macsclr  rexx exec -- gm 2002/03/06                                */
/*                                                                    */
/* added ISPEXEC CONTROL REFRESH around browse            gm 02/03/27 */
/*                                                                    */
/*================================================== start of HELP ===*/
/* MACSCLR interfaces users with a Compile & Linkedit Repository of   */
/*   listings for transmitted and cleared routines.  User is able to  */
/*   view listings or copy to a dataset for subsequent viewing,       */
/*   editing, and/or printing.                                        */
/*                                                                    */
/* Execute as: MACSCLR                          (H/? for this help)   */
/*                                                                    */
/* After about 20 seconds a list of all routines transmitted since    */
/*   November 26, 2001 will be presented with the following info:     */
/* ITEM  -MEMBER-  TYPE  A.R.BASE  -USERID-  YYYY/MM/DD HH:MM  LIBTYPE*/
/*    1  AATYZ94    PR   AATYZ     CUSXYZ    2002/01/08 14:05  LINKLIB*/
/*    2  ....       ..   ..        ...       .......    ..     ..     */
/*                                                                    */
/*   where ITEM       -- arbitrary number used by various list options*/
/*         MEMBER     -- name assigned to Compile & Linkedit listing  */
/*         TYPE       -- suffix of the Panvalet full 10 character name*/
/*         A.R.BASE   -- Application Repository Base name             */
/*         USERID     -- user ID of routine transmitter               */
/*         YYY...:MM  -- date & time transmittal occurred             */
/*         LIBTYPE    -- llq of the executable library nnnn.xx.llq    */
/*                                                                    */
/* Options available for the list are:                                */
/*                                                                    */
/*     N or null   -- show Next group of items in display window      */
/*     P           -- show Previous group of items in display window  */
/*     T           -- show Top group of items in display window       */
/*     E           -- show End group of items in display window       */
/*     <item #>    -- make item # first line in display window        */
/*     R <mem>     -- Restrict list to members starting with mem      */
/*     B <item #>  -- Browse item # from display window               */
/*     C <item #>  -- Copy item # from display window to dataset ...  */
/*                       your-userid.@@.MACSCLR.COMPLINK.REPORT.member*/
/*     H or ?      -- Help for application                            */
/*     Q           -- Quit further processing                         */
/*                                                                    */
/* Not all members displayed in the list may still be online as       */
/*   periodically the actual online members are compared with the     */
/*   latest cleared version for the Application Repository Base Name  */
/*   and older online members are deleted.  In this case, using a more*/
/*   recent version should result in a match with an online member.   */
/*                                                                    */
/* Any members deleted due to more recent versions available will have*/
/*   a backup of the Compile & Linkedit listing saved for 10 years    */
/*   from the date transmitted.  Contact the Help Desk if you REALLY  */
/*   need to access one of these offline members.                     */
/*                                                                    */
/* TYPE suffix codes are:                                             */
/*      BR -- BAL routine                PR -- PL/I routine           */
/*      BS -- BAL subroutine             PS -- PL/I subroutine        */
/*      BV -- BAL CICS map               PT -- PL/I CICS routine      */
/*      GR -- Easytrieve routine                                      */
/*                                                                    */
/* Any informational or error messages will appear on the blank line  */
/*   between the item list and the available options in the form      */
/*         ######## message text ########                             */
/*==================================================== end of HELP ===*/
 
ARG ALLDATA                              /* setup function parameters */
PARSE SOURCE . ETYPE EFN EFT EFM .       /* extract exec info         */
ADDRESS TSO                              /* limit command resolution  */
 
/*  set up exec variables ...                                         */
 
FILEINDSN = "ACN1.PR.D292.MACS.COMPLINK.INDEX"
INDD = "I"TIME(S)SUBSTR(DATE(S),7,2)
outdd1 = overlay("T",indd,1)
outdd2 = overlay("U",indd,1)
userlog1 = substr(date(s),1,2)date(o) time() ...0 left(userid(),8)
userlogstart = date(c) time(m)
userlogdd = overlay("L",indd,1)
userlogdsn = "ACN1.PR.D292.MACS.ULOGCLR.ACTIVITY"
 
/*  check for help starting application ...                           */
 
basetime = time(s)
"clear"
IF FIND("? H",WORD(ALLDATA,1)) > 0
   THEN DO
           call helpinfo
           EXIT
        END
 
/* check for GM undocumented option ... (used for testing)            */
 
PP = FIND(ALLDATA,"GM")
IF PP > 0
   THEN DO
           SAY "%%%%%% testing for GM in progress %%%%%%"
           ALLDATA = DELWORD(ALLDATA,PP,1)
           FILEINDSN = "ACN1.PR.D292.MACS.COMPLINK.INDEX.TESTGM"
        END
 
/*  determine if TEST option is selected ...                          */
 
TEST = "NO"
PP = FIND(ALLDATA,"TEST")
IF PP > 0
   THEN DO
           SAY "++++ 'TEST' option in effect ++++"
           SAY
           TEST = "YES"
           ALLDATA = DELWORD(ALLDATA,PP,1)
        END
 
/*  check for availability of index dataset ...                       */
 
TEMP = SYSDSN("'"FILEINDSN"'")
IF TEMP ^= "OK"
   then do
           say "unable to access INDEX dataset -- try later"
           call checktest "###0 INDEX temp=" temp
           exit
        end
 
   if test ^= "YES"             /* for message suppression */
      then do
              suppressmsg. = ""
              suppressmsg.0 = 0
              temprc = outtrap("suppressmsg.")
           end
 
"free dataset('"FILEINDSN"')"
 
"ALLOCATE DATASET('"FILEINDSN"') FILE("INDD") SHR"
allocrc = rc
 
temprc = outtrap("OFF")  /* message suppression off */
 
IF allocrc ^= "0"
   THEN DO
           SAY "#### problem allocating INDEX dataset"
           call checktest "###1 INDEX rc=" allocrc
           exit
        END
 
call checktest "###2 INDEX=" fileindsn
"clear"
say overlay(efn "setup ...",right(time(),79),1)
say
IF TEST = "YES" THEN SAY "++++ 'TEST' option in effect ++++"
say
say "Preparing data for a list of possible Compile" ,
      "listing members"
say
say "   ... can take up to 20 seconds ... Please be patient ..."
 
"EXECIO * DISKR" INDD "(FINIS STEM INDEXIN."
"FREE FILE("INDD")"
 
call sortindex
 
call buildlist "*"
 
call checktest "###3 ready for list screen"
 
/*  present and process display window ...                            */
 
ii = 1; screenitems = 10; infomess = ""
do forever            /* start display window */
   "clear"
   startii = ii; endii = ii
   duration = time(s) - basetime
   call headings
   line3 = right("Entries" ,
                   startii"-"min((startii + screenitems),listdata.0) ,
                   "of" listdata.0,79)
   line3 = overlay(contents,line3,1,30)
   say line3
   say "ITEM  -MEMBER-  TYPE  A.R.BASE  -USERID-  YYYY/MM/DD HH:MM " ,
         "LIBTYPE"
   do jj = 1 to screenitems
      ii = startii + jj - 1
      if ii <= listdata.0
         then do
                 say right(ii,4)" " ,
                       left(word(listdata.ii,05),10) ,
                       left(word(listdata.ii,07),04) ,
                       left(word(listdata.ii,04),09) ,
                       left(word(listdata.ii,03),09) ,
                       left(word(listdata.ii,01),10) ,
                       left(word(listdata.ii,02),06) ,
                       left(word(listdata.ii,09),08)
                 endii = ii
              end
 
         else say
 
   end
 
   if infomess = ""
      then say
      else say center(" "infomess" ",79,"#")
 
   say "Use following keys and hit ENTER to move around the item list:"
   say "   N or null -- Next; P -- Previous; T -- Top; E -- End;" ,
          "<item #> to first line"
   say "Enter B <item #> to Browse item:" ,
          "C <item #> to Copy item to a dataset"
   say "Other options: H/? -- Help; Q -- Quit; R <mem> -- Restrict" ,
          "list to members mem*"
 
   say
   pull dowhat towhat .
 
   basetime = time(s)
   ii = startii
   infomess = ""
   select             /* process user option */
      when dowhat = "" | dowhat = "N"
         then do
                 ii = startii + screenitems - 1
                 if ii > listdata.0 then ii = listdata.0
              end
 
      when dowhat = "P"
         then do
                 ii = startii - screenitems + 1
                 if ii < 1 then ii = 1
              end
 
      when dowhat = "T"
         then do
                 ii = 1
              end
 
      when dowhat = "E"
         then do
                 ii = listdata.0 - screenitems + 1
                 if ii < 1 then ii = 1
              end
 
      when dowhat = "Q"
         then do
                 leave
              end
 
      when find("? H",dowhat) > 0
         then do
                 "clear"
                 call helpinfo
                 say
                 say "hit ENTER to return to the list of members ..."
                 pull .
                 "clear"
              end
 
      when dowhat = "R"
         then do
                 "clear"
                 call buildlist towhat
                 userloga = left("; R" towhat,17)
                 userlog1 = userlog1 userloga
                 ii = 1
                 "clear"
              end
 
      when find("B C",dowhat) > 0
         then do
                 "clear"
                 if towhat >= startii & towhat <= endii & ,
                       datatype(towhat,"w") = 1
                    then do
                            member = "???"; pdsllq = "??"
                            call processmember
                            userloga = left(";" dowhat left(member,8) ,
                                                left(pdsllq,4),17)
                            userlog1 = userlog1 userloga
                         end
 
                    else do
                            infomess = dowhat towhat "option not in" ,
                                         "display window range"
                         end
 
                 "clear"
              end
 
      when datatype(dowhat,"w") = 1
         then do
                 if dowhat > 0 & dowhat <= listdata.0
                    then ii = dowhat
              end
 
      otherwise do
                   infomess = dowhat "option is not valid --" ,
                                     "try again!!!"
                end
 
   end   /* select */
 
 
end                   /* end display window */
 
call doneall
 
exit
/*====================================================================*/
/*== subroutine to handle exiting from exec ==========================*/
doneall:
 
   "clear"
 
   userlogmins = 1440 * (date(c) - word(userlogstart,1)) ,
                      + time(m) - word(userlogstart,2)
   userlog1 = overlay(right(userlogmins,4),userlog1,21)
 
   if test ^= "YES"             /* for message suppression */
      then do
              suppressmsg. = ""
              suppressmsg.0 = 0
              temprc = outtrap("suppressmsg.")
           end
 
/*    find available logging dataset ...                              */
 
   do uu = 1 to 9
      "allocate dataset('"userlogdsn"') file("userlogdd") mod"
      if rc = 0
         then do
                 "EXECIO 1 DISKW" userlogdd "(FINIS stem userlog"
                 leave
              end
 
      userlogdsn = overlay(uu,userlogdsn,length(userlogdsn),1)
   end
 
   "free file("userlogdd")"
 
   temprc = outtrap("OFF")  /* message suppression off */
 
   call checktest "###L logging user activity"
 
   "clear"
 
   EXIT
 
RETURN
/*====================================================================*/
/*== subroutine to handle headings for display window ================*/
headings:
 
   head1 = "M.A.C.S.  COMPILE  LISTING  REPOSITORY"
   head2 = copies("=",length(head1))
   head1 = center(head1,79)
   head2 = center(head2,79)
   head1 = overlay(left(efn,8,"0"),head1,1)
   head1 = overlay(right(duration,5),head1,75)
   say head1
   say head2
 
return
/*====================================================================*/
/*== subroutine to handle display help information ===================*/
helpinfo:
 
   say efn "Help function ... at '***' hit ENTER to continue ..."
   say
   SAY center(" H E L P   R E Q U E S T   I N F O ",68,"+")
   hhh = 3
   startnow = ""
   do hh = 1 to sourceline()
      if pos("start of HELP",sourceline(hh)) > 0
         then do
                 startnow = "yes"
                 iterate
              end
 
      if startnow = "" then iterate
      if substr(sourceline(hh),1,2) ^= "/*" then leave
      say substr(reverse(substr(reverse(strip(sourceline(hh),,
                                              "t")),3)),3)
      hhh = hhh + 1
   end
 
   if dowhat = "H"
      then do
              hhh = hhh + 2
              if hhh // 23 = 0 then say
           end
 
return
/*====================================================================*/
/*== subroutine to handle removing dups and sorting index file data ==*/
sortindex:
 
   indata. = ""
   do ii = 1 to indexin.0
      if datatype(substr(indexin.ii,1,4),"w") = 0 then iterate
      mempds = left(word(indexin.ii,05),08,"-")word(indexin.ii,07)
      datime = space(subword(indexin.ii,01,02),0)
      if find(indata.zzzzzzzzz,mempds) = 0
         then indata.zzzzzzzzz = indata.zzzzzzzzz mempds
      if datime > indata.mempds.zzzzzzzzz
         then indata.mempds.zzzzzzzzz = datime
 
      indata.mempds.datime = ii
   end
 
   ii = 0
   indata.zzzzzzzzz = RUFSORTL(indata.zzzzzzzzz)
   do jj = 1 to words(indata.zzzzzzzzz)
      mempds = word(indata.zzzzzzzzz,jj)
      datime = indata.mempds.zzzzzzzzz
      ii = ii + 1
      kk = indata.mempds.datime
      indata.ii = indexin.kk
   end
 
   indata.0 = ii
 
return
/*====================================================================*/
/*== subroutine to handle set up for the sorted index data ===========*/
buildlist:
 
   arg selector .
   if selector = "*" then selector = ""
   listdata. = ""; jj = 0
   listdata.1 = "try again selected members <<<< . no . >>>>"
   do ii = 1 to indata.0
      if abbrev(word(indata.ii,05),selector) = 1 | selector = ""
         then do
                 jj = jj + 1
                 listdata.jj = indata.ii
              end
 
   end
 
   listdata.0 = max(1,jj)
   if selector = ""
      then contents = ""
      else if word(listdata.1,1) = "try"
              then do
                      contents = "("indata.0 - listdata.0 + 1 ,
                                    "entries hidden)"
                      infomess = dowhat towhat "option yielded" ,
                                               "no items to display"
                   end
 
              else do
                      contents = "("indata.0 - listdata.0 ,
                                    "entries hidden)"
                      infomess = dowhat towhat "option yielded" ,
                                               listdata.0 "items"
                   end
 
return
/*====================================================================*/
/*== subroutine to handle processing for browse and copy options =====*/
processmember:
 
   member = word(listdata.towhat,05)
   pdsllq = word(listdata.towhat,07)
   selected = "ACN1.PR.D292.MACS.COMPLINK."pdsllq
   userdsn  = userid()".@@."efn".COMPLINK.REPORT."member
   temp = sysdsn("'"selected"("member")'")
   if temp ^= "OK"
      then do
              infomess = dowhat towhat "option" member ,
                                "no longer online --" ,
                                "try a more recent version"
              pdsllq = pdsllq"??"
              call checktest "###4 temp=" temp
              return
           end
 
   if test ^= "YES"             /* for message suppression */
      then do
              suppressmsg. = ""
              suppressmsg.0 = 0
              temprc = outtrap("suppressmsg.")
           end
 
   "free dataset('"selected"')"
   "free dataset('"userdsn"')"
 
   temprc = outtrap("OFF")  /* message suppression off */
 
   call checktest "###5 freeing datasets"
   "clear"
 
   select
      when dowhat = "B"
         then do
                 selectmember = selected"("member")"
                 "ISPEXEC CONTROL DISPLAY REFRESH"
                 "ISPEXEC BROWSE DATASET('"selectmember"')"
                 "ISPEXEC CONTROL DISPLAY REFRESH"
                 infomess = dowhat towhat "option browsed listing" ,
                               member
                 call checktest "###6 after browse"
              end
 
      when dowhat = "C"
         then do
                 say efn "Copy function for" member "..."; say
                 temp = sysdsn("'"userdsn"'")
                 call checktest "###7 copy userdsn temp=" temp
                 if temp = "OK"
                    then do
                            say "output dataset" userdsn "exists ..."
                            say "   ... hit ENTER to replace or" ,
                                           "N to terminate copy"
                            say
                            pull whatnow .
                            basetime = time(s)
                            if whatnow = ""
                               then "delete '"userdsn"' purge"
                               else do
                                       infomess = dowhat towhat ,
                                                    "option" ,
                                                    "terminated" ,
                                                    "as requested"
                                       pdsllq = pdsllq"??"
                                       return
                                    end
 
                            call checktest "###8 copy userdsn delete"
                         end
 
                 say
                 say "... please wait for copy function to complete" ,
                          "and return to the member list"
                 "allocate dataset('"selected"') file("outdd1") shr"
 
                 "allocate dataset('"userdsn"') file("outdd2")" ,
                           "dataclas(dckfblar) new" ,
                           "lrecl(137) recfm(v b a)"
 
                 "ispexec lminit dataid(goodone) ddname("outdd1")"
                 "ispexec lminit dataid(goodtwo) ddname("outdd2")"
 
                 "ispexec lmcopy fromid("goodone") frommem("member")" ,
                                "todataid("goodtwo") replace"
                 infomess = dowhat towhat "option created" userdsn
 
                 "free file("outdd1")"
                 "free file("outdd2")"
                 call checktest "###9 after copy"
              end
 
      otherwise nop
   end          /* select */
 
return
/*====================================================================*/
/*== subroutine to handle exec pauses and data display for testing ===*/
checktest:
 
   arg output
 
   if test = "YES"
      then do
              say output
              say "#### in TEST mode -- hit ENTER to continue"
              pull .
           end
 
return
/*====================================================================*/
