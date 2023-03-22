/******************************************************************************
  sotest.rex -- A Search Order test suite

  Interpreter:      REXX-ooRexx_5.1.0(MT)_64-bit 6.05 10 Mar 2023
  Operating system: WindowsNT
  Full name:        D:\Dropbox\ooRexx\sotest\sotest.rex
  Main routine:     D:\Dropbox\ooRexx\sotest\subdir\dotdotsame\same\main.rex

  Special test: CMD.EXE

  Test suite starting on 22 Mar 2023 at 14:37:07

  The following values have been set:

    Same directory:    'D:\Dropbox\ooRexx\sotest\subdir\dotdotsame\same'
    Current directory: 'D:\Dropbox\ooRexx\sotest\subdir\dotdotcurr\curr'
    Path:              'D:\Dropbox\ooRexx\sotest\subdir\dotdotpath\path'

  This is ooRexx. Search order is extension-first

 ******************************************************************************/
Pass.1  = .false; Pass.1.test  = 'same'
Pass.2  = .false; Pass.2.test  = 'same.rex'
Pass.3  = .true;  Pass.3.test  = 'curr'
Pass.4  = .true;  Pass.4.test  = 'curr.rex'
Pass.5  = .true;  Pass.5.test  = 'pth'
Pass.6  = .true;  Pass.6.test  = 'path.rex'
Pass.7  = .false; Pass.7.test  = 'lib\samelib'
Pass.8  = .false; Pass.8.test  = 'lib\samelib.rex'
Pass.9  = .true;  Pass.9.test  = 'lib\currlib'
Pass.10 = .true;  Pass.10.test = 'lib\currlib.rex'
Pass.11 = .false; Pass.11.test = 'lib\pathlib'
Pass.12 = .false; Pass.12.test = 'lib\pathlib.rex'
Pass.13 = .false; Pass.13.test = '.\same'
Pass.14 = .false; Pass.14.test = '.\same.rex'
Pass.15 = .true;  Pass.15.test = '.\curr'
Pass.16 = .true;  Pass.16.test = '.\curr.rex'
Pass.17 = .false; Pass.17.test = '.\path'
Pass.18 = .false; Pass.18.test = '.\path.rex'
Pass.19 = .false; Pass.19.test = '..\dotdotsame'
Pass.20 = .false; Pass.20.test = '..\dotdotsame.rex'
Pass.21 = .true;  Pass.21.test = '..\dotdotcurr'
Pass.22 = .true;  Pass.22.test = '..\dotdotcurr.rex'
Pass.23 = .false; Pass.23.test = '..\dotdotpath'
Pass.24 = .false; Pass.24.test = '..\dotdotpath.rex'
Pass.25 = .false; Pass.25.test = 'lib\..\..\dotdotsame'
Pass.26 = .false; Pass.26.test = 'lib\..\..\dotdotsame.rex'
Pass.27 = .true;  Pass.27.test = 'lib\..\..\dotdotcurr'
Pass.28 = .true;  Pass.28.test = 'lib\..\..\dotdotcurr.rex'
Pass.29 = .false; Pass.29.test = 'lib\..\..\dotdotpath'
Pass.30 = .false; Pass.30.test = 'lib\..\..\dotdotpath.rex'
/* Executing 'SUBST Z: D:\Dropbox\ooRexx\sotest\subdir\dotdotcurr'            */
/* Executing 'SUBST Y: D:\Dropbox\ooRexx\sotest\subdir\dotdotpath'            */
/* Changing current directory to Z:\                                          */
/* Changing PATH to Y:\                                                       */
Pass.31 = .false; Pass.31.test = '\Dropbox\ooRexx\sotest\subdir\dotdotsame\same\same'
Pass.32 = .false; Pass.32.test = '\Dropbox\ooRexx\sotest\subdir\dotdotsame\same\same.rex'
Pass.33 = .true;  Pass.33.test = '\dotdotcurr'
Pass.34 = .true;  Pass.34.test = '\dotdotcurr.rex'
Pass.35 = .false; Pass.35.test = '\dotdotpath'
Pass.36 = .false; Pass.36.test = '\dotdotpath.rex'
Pass.37 = .false; Pass.37.test = 'D:lib\samelib'
Pass.38 = .false; Pass.38.test = 'D:lib\samelib.rex'
Pass.39 = .true;  Pass.39.test = 'Z:curr\curr'
Pass.40 = .true;  Pass.40.test = 'Z:curr\curr.rex'
Pass.41 = .true;  Pass.41.test = 'Y:path\path'
Pass.42 = .true;  Pass.42.test = 'Y:path\path.rex'
Pass.43 = .true;  Pass.43.test = 'D:\Dropbox\ooRexx\sotest\subdir\dotdotsame\same\same'
Pass.44 = .true;  Pass.44.test = 'D:\Dropbox\ooRexx\sotest\subdir\dotdotsame\same\same.rex'
Pass.45 = .true;  Pass.45.test = 'Z:\curr\curr'
Pass.46 = .true;  Pass.46.test = 'Z:\curr\curr.rex'
Pass.47 = .true;  Pass.47.test = 'Y:\path\path'
Pass.48 = .true;  Pass.48.test = 'Y:\path\path.rex'
Pass.0 = 48
Return Pass.