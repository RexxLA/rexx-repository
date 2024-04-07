"The past is a foreign country; they do things differently there."

The zip file comprises the record of "Compact Rexx" (CRX) which was written in the years around 1999 to validate the ANSI Rexx Standard and its Errata.  CRX has served its purpose in that respect. It is a 40000 byte CRX.EXE made from 13000 hand coded assembler lines (with sometimes more than one machine instruction per line) and 3000 machine generated assembler lines.  There are 18000 lines of source for tools that make the 3000 from the contents of the Standard.  This would be a poor balance if one just wanted another Rexx interpreter – it reflects the intent to take the Standard to execution with minimal human distortion.

There is now a zip

All readers now interested in CRX will benefit from at least skim reading:

- The Standard. http://www.rexxla.org/rexxlang/standards/j18pub.pdf
- Relevant papers presented at Rexx Symposia. (Here in \crx1999\symposia\) 

If your interest is only in something that will execute in a DOS 16 bit environment, take CRX.EXE from here. Put it where your PATH sees it and use it like CRX yourprog yourargs.  (The readme has more detail on what systems can run 16 bit programs.)

If your interest is in what it can do, or in test cases for the ANSI standard, consider folder crx1999\TESTS\.  Note that if there is no test for a Rexx feature, CRX probably does not handle it.  What the Standard defined as mostly configuration specific, e.g. the action of the STREAM builtin, CRX did not implement.

If your interest is in tools and coding styles for 1990's DOS Assembler code then consider folder CRX1999\ASM. This has the material to reproduce the old CRX.exe today, using the ancient tools in a DOS environment.  If you delete the .OBJ files and run NMAKE CRX.MK all the non-source files (.LST .EXE .MAP .OBJ) will be recreated (provided you have MASM 6.11 installed and the provided as2asm.exe available).  Note that some of the assembler code was machine generated.  The issue of reproducing the tools that made the machine generated Assembler code is covered in CRX1999\TOOLs 

If your interest is in compiler technology and the CRX structure, consider folder CRX2011.  This duplicates the CRX1999\Tools but with using the Studio Express 2010 IDE) 

If your interest is in upgrading CRX, in function or to 32/64 bit execution, consider folder CRX2012 which is commentary on the potential problems.  

There are READMEs in all the folders.






Any copyright notices about Formcroft can be ignored - the company mentioned no longer exists.

GENERAL

To execute anything with CRX you need a place to run 16-bit real mode addressing programs.  An old computer or a multiboot or a boot from CD, which brings up DOS, e.g. DOS 5.0, would be the authentic way to do this.  The Command Prompt of some Windows systems will also run 16 bit real programs, sometimes.  Early Windows, up to Windows XP 32 bit, will run the programs reliably in the Command Prompt.  No 64-bit Windows will run the programs.  Windows 7, 32 bit, fails on some programs. In particular it fails on the linker supplied with MASM 6.11 so CRX cannot be built there.  (This is a known problem.  The symptom of failure is a "NTVDM.EXE has stopped working" message.  DosBox is a free emulator you could install, and it does allow the linker to run under Windows 7, but DosBox was designed to run historic games and you would not want to run it all the time.)
   

The editor provided here (Edit.exe also e.exe) is PE2 from that era. Its tailoring is in E.PRO. Shown by f1 key when in editor.  Cable is a hex editor. These also run only at 16-bit.

Ignore anything that says "; MASM error.........".  There was a version of MASM with a bug that could be avoided by adding padding to your program.

FILE NAMES

In the "good old days" file extensions were a programmer choice.  Nowadays they are largely controlled by the big software providers.  You will find some unfamiliar file extensions here. Thus IS.KWC is the original name of a file that has the keywords from the international standard in a form that a C compiler can read.  ANSIKW.CPP would be a more modern name for the same file.

FILE DATES

Most of the files have been edited recently, to remove dependence on the directory structure within which they were originally used.  A few in more original form have been kept in the CRX1999\HISTORY folder as examples.

