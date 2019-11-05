/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Copyright (c) 2009-2014 Rexx Language Association. All rights reserved.    */
/*                                                                            */
/* This program and the accompanying materials are made available under       */
/* the terms of the Common Public License v1.0 which accompanies this         */
/* distribution. A copy is also available at the following address:           */
/* http://www.oorexx.org/license.html                                         */
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

  	ReadMe

  1.  ooDialog - Dialog Control Example Programs
  -----------------------------------------------

  This directory and subdirectory contain example programs that demonstrate
  how to use the various dialog control objects in ooDialog.  It is intended
  that, eventually there will be an example of all the control objects.  The
  programs are intended to show several of the methods of the control
  objects. This will probably cause them to be medium complex.

  Many of the example programs are in dialog control subdirectories to make
  it easy to find examples of a specific control.  List-view examples in the
  ListView subdirectory, ToolTip examples in the ToolTip subdirectory, etc..

    - fiscalReports.rex

    Demonstrates how to use the DateTimePicker control.  This example
    focuses on how to use call back fields in the format string for the
    DateTimePicker control and how to respond to the FORMATQUERY, FORMAT,
    and KEYDOWN notifications.

    - paidHolidays.rex

    Shows how to use a MonthCalendar control, including responding to the
    GETDAYSTATE event.  Also shows how to: restrict the time span shown in
    the calendar, resize the calendar to the optimal size, and determine
    which months are currently displayed.

    - upDown.rex

    Demonstrates how to use the UpDown class.  An up down control is a pair
    of arrow buttons that the user can click to increment or decrement a
    value, such as a scroll position or a number displayed in a companion
    control.

    - userStringDTP.rex

    Demonstrates how to use the DateTimePicker control.  This example
    focuses on the USERSTRING notification.  The USERSTRING notification is
    sent when the user finishes editing in the DTP control.  Only DTP
    controls with the CANPARSE style send this notification.  It allows the
    program to provide the user with the capability of typing within the DTP
    control.  The program can then provide a custom response when the user
    has finished typing.

