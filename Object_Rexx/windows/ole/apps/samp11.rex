/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Copyright (c) 1995, 2004 IBM Corporation. All rights reserved.             */
/* Copyright (c) 2005-2014 Rexx Language Association. All rights reserved.    */
/*                                                                            */
/* This program and the accompanying materials are made available under       */
/* the terms of the Common Public License v1.0 which accompanies this         */
/* distribution. A copy is also available at the following address:           */
/* http://www.oorexx.org/license.html                          */
/*                                                                            */
/* Redistribution and use in source and binary forms, with or                 */
/* without modification, are permitted provided that the following            */
/* conditions are met:                                                        */
/*                                                                            */
/* Redistributions of source code must retain the above copyright             */
/* notice, this list of conditions and the following disclaimer.              */
/* Redistributions in binary form must reproduce the above copyright          */
/* notice, this list of conditions and the following disclaimer in            */
/* the documentation and/or other materials provided with the distribution.   */
/*                                                                            */
/* Neither the name of Rexx Language Association nor the names                */
/* of its contributors may be used to endorse or promote products             */
/* derived from this software without specific prior written permission.      */
/*                                                                            */
/* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS        */
/* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT          */
/* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS          */
/* FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   */
/* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,      */
/* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED   */
/* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,        */
/* OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY     */
/* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING    */
/* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS         */
/* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               */
/*                                                                            */
/*----------------------------------------------------------------------------*/
/**********************************************************************/
/*                                                                    */
/* SAMP11.REX: OLE Automation with Object REXX - Sample 11            */
/*                                                                    */
/* Get stock price from IBM internet page with Microsoft Internet     */
/* Explorer and store it in a REXX variable.                          */
/*                                                                    */
/**********************************************************************/

/* Get stock price from IBM internet page with MS IE and OLE */

say "Getting stock price from IBM Internet page."
say "Using a not visible InternetExplorer."
say

Explorer = .OLEObject~new("InternetExplorer.Application")
/* uncomment the next line if you want to see what is happening */
--Explorer~Visible = .true
Explorer~Navigate("http://www.ibm.com/investor/")

-- Wait for browser to load the page, with a time out.  If the page is not
-- loaded by the timout, then quit.
count = 0
do while Explorer~busy & count < 12
    do while Explorer~readyState <> 4 & count < 12
        j = SysSleep(.5)
        count += 1
    end
end

if Explorer~busy | Explorer~readyState <> 4 then do
    say 'Timed out waiting for page: http://www.ibm.com/investor/'
    say 'to load.  Going to quit.'
    Explorer~quit
    return 99
end

/* obtain text representation of the page */
doc = Explorer~document           -- DOM document
body = doc~body                   -- get BODY
textrange = body~CreateTextRange  -- get TextRange
text = textrange~Text             -- get the contents

/* extract stock price information, this is dependent on page not changing */
parse var text . "(NYSE)" '0d0a'x stockprice "0d0a"x .
if stockprice = "" then do
    stockprice = "<could not read stock price>"
    gotPrice = .false
end
else do
    gotPrice = .true
end

/* end Explorer */
Explorer~quit

say "IBM stocks are at" stockprice"."
if \ gotPrice then say "Web page has likely changed format."

exit


