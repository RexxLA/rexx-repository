 say "Not meant to run, just illustrate checking syntax of a big one."
 exit
/*************************************************************************/
/* Licensed Materials - Property of IBM                                  */
/*                                                                       */
/* XXXX-XXX                                                              */
/*                                                                       */
/* (C) Copyright IBM Corp. 1995.  All Rights Reserved.                   */
/*                                                                       */
/* US Government Users Restricted - Use, duplication, or                 */
/* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.     */
/*                                                                       */
/*************************************************************************/
exit
parse ARG client logfile additional

QUEUE_REBOOT = 0
CALL_AGAIN = 0

Call AddDLLFunctions

x.0.instprog = ''
x.0.rspdir   = ''
x.0.statevar = 'CAS_STATE'
x.0.default  = ''

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* Start Drive Variables section */
CD_Drive = "G:"
bootdrive = "F:"
MPTS_Drive = "F:"
ibminstdrive = "F:"
products_to_install = " MPTS "
integrate = "1"
Deltasize = "MPTS:8915093 F WARP:0 F"
rmv_nb = 0
WCTune = 0
nwexists = 0
addcallcrtuidp = 0
/* End Drive Variables section */

rc = value('NEWCDDRIVE',,'OS2ENVIRONMENT')
if rc <> '' then
   CD_Drive = strip(rc)

msgfile = 'NPINST.MSG'
ibminstdir = ibminstdrive'\IBMINST'
ciddir = CD_Drive'\CID'
locdir = ibminstdrive'\CID'
cltdir = ibminstdir'\RSP\'client
dllpath = ciddir'\DLL\OS2;'locdir'\LOCINSTU;'cltdir';'
exepath = ciddir'\EXE\OS2'
logsdir = ibminstdir'\LOGS'
configsys = bootdrive'\CONFIG.SYS'
cidimgdir = CD_Drive'\CID\IMG'
percentfile = bootdrive'\wspcnt.cpt'
reboot_this_time = 0
percent_complete = 0

/* Determine if we're local or remote */
if strip(translate(CD_Drive)) = 'Z:' then
   remote = 1
else
   remote = 0

/* Set the beginlibpath to pick up the right DLL's */
blpvalue = value('BEGINLIBPATH',, 'OS2ENVIRONMENT')

if blpvalue \= '' then
   if right(blpvalue,1) \= ';' then
      blpvalue = blpvalue || ';'

ok = value('BEGINLIBPATH',blpvalue || ibminstdir || ';','OS2ENVIRONMENT')

'@SET BEGINLIBPATH=' || ibminstdir || ';' || locdir'\LOCINSTU;'

call SysMkDir bootdrive'\OS2\INSTALL\IBMINST'

call cas_setup

OVERALL_STATE = GetEnvironmentVars()

products.0 = 0

/* Call the progress indicator */
if OVERALL_STATE = 0 then do
   '@'ibminstdir'\ISHIELD.EXE /U 1>nul 2>nul'
   '@'ibminstdir'\WRAPPER.EXE 1>nul 2>nul'
   '@call 'ibminstdir'\callprog 'ibminstdir
end


/* Determine if reboot is needed */
if pos('MPTS', products_to_install) > 0 then do
   bootfile = cltdir'\REBOOT.FIL'
   if stream(bootfile, 'C', 'QUERY EXISTS') \= '' then do
      call SysFileDelete bootfile
      reboot_this_time = 0
   end
   else reboot_this_time = 1
end /* do */


Do Forever
  Select
    when OVERALL_STATE = 0 then do

      /* Call connection to progress indicator */
      call progress_setup

      inst_product = 'MPTS'
      call progress_change inst_product

      /* Wait for Workplace shell to come up before we do anything */
      rc = SysIni('USER', 'PM_InstallObject', 'ALL:', 'stem')
      do while rc \= 'ERROR:'
         call SysSleep 2
         rc = SysIni('USER', 'PM_InstallObject', 'ALL:', 'stem')
      end
      drop rc

      /* Check for locked files */
      'call 'ibminstdir'\Chklanlk' bootdrive' 'CD_Drive
      if nwexists then do
         call RunInstall x.rmvnw
         /* npnwinst (i.e., x.rmvnw) also removes ODI2NDI from the protocol.ini */
      end

      /* Check for locked files */
      'call 'ibminstdir'\Chklanlk' bootdrive' 'CD_Drive

      if pos('MPTS', products_to_install) > 0 then do
         if RunInstall(x.mpts) == BAD_RC then
            call kill_install

         /* If we are in a remote install, we need to add laps and thinifs */
         if remote then do
            run_instlaps = 'cmd.exe /c '||ibminstdir||'\INSTLAPS.CMD '||left(bootdrive,1)
            run_instlaps
            if stream('W:\USER.CMD', 'C', 'QUERY EXISTS') \= '' then do
               'copy w:\user.cmd 'cltdir
            end
         end

         'call 'ibminstdir'\Chklanlk' bootdrive' 'CD_Drive

      end /* do */

      /* Copy for unsupported adapters */
        call SysFileTree ibminstdir'\TABLES\IBMCOM\*.*', 'nifs', 'FOS'

      if nifs.0 > 0 then do
        '@xcopy 'ibminstdir'\TABLES\IBMCOM\* 'MPTS_Drive'\IBMCOM\ /S /E 1>nul 2>nul'
        do jj = 1 to nifs.0
           call SysFileDelete nifs.jj
        end
        call SysRmDir ibminstdir'\TABLES\IBMCOM\PROTOCOL'
        call SysRmDir ibminstdir'\TABLES\IBMCOM\MACS'
        call SysRmDir ibminstdir'\TABLES\IBMCOM\DLL'
        call SysRmDir ibminstdir'\TABLES\IBMCOM'
      end

      /* Copy over MPTS pubs */
      '@copy 'cidimgdir'\books\dhcpclnt.inf 'bootdrive'\os2\book 1>nul 2>nul'
      '@copy 'cidimgdir'\books\dipintr.inf 'bootdrive'\os2\book 1>nul 2>nul'
      '@copy 'cidimgdir'\books\mptscfg.inf 'bootdrive'\os2\book  1>nul 2>nul'

      /* Install FFST */
      if pos('FFST', products_to_install) > 0 then do
         inst_product = 'FFST'
         call progress_change inst_product
         '@call 'cltdir'\instffst.cmd'
      end /* do */

      if integrate then do
         /* Keep ARCINST and TUTORIAL from running at phase 3 */
         rc = SysIni(bootdrive || '\os2\os2.ini', 'PM_Workplace:InstallAutorun', 'OS/2 Warp Tutorial', '')
         rc = SysIni(bootdrive || '\os2\os2.ini', 'PM_RunInstallProgram', '\os2\arcinst.exe', '')

      end

      if reboot_this_time then do
         /* Reset IBMLANLK files */
         'call 'ibminstdir'\rstlanlk' bootdrive' 'CD_Drive' 'OVERALL_STATE
      end

      /* Increment the state to prepare for the reboot */
      rc = SetState(OVERALL_STATE+1)

      /* Save the environmental variables */
      Call SaveStates

      if reboot_this_time then do

         /* Let the progress indicator reboot.  If it can't do it in 30 seconds,
          then we'll reboot */
         call SysSleep 20
         rc = ProgressReboot()
         if rc = 0 then do
            sleepcnt = 0
            do until rc = 1 | sleepcnt > 3
               sleepcnt = sleepcnt + 1
               call SysSleep 60
               rc = ProgressReboot()
            end
         end

         /* If it still didn't do it, reboot */
         if rc = 0 then call Reboot
         /* If it says it did, but lied, give it 3 minutes, then reboot */
         else do
            call SysSleep 180
            call Reboot
         end
      end /* If reboot_this_time */

   End /* When State 0 */

   when OVERALL_STATE = 1 then do

      /* Wait for Workplace shell to come up before we do anything */
      rc = SysIni('USER', 'PM_InstallObject', 'ALL:', 'stem')
      do while rc \= 'ERROR:'
         call SysSleep 2
         rc = SysIni('USER', 'PM_InstallObject', 'ALL:', 'stem')
      end
      drop rc

      /* Call connection to progress indicator. */
      call progress_setup

      if pos('SVAGENT', products_to_install) >0 then do
         inst_product = 'SVAGENT'
         call progress_change inst_product
         call Directory cidimgdir'\SVAGENT'
         if RunInstall(x.svagent) = BAD_RC then
           x.svagent.bad = 1
         call Directory ibminstdir
         'call 'ibminstdir'\Chklanlk' bootdrive' 'CD_Drive
      end /* do */

      if pos('NW', products_to_install) > 0 then do
         inst_product = 'NW'
         call progress_change inst_product
         if RunInstall(x.nwinst) = BAD_RC then
           x.nwinst.bad = 1
         if RunInstall(x.nwaddress) = BAD_RC then
           x.nwinst.bad = 1
         if RunInstall(x.nwmpts) = BAD_RC then
           x.nwinst.bad = 1
      end

      if pos('MFS', products_to_install) > 0 then do
         inst_product = 'MFS'
         call progress_change inst_product
         if RunInstall(x.mfs) = BAD_RC then
            x.mfs.bad = 1
      end

      if pos('OS2PEER', products_to_install) > 0 then do
         inst_product = 'OS2PEER'
         call progress_change inst_product
         if RunInstall(x.os2peer) == BAD_RC then
            x.os2peer.bad = 1

         'call 'ibminstdir'\Chklanlk' bootdrive' 'CD_Drive

      end /* do */

      if pos('NSC', products_to_install) > 0 then do
         inst_product = 'NSC'
         call progress_change inst_product
         call Directory cidimgdir'\NSC'
         if RunInstall(x.nsc) = BAD_RC then
            x.nsc.bad = 1
         call Directory ibminstdir
      end /* do */

      if pos('TCPIP', products_to_install) > 0 then do
         inst_product = 'TCPIP'
         call progress_change inst_product
         if RunInstall(x.tcpapps) = BAD_RC then
            x.tcpapps.bad = 1
         else
            /* defect 39524 */
            rc = SysIni(bootdrive || '\os2\os2.ini', 'CoachEnabled', bootdrive || '\TCPIP\BIN\EXPLORE.EXE', '1')

         'call 'ibminstdir'\Chklanlk' bootdrive' 'CD_Drive
      end /* do */

      if pos('LDR', products_to_install) > 0 then do
         inst_product = 'LDR'
         call progress_change inst_product
         if RunInstall(x.ldr) = BAD_RC then
            x.ldr.bad = 1
         else do
            /* Copy over LDR pubs */
            '@copy 'cidimgdir'\books\a9m04mst.inf 'bootdrive'\os2\book 1>nul 2>nul'
            '@copy 'cidimgdir'\books\a3t12mst.inf 'bootdrive'\os2\book 1>nul 2>nul'
         end
         'call 'ibminstdir'\Chklanlk' bootdrive' 'CD_Drive
      end /* do */

      if pos('NETFIN', products_to_install) > 0 then do

         inst_product = 'NETFIN'
         call progress_change inst_product

         call directory cidimgdir'\NETFIN'
         if RunInstall(x.netfin) = BAD_RC then
            x.netfin.bad = 1
         call Directory ibminstdir
         '@call 'ibminstdir'\Chklanlk' bootdrive' 'CD_Drive

         /* Copy NetFinity on-line guide */
         '@copy 'cidimgdir'\books\services.inf 'bootdrive'\os2\book  1>nul 2>nul'

      end

      /* If we need to remove NetBEUI, then do it */
      if rmv_nb then do
        '@'MPTS_Drive'\ibmcom\mpts  ',
                 ' /e:prod  ',
                 ' /s:'cidimgdir'\mpts  ',
                ' /t:' || MPTS_Drive || '\  ',
                ' /tu:' || bootdrive || '\ ',
                 ' /l1:'logsdir'\mpts\'client'.rmv',
                 ' /r:'cltdir'\RMVNB.RSP'
      end /* do */

      call Directory ibminstdir

      /* Run NPTUNE if we need to */
      if WCTune = 1 then
         '@call NPTUNENB.EXE /Q'

      /* Delete CAS stuff */
      call RunInstall x.casdelet

      /* Reset IBMLANLK files */
      'call 'ibminstdir'\rstlanlk' bootdrive' 'CD_Drive' 'OVERALL_STATE

      /* Add call to create userid and password */
      /* Only run this if we just installed Peer */
      if pos('OS2PEER', products_to_install) > 0 then do

         startupfil = bootdrive'\startup.cmd'

         i = 0
         crtuidpAdded = 0

         do while lines(startupfil) > 0
            i = i + 1
            strt.i = linein(startupfil)

            /* If we need to add the call to create uid and passwd, then do it */
            if pos('\LSERR.EXE',translate(strt.i)) >0 then do
               i = i + 1
               strt.i = 'detach' ibminstdir'\crtuidp'
               crtuidpAdded = 1
            end /* do */

         end /* do */

         call stream startupfil, 'C', 'CLOSE'

         /* Delete the old one */
         call SysFileDelete(startupfil)

         /* if LS was not already in the startup.cmd append call to the beginning */
         if crtuidpAdded = 0 then do
            call lineout startupfil, 'detach' ibminstdir'\crtuidp'
            crtuidpAdded = 1
         end /* do */

         /* Re-write the startup file */
         do j = 1 to i
            call lineout startupfil, strt.j
         end
         call stream startupfil, 'C', 'CLOSE'

      end /* call to CRTUIDP */

      if integrate then do

         /* Have arcinst re-run if we're in an integrated install. */
         /* Put ARCINST.EXE back in the OS2.INI file */
         call SysIni "USER", "PM_RunInstallProgram", "\os2\arcinst.exe", "0"

         /* Put welcome.exe in Startup folder */
         classname = 'WPProgram'
         Title = 'welcome.exe'
         Location = '<WP_START>'
         Setup = 'OBJECTID=<WP_WELCOME>;EXENAME=\OS2\WELCOME.EXE;STARTUPDIR=\OS2'
         result=SysCreateObject(classname,Title,Location,Setup)

      end

      /* Cleanup srvifs */
      if remote then
         call RunInstall x.ifsdel

      /* Tell progress indicator we're done */
      call ProgressCompleted

      /* Clean up CAS, etc. */
      '@call npclean 'bootdrive

      /* Arrange the desktop objects  */
      '@call clndesk deskobj.rem tables\npconfig.cfg'

      /* Write the installed products file */
      call write_inst_prod

      /* Call the user.cmd if there is one */
      if stream(cltdir'\USER.CMD', 'C', 'QUERY EXISTS') \= '' then do
         '@call 'cltdir'\USER.CMD'
      end

      /* Let the progress indicator reboot.  If it can't do it in 30 seconds,
          then we'll reboot just as a backup.  */
      call SysSleep 20
      rc = ProgressReboot()
      if rc = 0 then do
         sleepcnt = 0
         do until rc = 1 | sleepcnt > 3
            sleepcnt = sleepcnt + 1
            call SysSleep 60
            rc = ProgressReboot()
         end
      end

      /* If it still didn't do it, reboot */
      if rc = 0 then call Reboot
      /* If it says it did, but lied, give it 3 minutes, then reboot */
      else do
         call SysSleep 180
         call Reboot
      end

      /* Keep this reboot only as backup once */
      call Reboot                                        /* Reboot           */

    End /* When State 1 */
  End /* Select */
End /* Do Forever */

cas_setup:

x.casdelet = 1
x.1.name='LAN CID Utility Delete'
x.1.statevar = ''
x.1.instprog = locdir'\locinstu\casdelet   ',
               ' /tu:' || bootdrive,
               ' /pl:' || dllpath || '   '
x.1.rspdir   = ''
x.1.default  = ''

x.ifsdel = 2
x.2.name='SRVIFS Delete'
x.2.statevar = ''
x.2.instprog = 'z:\cid\srvifs\ifsdel     ',
               ' /t:' || bootdrive || '\srvifsrq ',
               ' /tu:' || bootdrive
x.2.rspdir   = ''
x.2.default  = ''

x.mpts = 3
x.3.name='MPTS'
x.3.statevar = 'CAS_' || x.3.name
x.3.instprog = cidimgdir'\mpts\mpts  ',
                 ' /e:prod  ',
                 ' /s:'cidimgdir'\mpts  ',
                ' /t:' || MPTS_Drive || '\  ',
                ' /tu:' || bootdrive || '\ ',
                 ' /l1:'logsdir'\mpts\'client'.mpt',
                 ' /r:'
x.3.rspdir   = cltdir'\'
x.3.default  = 'mpts.rsp'

x.os2peer =4
x.4.name='OS/2 Peer'
x.4.statevar = 'CAS_' || x.4.name
x.4.instprog = cidimgdir'\ibmpeer\peerrmt   ',
               '/l1:'logsdir'\os2peer\'client'.ins  ',
               '/CONNECT ',
               '/r:'
x.4.rspdir = cltdir'\'
x.4.default = 'os2peer.rsp'

x.nsc = 5
x.5.name='NSC'
x.5.statevar = 'CAS_' || x.5.name
x.5.instprog = cidimgdir'\nsc\install.exe ',
                 ' /a:' || nsc_instupdt,
                 ' /x',
                 ' /l1:'logsdir'\nsc\'client'.log ',
                 ' /l2:'logsdir'\nsc\'client'.hst ',
                 ' /s:'cidimgdir'\nsc ',
               '/r:'
x.5.rspdir   = cltdir'\'
x.5.default  = 'nsc.rsp'

x.tcpapps = 6
x.6.name = 'TCP/IP Applications'
x.6.statevar = 'CAS_' || x.6.name
x.6.instprog = cidimgdir'\tcpapps\install /b- ',
                 ' /s:'cidimgdir'\tcpapps         ',
                 ' /l1:'logsdir'\tcpapps\'client'.tcp',
                 ' /r:'
x.6.rspdir = cltdir'\'
x.6.default = 'tcpapps.rsp'

x.nwinst = 7
x.7.name = 'NetWare Requester'
x.7.statevar = 'CAS_' || x.7.name
x.7.instprog = ibminstdir'\npnwinst ',
               '/L1:'logsdir'\nwreq\'client'.hst ',
               '/L2:'logsdir'\nwreq\'client'.err ',
               '/NC:'nwcontext' ',
               '/P:'nwprefsrv' ',
               '/T:'nwtgtpath' ',
               '/V:'nwversion' ',
               '/TR:'nwtokenring' ',
               '/S:'left(cidimgdir,1)
x.7.rspdir = ''
x.7.default = ''

x.nwmpts = 8
x.8.name='MPTS for NetWare'
x.8.statevar = 'CAS_' || x.8.name
x.8.instprog = cidimgdir'\mpts\mpts  ',
                 ' /e:prod  ',
                 ' /s:'cidimgdir'\mpts  ',
                 ' /t:' || MPTS_Drive || '\  ',
                 ' /tu:' || bootdrive || '\ ',
                 ' /l1:'logsdir'\mpts\'client'.nwr',
                 ' /r:'
x.8.rspdir   = cltdir'\'
x.8.default  = 'nwmpts.rsp'

x.nwaddress = 9
x.9.name='Add ODI2NDI Address'
x.9.statevar = 'CAS_' || x.9.name
x.9.instprog = ibminstdir'\address ',
                logsdir'\nwreq\'client'.adr ',
                cltdir'\nwmpts.rsp'
x.9.rspdir = ''
x.9.default = ''

x.ldr = 10
x.10.name='Lan Distance Remote'
x.10.statevar = 'CAS_' || x.10.name
ldcs_install = ''
call SysFileTree cidimgdir'\ldrem\*', 'ldcsstem', 'FOS'                         /* Find all the files under LDCS */
do jj = 1 to ldcsstem.0                                                         /* Walk each file until we find */
   if strip(translate(filespec('NAME',ldcsstem.jj))) = 'INSTALL.EXE' then do    /* install.exe */
      ldcs_install = ldcsstem.jj                                                /* Assign the path to a variable */
      jj = ldcsstem.0
   end
end
drop ldcsstem.
x.10.instprog = ldcs_install' ',
                 ' /l1:'logsdir'\ldr\'client'.ldi ',
                 ' /r:'
x.10.rspdir = cltdir'\'
x.10.default = 'ldr.rsp'

x.svagent = 11
x.11.name = 'SystemView Agent'
x.11.statevar = 'CAS_'|| x.11.name
x.11.instprog = cidimgdir'\SVAGENT\install.cmd ',
                 '/l1:'logsdir'\svagent\'client'.sva ',
                 '/s:'cidimgdir'\SVAGENT ',
                 '/a:' || svagent_instupdt ' ',
                 '/x ',
                 '/o:DRIVE ',
                 '/r:'
x.11.rspdir = cltdir'\'
x.11.default = 'svagent.rsp'

x.netfin = 12
x.12.name = 'NetFinity'
x.12.statevar = 'CAS_'|| x.12.name
x.12.instprog = cidimgdir'\netfin\netfinst.exe ',
                 ' /l1:'logsdir'\netfin\'client'.cer ',
                 ' /s:'cidimgdir'\netfin ',
                 ' /t:'NetFin_Drive' ' ,
                 ' /tu:'bootdrive'\ ',
                 ' /r:'
x.12.rspdir = cltdir'\'
x.12.default = 'netfin.rsp'

x.mfs = 13
x.13.name='Mobile File Sync'
x.13.statevar = 'CAS_' || x.13.name
x.13.instprog = cidimgdir'\MFS\INSTALL.EXE ',
                     '/l1:'logsdir'\mfs\'client'.hst ',
                     '/l2:'logsdir'\mfs\'client'.err ',
                     '/a:' || mfs_instupdt ' ',
                     '/x ',
                     '/o:DRIVE ',
                     '/p:"MFS Cache Manager" ',
                     '/s:'cidimgdir'\MFS ',
                     '/t:'MFS_Drive' ',
                     '/r:'
x.13.rspdir = cltdir'\'
x.13.default = 'MFS.RSP'

x.psns = 14
x.14.name='Personally Safe and Sound'
x.14.statevar = 'CAS_' || x.14.name
x.14.instprog = cidimgdir'\psns\psnsinst ',
                 ' /l1:'logsdir'\PSNS\'client'.err ',
                 ' /l2:'logsdir'\PSNS\'client'.hst ',
                 ' /s:'cidimgdir'\PSNS ',
                 ' /t:'psnstgtpath' ',
                 ' /tu:'bootdrive' ',
                 ' /r:'
x.14.rspdir = cltdir'\'
x.14.default = 'psns.rsp'

x.rmvnw = 15
x.15.name = 'Remove NetWare Requester'
x.15.statevar = 'CAS_' || x.15.name
x.15.instprog = ibminstdir'\npnwinst ',
               '/L1:'logsdir'\nwreq\'client'.hst ',
               '/L2:'logsdir'\nwreq\'client'.err ',
               '/P:'nwprefsrv' ',
               '/T:'nwtgtpath' ',
               '/TR:'nwtokenring' ',
               '/A:D ',
               '/S:'left(cidimgdir,1)
x.15.rspdir = ''
x.15.default = ''


NUM_INSTALL_PROGS=15

RETURN 0

/* Code to communicate with Progress Indicator */
progress_setup:

call rxfuncadd 'ProgressChangeProduct', RLANUTIL, 'ProgressChangeProduct'
call rxfuncadd 'ProgressKickOff', RLANUTIL, 'ProgressKickOff'
call rxfuncadd 'ProgressInstallFailed', RLANUTIL, 'ProgressInstallFailed'
call rxfuncadd 'ProgressCompleted', RLANUTIL, 'ProgressCompleted'
call rxfuncadd 'ProgressConnection', RLANUTIL, 'ProgressConnection'
call rxfuncadd 'ProgressReboot', 'RLANUTIL', 'ProgressReboot'

/* Only pass the progress indicator the products being installed
   in this boot iteration */

if OVERALL_STATE = 0 then do
   if reboot_this_time = 1 then do

      parse var deltasize 'MPTS:'mptssize mptsletter .
      deltasize = 'MPTS:'mptssize' 'mptsletter

   end /* do */
end /* do */

productcount = 0
do i = 1 to words(deltasize) by 2
   productcount = productcount + 1
   parse value word(deltasize,i) with kw':'kwval
   products.productcount.Drive = word(deltasize,i+1) || ':'
   products.productcount.Internalname = translate(kw)
   products.productcount.DASDRequired = kwval
   select

      when translate(kw) = 'MPTS' then do
         products.productcount.Product = strip(strip(SysGetMessage(111, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 8915093
      end

      when translate(kw) = 'FFST' then do
         products.productcount.Product = strip(strip(SysGetMessage(111, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 1
      end

      when translate(kw) = 'OS2PEER' then do
         products.productcount.Product = strip(strip(SysGetMessage(102, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 12361342
      end

      when translate(kw) = 'LDR' then do
         products.productcount.Product = strip(strip(SysGetMessage(105, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 5033547
      end

      when translate(kw) = 'TCPIP' then do
         products.productcount.Product = strip(strip(SysGetMessage(106, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 28768351
      end

      when translate(kw) = 'NETFIN' then do
         products.productcount.Product = strip(strip(SysGetMessage(107, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 7341429
      end

      when translate(kw) = 'NW' then do
         products.productcount.Product = strip(strip(SysGetMessage(110, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 5976883
      end

      when translate(kw) = 'PSNS' then do
         products.productcount.Product = strip(strip(SysGetMessage(108, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 3355443
      end

      when translate(kw) = 'WARP' then do
         products.productcount.Product = strip(strip(SysGetMessage(100, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 0
      end

      when translate(kw) = 'NSC' then do
         products.productcount.Product = strip(strip(SysGetMessage(112, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 2355443
      end

      when translate(kw) = 'MFS' then do
         products.productcount.Product = strip(strip(SysGetMessage(113, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 3654998
      end

      when translate(kw) = 'SVAGENT' then do
         products.productcount.Product = strip(strip(SysGetMessage(114, msgfile),,D2C(10)),,D2C(13))
         products.productcount.maxdasd = 5290650
      end


      otherwise nop

   end
end

products.0 = productcount

/* Find out what the total install size is if they weren't being reinstalled */
total_install_size = 0
do ii = 1 to products.0
   if products.ii.Internalname \= 'WARP' then
      total_install_size = total_install_size + products.ii.maxdasd
end

/* Assign it a weighted average */
do ii = 1 to products.0
   /* Leave warp out of the calcs */
   if products.ii.Internalname = 'WARP' then products.ii.percentcomplete = 0

   else products.ii.percentcomplete = format(products.ii.maxdasd / total_install_size *100,,0)
end

/* Kick off the progress indicator */
call ProgressKickOff 'products'

return 0

/* Tell indicator to go to next product */
progress_change: procedure expose products. percent_complete percentfile

parse arg prod1

tmprod = prod1

if prod1 = 'FFST' then prod1 = 'MPTS'

do i = 1 to products.0
   if prod1 = products.i.InternalName then do
      if tmpprod \= 'FFST' then
         percent_complete = update_pc(prod1)
      call ProgressChangeProduct products.i.Product, percent_complete
   end
end

return 0

/* Update the percent complete */
update_pc: procedure expose percentfile products. percent_complete

/* Arguments are the current product and whether or not we have to read in
   the file after a reboot */
parse arg inst_product rebooted

/* If we've rebooted, read in the file, getting the percent complete */
if rebooted \= '' then do
  percent_complete = linein(percentfile)
  call stream percentfile, 'C', 'CLOSE'
  call SysFileDelete percentfile
end

currper = 0
/* Find what percentage the current product is */
do i = 1 to products.0
  if inst_product = products.i.InternalName then
     currper = products.i.percentcomplete
end

percent_complete = percent_complete + currper

RETURN percent_complete

/* Write a list of the products installed, and if they succeeded. */
write_inst_prod:

   inst_prod_file = bootdrive'\OS2\INSTALL\NPINST.PRD'

   if stream(inst_prod_file, 'C', 'QUERY EXISTS') \= '' then
      call SysFileDelete inst_prod_file

   call lineout inst_prod_file, '('
   call lineout inst_prod_file, strip(strip(SysGetMessage(111, msgfile),,D2C(10)),,D2C(13))
   call lineout inst_prod_file, 1
   call lineout inst_prod_file, logsdir'\mpts\'client'.mpt'
   call lineout inst_prod_file, ')'


   do i = 1 to words(products_to_install)

      kw = strip(word(products_to_install,i))

      select

         when translate(kw) = 'OS2PEER' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(102, msgfile),,D2C(10)),,D2C(13))
            if x.os2peer.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\os2peer\'client'.ins  '
            call lineout inst_prod_file, ')'
         end

         when translate(kw) = 'LDR' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(105, msgfile),,D2C(10)),,D2C(13))
            if x.ldr.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\ldr\'client'.ldi '
            call lineout inst_prod_file, ')'
         end

         when translate(kw) = 'TCPIP' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(106, msgfile),,D2C(10)),,D2C(13))
            if x.tcpapps.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\tcpapps\'client'.tcp'
            call lineout inst_prod_file, ')'
         end

         when translate(kw) = 'NETFIN' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(107, msgfile),,D2C(10)),,D2C(13))
            if x.netfin.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\netfin\'client'.cer'
            call lineout inst_prod_file, ')'
         end

         when translate(kw) = 'NW' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(110, msgfile),,D2C(10)),,D2C(13))
            if x.nwinst.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\nwreq\'client'.hst '
            call lineout inst_prod_file, ')'
         end

         when translate(kw) = 'PSNS' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(108, msgfile),,D2C(10)),,D2C(13))
            if x.psns.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\PSNS\'client'.err '
            call lineout inst_prod_file, ')'
         end

         when translate(kw) = 'NSC' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(112, msgfile),,D2C(10)),,D2C(13))
            if x.nsc.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\nsc\'client'.log '
            call lineout inst_prod_file, ')'
         end

         when translate(kw) = 'MFS' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(113, msgfile),,D2C(10)),,D2C(13))
            if x.mfs.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\mfs\'client'.hst '
            call lineout inst_prod_file, ')'
         end

         when translate(kw) = 'SVAGENT' then do
            call lineout inst_prod_file, '('
            call lineout inst_prod_file, strip(strip(SysGetMessage(114, msgfile),,D2C(10)),,D2C(13))
            if x.svagent.bad = 1 then
               call lineout inst_prod_file, 1
            else
               call lineout inst_prod_file, 0
            call lineout inst_prod_file, logsdir'\svagent\'client'.sva '
            call lineout inst_prod_file, ')'
         end


         otherwise nop

      end


   end

   call lineout inst_prod_file

RETURN 0

/* Error handling.  This will call the progress indicator with the failing module
   and return code, kill the startup.cmd and then the progress
   indicator will re-boot */

kill_install:

  currdir = directory()
  call directory ibminstdir
  do i = 1 to products.0
     if inst_product = products.i.InternalName then failname = products.i.Product
  end
  progress_rc = d2x(progress_rc)

  '@call npclean 'bootdrive

  /* Move whichever objects we are able. */
  '@call clndesk deskobj.rem tables\npconfig.cfg'

  if products.0 > 0 then do
     rc =ProgressInstallFailed(progress_rc, failname)
     if rc = 0 then do
         sleepcnt = 0
         do until rc = 1 | sleepcnt > 3
            call SysSleep 10
            rc = ProgressInstallFailed(progress_rc, failname)
         end
     end
  end
  else do
     rc = ProgressInstallFailed(progress_rc, 'Preprocessing')
     if rc = 0 then do
         sleepcnt = 0
         do until rc = 1 | sleepcnt > 3
            call SysSleep 10
            rc = ProgressInstallFailed(progress_rc, 'Preprocessing')
         end
     end
  end
  call directory currdir
  exit
RETURN 0

RunInstall: procedure expose x. queue_reboot call_again configsys logfile client OVERALL_STATE progress_rc bootdrive
  parse arg index, new_state, other
  install = SetEnvironmentVar(x.index.statevar)
  if install == YES then do
    state = value('REMOTE_INSTALL_STATE',,'OS2ENVIRONMENT')     /* check   REMOTE_INSTALL_STATE */
    if state <> 0 then
      rc2 = LogMessage(75, x.index.name, state, logfile)        /* log an install starting msg  */
    else
      rc2 = LogMessage(72, x.index.name, '', logfile)           /* log an install starting msg  */

    /* Need to handle the case for migrating TCP/IP in MPTS from the integrated path */
    integratflag = value('TARGETPATH',,'OS2ENVIRONMENT')
    if integratflag \= '' then do
       fndpath = 0
       do while lines(configsys) > 0 & fndpath \= 1
          line1 = linein(configsys)
          parse var line1 . kw'='kwval
          if translate(kw) = 'PATH' then fndpath = 1
       end /* do */
       call lineout configsys
       install_prog = bootdrive || '\OS2\CMD.EXE /C "SET PATH='kwval' & ' || strip(x.index.instprog)         /* build the command string     */
    end  /* Do */
    else
      install_prog = 'CMD /C ' || strip(x.index.instprog)         /* build the command string     */

                                                /* If automatic responst file selection was     */
                                                /* indicated, then get the response file name   */
                                                /* and append it to the command string.         */
    if x.index.default <> '' then do
      response_file = DetermineResponseFile(x.index.rspdir, client,
                                            , x.index.default, x.index.name,
                                            , logfile)
      if response_file == '' then call kill_install
      install_prog = install_prog || response_file
    end

    /* Append final quote mark */
    if integratflag \= '' then install_prog = install_prog || '"'

    install_prog                                                /* Execute the install program  */

    state = value(x.index.statevar,,'OS2ENVIRONMENT')           /* Get the current install state*/
                                                                /* for this install program from*/
                                                                /* the environment.             */

/* Added save of rc to use with install_failure window */
    progress_rc = rc

                                                /* Check the return code and set the global     */
                                                /* variables accordingly.                       */

    parse value ProcessReturnCode(rc, state, QUEUE_REBOOT, CALL_AGAIN, logfile),
           with rc ',' state ',' QUEUE_REBOOT ',' CALL_AGAIN

    rc2 = value(x.index.statevar, state, 'OS2ENVIRONMENT')      /* Set the new install state for*/
                                                                /* this install program.        */

                                                /* Put the install state into the CONFIG.SYS,   */
                                                /* if this action was unsuccessful, then exit.  */

    putsuccess = 1; repeat_counter = 0
    do while putsuccess \= 0 & repeat_counter < 3
       putsuccess = PutStateVar(x.index.statevar, state, configsys, logfile)
       if putsuccess \= 0 then do
          call SysSleep 2
          repeat_counter = repeat_counter + 1
       end /* do */
    end /* do */
    if putsuccess \= 0 then call kill_install

    if rc == GOOD_RC then do
      rc2 = LogMessage(70, x.index.name, '', logfile)           /* log an install successful msg*/
      return GOOD_RC                                            /* return a good return code    */
    end

    else do
      rc2 = LogMessage(71, x.index.name, '', logfile)           /* log an install failed msg    */
      if (new_state <> '') then                                 /* If a new state was requested,*/
                                                                /* then set OVERALL_STATE to the*/
        rc2 = SetState(new_state, 'RunInstall', 2)              /* new state.                   */

      return BAD_RC                                             /* return a bad return code     */
    end
  end
  return GOOD_RC

/*************************************************************/
GetEnvironmentVars: procedure expose X. NUM_INSTALL_PROGS


  OVERALL_STATE = value(x.0.statevar,,'OS2ENVIRONMENT')         /* Get the overall install state */
                                                                /* from the environment.         */

  if OVERALL_STATE == '' then do                                /* If the overall install state  */
    OVERALL_STATE = 0                                           /* has not been set yet, reset   */
    do I=0 to NUM_INSTALL_PROGS by 1                            /* all the state vars to 0.      */
      if x.I.statevar <> '' then
        rc = value(x.I.statevar,'0','OS2ENVIRONMENT')
    end
  end

  return OVERALL_STATE


/*************************************************************/
SetEnvironmentVar: procedure
  parse arg env_string, other
  if env_string == '' then do                                   /* If the install program has   */
                                                                /* no state variable, then ...  */

    rc = value('REMOTE_INSTALL_STATE','0','OS2ENVIRONMENT')     /* Set the REMOTE_INSTALL_STATE */
                                                                /* to 0 so that the program     */
                                                                /* being run can know that is   */
                                                                /* being run in an unattended   */
                                                                /* environment.                 */

    return YES                                                  /* return install=yes           */

  end

  state = value(env_string,,'OS2ENVIRONMENT')                   /* Otherwise, get the value of  */
                                                                /* the state variable from the  */
                                                                /* environment.                 */

  if state <> '' then do                                        /* If the state variable exists */

    rc = value('REMOTE_INSTALL_STATE',state,'OS2ENVIRONMENT')   /* Set the REMOTE_INSTALL_STATE */
                                                                /* environment variable to the  */
                                                                /* value of the state variable. */

    return YES                                                  /* return install=yes           */
  end
  else                                                          /* Otherwise,                   */
    return NO                                                   /* return install=no            */


/*************************************************************/
BootDriveIsDiskette:

  if IsBootDriveRemovable() == 1 then do                        /* If the drive booted from is  */
                                                                /* a diskette drive, then set   */
    rc2 = SetState(OVERALL_STATE+1)                             /* the OVERALL_STATE to the     */
                                                                /* requested value.             */
    return 'YES'

  end

  else                                                          /* else the machine was booted  */
                                                                /* from the hardfile.           */
    return 'NO'

/*************************************************************/
BootDriveIsFixedDisk:

  if IsBootDriveRemovable() == 0 then do                        /* If the drive booted from is  */
                                                                /* a fixed disk, then set       */
    rc2 = SetState(OVERALL_STATE+1)                             /* the OVERALL_STATE to the     */
                                                                /* requested value.             */
    return 'YES'

  end

  else                                                          /* else the machine was booted  */
                                                                /* from a diskette.             */
    return 'NO'

/*************************************************************/
SetState:
  parse arg new_state, proc_name, param_num, other

    if datatype(new_state, number) <> 1 then do                 /* If the new state requested is*/
                                                                /* not numeric, then log an     */
      if proc_name <> '' then                                   /* error.                       */
        LogMessage(63, proc_name, param_num, logfile)
      else
        LogMessage(63, 'SetState', 1, logfile)

      call kill_install
    end

    OVERALL_STATE = new_state                                   /* Set the OVERALL_STATE to the */
                                                                /* new state requested.         */

    rc = value(x.0.statevar, new_state, 'OS2ENVIRONMENT')       /* Save the OVERALL_STATE in the*/
                                                                /* environment.                 */
    return 'NO_ERROR'


/*************************************************************/
SaveStates:

  do I=0 to NUM_INSTALL_PROGS by 1            /* Put the install states into the CONFIG.SYS,  */
    if x.I.statevar <> '' then do               /* if this action was unsuccessful, then exit.  */
      putsuccess = 1; repeat_counter = 0
      do while putsuccess \= 0 & repeat_counter < 3
         putsuccess =  PutStateVar(x.I.statevar, value(x.I.statevar,,'OS2ENVIRONMENT'),
                                     , configsys, logfile)
         if putsuccess \= 0 then do
             call SysSleep 2
             repeat_counter = repeat_counter + 1
          end /* do */
      end
      if putsuccess \= 0 then call kill_install
    end
  end

  return

/*************************************************************/
RebootAndGotoState:
  parse arg new_state, other

  rc2 = SetState(new_state, 'RebootAndGotoState', 1)           /* Set the state to go to in    */
                                                               /* OVERALL_STATE.               */

  Call SaveStates                                              /* Save the environment vars    */

  Call Reboot                                                  /* Reboot the machine           */

  return


/*************************************************************/
CheckBoot:
  if QUEUE_REBOOT <> 0 then do                                  /* If a reboot has been queued  */
                                                                /* by an install program ...    */

    if CALL_AGAIN == 0 then                                     /* If no install programs want  */
                                                                /* to be recalled ...           */

      rc = SetState(OVERALL_STATE+1)                            /* Increment the overall state  */
                                                                /* variable.                    */

    Call SaveStates                                             /* Save the environment vars    */

    Call Reboot                                                 /* Reboot the machine           */

  end

  else                                                          /* Otherwise, increment the     */
    rc = SetState(OVERALL_STATE+1)                              /* state variable and go on.    */

  return


/*************************************************************/
Reboot:
  bootdrive

  rc = value('OS2_SHELL', bootdrive || '\OS2\CMD.EXE', 'OS2ENVIRONMENT')
  rc = value('COMSPEC',   bootdrive || '\OS2\CMD.EXE', 'OS2ENVIRONMENT')

  'cls'
/*  rc = AskRemoveDiskIfFloppy()*/

  pathlen = length(exepath)                                     /* Get length of exepath        */
  posslash = lastpos("\",strip(exepath))                        /* Determine the last occurcnce */
                                                                /*   of '\' in exepath          */

  if posslash = pathlen then                                    /* If '\' is the last character */

    cmdline = exepath || 'SETBOOT /IBD:' || bootdrive           /* Then append 'SETBOOT'        */

  else

    cmdline = exepath || '\SETBOOT /IBD:' || bootdrive          /* Else append '\SETBOOT'       */

  LogMessage(74, '', '', logfile)                               /* Log a message indicating     */
                                                                /* reboot.                      */
  cmdline

  LogMessage(73, 'SETBOOT', '', logfile)                        /* If the code gets to here, the*/
                                                                /* reboot failed.  Log a message*/
/*exit  Modified line follows for LAN Client */                 /* and exit.                    */
  '@pause 1>nul 2>nul'


  return


/*************************************************************/
AddDLLFunctions:
  Call RxFuncAdd 'ProcessReturnCode',     'CASAGENT', 'PROCESSRETURNCODE'
  Call RxFuncAdd 'DetermineResponseFile', 'CASAGENT', 'DETERMINERESPONSEFILE'
  Call RxFuncAdd 'PutStateVar',           'CASAGENT', 'PUTSTATEVAR'
  Call RxFuncAdd 'LogMessage',            'CASAGENT', 'GETANDLOGMESSAGE'
  Call RxFuncAdd 'AskRemoveDiskIfFloppy', 'CASAGENT', 'ASKREMOVEDISKIFFLOPPY'
  Call RxFuncAdd 'IsBootDriveRemovable',  'CASAGENT', 'ISBOOTDRIVEREMOVABLE'
  Call RxFuncAdd 'GetOS2Version',         'CASAGENT', 'GETOS2VERSION'
  Call RxFuncAdd 'SetCIDType',            'CASAGENT', 'SETCIDTYPE'

  return
