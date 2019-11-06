* PROCESS LANGLVL(SPROG);
 whoyou: proc options(main);
 
        jobname  = jobnm ;
        jobnumbr = job#  ;
        sysname  = sysnm ;
        cputag   = cpuid ;
        namlenovly.b2 = unaml;
        username = Substr(unamdata,1,namlen-1);
 
        put data(jobname, jobnumbr,
                 username,
                 sysname, cputag) ;
 
        /* --------- Declares below this point ------------- */
        dcl   jobname        char(008)
             ,jobnumbr       char(008)
             ,sysname        char(008)
             ,cputag         char(004)
             ,username       char(128) var
        ;          /* ---------------------------- */
        dcl tcbptr           pointer based(pointervalue(540)) ;
        dcl 1 tcb       based(tcbptr)
            ,2 tcbx1         char(012)
            ,2 tiotptr       pointer
            ,2 tcbx2         char(164)
            ,2 jscbptr       pointer
        ;
        dcl 1 tiot      based(tiotptr)
            ,2 jobnm         char(008)
        ;
        dcl 1 jscb      based(jscbptr)
            ,2 jscbx1        char(316)
            ,2 ssibptr       pointer
        ;
        dcl 1 ssib      based(ssibptr)
            ,2 ssibx1        char(12)
            ,2 job#          char(008)
        ;          /* ---------------------------- */
        dcl cvtptr           pointer based(pointervalue(16)) ;
        dcl 1 cvt       based(cvtptr)
            ,2 cvtx1         char(196)
            ,2 smcaptr       pointer
            ,2 cvtx2         char(140)
            ,2 sysnm         char(008)
        ;
        dcl 1 smca      based(smcaptr)
            ,2 smcax1        char(16)
            ,2 cpuid         char(004)
        ;          /* ---------------------------- */
        dcl ascbptr          pointer based(pointervalue(548)) ;
        dcl 1 ascb      based(ascbptr)
            ,2 ascbx1        char(108)
            ,2 ascbasxb      pointer
        ;
        dcl 1 asxb      based(ascbasxb)
            ,2 asxbx1        char(200)
            ,2 asxbsenv      pointer
        ;
        dcl 1 senv      based(asxbsenv)
            ,2 senvx1        char(100)
            ,2 aceeunam      pointer
        ;
        dcl 1 acee      based(aceeunam)
            ,2 unaml         char(001)
            ,2 unamdata      char(064)
        ;
        dcl  fb31   bin fixed(31) init(0);
        dcl  namlen bin fixed(15) init(0);
        dcl 1 namlenovly based(addr(namlen))
            ,2 b1 char(1)
            ,2 b2 char(1)
        ;
        dcl   sysprint file stream output print;
        dcl  (addr
             ,substr
             ,pointervalue)            builtin ;
        end;
