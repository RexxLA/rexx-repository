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

/**
 * Name: employe4valid.rex
 * Type: Open Object REXX Script
 */

sd = locate()
dlg = .MyDialogClass~new(sd"employe2.rc", 100)
if dlg~initCode <> 0 then exit

dlg~execute("SHOWTOP")

::requires "ooDialog.cls"

::class MyDialogClass subclass RcDialog
::method initDialog
    self~city = "New York"
    self~male = 1
    self~female = 0
    self~addComboEntry(22, "Munich")
    self~addComboEntry(22, "New York")
    self~addComboEntry(22, "San Francisco")
    self~addComboEntry(22, "Stuttgart")
    self~addListEntry(23, "Business Manager")
    self~addListEntry(23, "Software Developer")
    self~addListEntry(23, "Broker")
    self~addListEntry(23, "Police Man")
    self~addListEntry(23, "Lawyer")
    self~connectButtonEvent(10, "CLICKED", "Print")   /* connect button 10 with a method */

::method print
    self~getData
    if self~male = 1 then title = "Mr."
    else title = "Ms."
    if self~married = 1 then addition = " (married) "
    else addition = ""
    call infoDialog title self~name addition || "A"x || "City:" self~city || "A"x ||,
                     "Profession:" self~profession

::method validate
    if self~getControlData(21)~strip = "" then do
        call infoDialog "An unnamed employee is not accepted!"
        return .false       /* dialog cannot be closed */
    end
    else do
        return .true       /* dialog can be closed */
    end
