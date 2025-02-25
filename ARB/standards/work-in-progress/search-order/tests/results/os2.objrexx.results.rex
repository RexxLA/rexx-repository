/******************************************************************************
  SOTEST.REX -- A Search Order test suite

  Interpreter:      OBJREXX 6.00 18 May 1999
  Operating system: OS/2
  Full name:        C:\sotest\SOTEST.REX
  Main routine:     C:\sotest\subdir\dotdotsame\same\main.rex

  Test suite starting on 17 Mar 2023 at 16:23:29

  The following values have been set:

    Same directory:    'C:\sotest\subdir\dotdotsame\same'
    Current directory: 'C:\sotest\subdir\dotdotcurr\curr'
    Path:              'C:\sotest\subdir\dotdotpath\path'

 ******************************************************************************/
Pass.1  = .false; Pass.1.test  = 'same'
Pass.2  = .false; Pass.2.test  = 'same.rex'
Pass.3  = .true;  Pass.3.test  = 'curr'
Pass.4  = .true;  Pass.4.test  = 'curr.rex'
Pass.5  = .true;  Pass.5.test  = 'path'
Pass.6  = .true;  Pass.6.test  = 'path.rex'
Pass.7  = .false; Pass.7.test  = 'lib\samelib'
Pass.8  = .false; Pass.8.test  = 'lib\samelib.rex'
Pass.9  = .true;  Pass.9.test  = 'lib\currlib'
Pass.10 = .true;  Pass.10.test = 'lib\currlib.rex'
Pass.11 = .true;  Pass.11.test = 'lib\pathlib'
Pass.12 = .true;  Pass.12.test = 'lib\pathlib.rex'
Pass.13 = .false; Pass.13.test = '.\same'
Pass.14 = .false; Pass.14.test = '.\same.rex'
Pass.15 = .true;  Pass.15.test = '.\curr'
Pass.16 = .true;  Pass.16.test = '.\curr.rex'
Pass.17 = .true;  Pass.17.test = '.\path'
Pass.18 = .true;  Pass.18.test = '.\path.rex'
Pass.19 = .false; Pass.19.test = '..\dotdotsame'
Pass.20 = .false; Pass.20.test = '..\dotdotsame.rex'
Pass.21 = .true;  Pass.21.test = '..\dotdotcurr'
Pass.22 = .true;  Pass.22.test = '..\dotdotcurr.rex'
Pass.23 = .true;  Pass.23.test = '..\dotdotpath'
Pass.24 = .true;  Pass.24.test = '..\dotdotpath.rex'
Pass.25 = .false; Pass.25.test = 'lib\..\..\dotdotsame'
Pass.26 = .false; Pass.26.test = 'lib\..\..\dotdotsame.rex'
Pass.27 = .true;  Pass.27.test = 'lib\..\..\dotdotcurr'
Pass.28 = .true;  Pass.28.test = 'lib\..\..\dotdotcurr.rex'
Pass.29 = .true;  Pass.29.test = 'lib\..\..\dotdotpath'
Pass.30 = .true;  Pass.30.test = 'lib\..\..\dotdotpath.rex'
/*
    Drives Z: and Y: have been specified in the SOTEST_DRIVES
    environment variable. All required files are in place.
*/
/* Changing current directory to Z:\                                          */
/* Changing PATH to Y:\                                                       */
Pass.31 = .false; Pass.31.test = '\sotest\subdir\dotdotsame\same\same'
Pass.32 = .false; Pass.32.test = '\sotest\subdir\dotdotsame\same\same.rex'
Pass.33 = .true;  Pass.33.test = '\dotdotcurr'
Pass.34 = .true;  Pass.34.test = '\dotdotcurr.rex'
Pass.35 = .false; Pass.35.test = '\dotdotpath'
Pass.36 = .false; Pass.36.test = '\dotdotpath.rex'
Pass.37 = .false; Pass.37.test = 'C:lib\samelib'
Pass.38 = .false; Pass.38.test = 'C:lib\samelib.rex'
Pass.39 = .true;  Pass.39.test = 'Z:curr\curr'
Pass.40 = .true;  Pass.40.test = 'Z:curr\curr.rex'
Pass.41 = .true;  Pass.41.test = 'Y:path\path'
Pass.42 = .true;  Pass.42.test = 'Y:path\path.rex'
Pass.43 = .true;  Pass.43.test = 'C:\sotest\subdir\dotdotsame\same\same'
Pass.44 = .true;  Pass.44.test = 'C:\sotest\subdir\dotdotsame\same\same.rex'
Pass.45 = .true;  Pass.45.test = 'Z:\curr\curr'
Pass.46 = .true;  Pass.46.test = 'Z:\curr\curr.rex'
Pass.47 = .true;  Pass.47.test = 'Y:\path\path'
Pass.48 = .true;  Pass.48.test = 'Y:\path\path.rex'
Pass.0 = 48
Return Pass.
