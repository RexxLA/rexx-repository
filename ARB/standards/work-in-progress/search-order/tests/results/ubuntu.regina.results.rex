/******************************************************************************
  sotest.rex -- A Search Order test suite

  Interpreter:      REXX-Regina_3.9.5 5.00 25 Jun 2022
  Operating system: UNIX
  Full name:        /home/sam/sotest/sotest.rex
  Main routine:     /home/sam/sotest/subdir/dotdotsame/same/main.rex

  Test suite starting on 17 Mar 2023 at 15:40:53

  The following values have been set:

    Same directory:    '/home/sam/sotest/subdir/dotdotsame/same'
    Current directory: '/home/sam/sotest/subdir/dotdotcurr/curr'
    Path:              '/home/sam/sotest/subdir/dotdotpath/path'

  This is Regina. Search order is directory-first

 ******************************************************************************/
Pass.1  = .false; Pass.1.test  = 'same'
Pass.2  = .false; Pass.2.test  = 'same.rex'
Pass.3  = .true;  Pass.3.test  = 'curr'
Pass.4  = .true;  Pass.4.test  = 'curr.rex'
Pass.5  = .true;  Pass.5.test  = 'path'
Pass.6  = .true;  Pass.6.test  = 'path.rex'
Pass.7  = .false; Pass.7.test  = 'lib/samelib'
Pass.8  = .false; Pass.8.test  = 'lib/samelib.rex'
Pass.9  = .true;  Pass.9.test  = 'lib/currlib'
Pass.10 = .true;  Pass.10.test = 'lib/currlib.rex'
Pass.11 = .false; Pass.11.test = 'lib/pathlib'
Pass.12 = .false; Pass.12.test = 'lib/pathlib.rex'
Pass.13 = .false; Pass.13.test = './same'
Pass.14 = .false; Pass.14.test = './same.rex'
Pass.15 = .true;  Pass.15.test = './curr'
Pass.16 = .true;  Pass.16.test = './curr.rex'
Pass.17 = .false; Pass.17.test = './path'
Pass.18 = .false; Pass.18.test = './path.rex'
Pass.19 = .false; Pass.19.test = '../dotdotsame'
Pass.20 = .false; Pass.20.test = '../dotdotsame.rex'
Pass.21 = .true;  Pass.21.test = '../dotdotcurr'
Pass.22 = .true;  Pass.22.test = '../dotdotcurr.rex'
Pass.23 = .false; Pass.23.test = '../dotdotpath'
Pass.24 = .false; Pass.24.test = '../dotdotpath.rex'
Pass.25 = .false; Pass.25.test = 'lib/../../dotdotsame'
Pass.26 = .false; Pass.26.test = 'lib/../../dotdotsame.rex'
Pass.27 = .true;  Pass.27.test = 'lib/../../dotdotcurr'
Pass.28 = .true;  Pass.28.test = 'lib/../../dotdotcurr.rex'
Pass.29 = .false; Pass.29.test = 'lib/../../dotdotpath'
Pass.30 = .false; Pass.30.test = 'lib/../../dotdotpath.rex'
Pass.0 = 30
Return Pass.
