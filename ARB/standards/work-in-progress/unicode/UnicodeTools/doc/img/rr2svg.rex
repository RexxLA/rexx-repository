#!/usr/bin/env rexx
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Copyright (c) 2023-2024 Rexx Language Association. All rights reserved.    */
/*                                                                            */
/* This program and the accompanying materials are made available under       */
/* the terms of the Common Public License v1.0 which accompanies this         */
/* distribution. A copy is also available at the following address:           */
/* https://www.oorexx.org/license.html                                        */
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

/* As of 2023-02-04 Gunther Rademacher's RailroadGenerator will create all svg
   definitions from an ebnf definition and export it as part of a single xhtml file.
   The ooRexx documentation needs single svg files which this utility will extract
   and create.

   The formatting definitions will be replaced by the ones found in
   "rexxextensions\en-US\images\json_init.svg" as of 2023-02-04.

   Cf: "Railroad-Diagram-Generator":
          outdated: <https://www.bottlecaps.de/rr/ui> (2023-02-04)
          latest:   <https://rr.red-dove.com/ui> (2024-03-16)

   Usage:
      - create EBNF and download the svg as part of xhtml from <https://rr.red-dove.com/ui>
      - run this program, supply it the name of the downloaded xhtml file: all included
        svg definitions will be saved in separate svg files in the same directory
        where the xhtml file is located
   Changes:
      - 20240316: changed the svg name needle from '<xhtml:a name="' to '<a name="'
      - 20240323: now probing if '<xhtml:a' needle is available, if so it will get used,
                  otherwise the '<a' needle (to support both encodings)
      - 20240324: - if no argument, then do a sysFileTree from current directory to locate
                    all xhtml files and process them
                  - if argument is a directory, then do a sysFileTree from that
                    directory and its subdirectories to locate all xhtml files and process them
                  - make sure that the extracted svg data is ended with CRLF by turning
                    the data into a string array and back into a string defining CRLF
                    to be used as the line delimiter
*/

parse arg xhtml_fn
if xhtml_fn="" | SysIsFileDirectory(xhtml_fn) then -- search directory and subdirectories
do
  if xhtml_fn="" then xhtml_fn="." -- default to current directory
  qxhtml_fn=qualify(xhtml_fn"\.")
  search=qxhtml_fn"\*.xhtml"
  call sysFileTree search, "files.", "FOS"
  say "searched" pp(search)", found" files.i "xhtml files to process"
end
else if \sysFileExists(xhtml_fn) then
do
   say pp(xhtml_fn) "does not exist, aborting ..."
   exit -1
end
else  -- use single xhtml file only
do
   files.0=1
   files.1=qualify(xhtml_fn)
end

prefix="    "
say "processing the following xhtml file(s):"
do counter c0 i=1 to files.0
   say prefix "#" i~right(3)":" files.i
end
ruler="-"~copies(79)
say ruler
do counter c1 i=1 to files.0     -- iterate over stem
   say "processing" pp(files.i) "..."
      -- read content
   s=.stream~new(files.i)~~open("read")
   content=s~charin(1,s~chars)
   s~close
   arrSvgs=parse_svgs(content, prefix)   -- get array with extracted svg definitions
   say "... extracted" pp(arrSvgs~items) "svg definitions from" pp(files.i)
   say
      -- create svg files
   xhtml_dir=filespec("location",files.i)  -- get xhtml's directory
   do counter c2 a over arrSvgs
      fn=xhtml_dir || a[1]".svg"
      say prefix"creating #" c2~right(4)":" pp(fn)
      -- make sure we use only CRLF as eol for svg files
      svgData=a[2]~makeArray ~makeString('L','0d0a'x)
      .stream~new(fn)~~open("replace")~~charout(svgData)~~close
   end
   say ruler
end


::routine parse_svgs
  use arg content, prefix=""

  xhtmlOTag='<a name="'       -- default to newer xhtml
  needle='<xhtml:a name="'    -- could still be in use
  if content~pos(needle)>0 then xhtmlOTag=needle
  svgOTag="<svg "
  svgETag="</svg>"

  arrSvgs=.array~new
  nl="0d0a"x
  str_svg_style_defs=nl || .resources~svg_style_defs~makeString || nl

  do counter c while content<>""
      parse var content (xhtmlOTag) svnName '"' (svgOTag) <0 svgDef (svgETag) content
      if svgDef="" | svnName="Railroad-Diagram-Generator" then iterate
      parse var svgDef "<" <0 svgOpen '>' svgDef2
      res=svgOpen || '>' || str_svg_style_defs || svgDef2 || nl || svgETag
      arrSvgs~append( (svnName, res) )
      say prefix || "extracted #" c~right(3)":" pp(svnName)
  end
  return arrSvgs


::routine pp
  return "["arg(1)"]"

/*
   Extracted the <defs> definitions from "rexxextensions\en-US\images\json_init.svg" as
   of 2023-02-04.
*/
::resource svg_style_defs
         <defs>
            <style type="text/css">
               @namespace "http://www.w3.org/2000/svg";
               .line                 {fill: none; stroke: #1F1F1F;}
               .bold-line            {stroke: #0A0A0A; shape-rendering: crispEdges; stroke-width:
               2; }
               .thin-line            {stroke: #0F0F0F; shape-rendering: crispEdges}
               .filled               {fill: #1F1F1F; stroke: none;}
               text.terminal         {font-family: Verdana, Sans-serif;
               font-size: 12px;
               fill: #0A0A0A;
               font-weight: bold;
               }
               text.nonterminal      {font-family: Verdana, Sans-serif; font-style: italic;
               font-size: 12px;
               fill: #0D0D0D;
               }
               text.regexp           {font-family: Verdana, Sans-serif;
               font-size: 12px;
               fill: #0F0F0F;
               }
               rect, circle, polygon {fill: #1F1F1F; stroke: #1F1F1F;}
               rect.terminal         {fill: #CCCCCC; stroke: #1F1F1F;}
               rect.nonterminal      {fill: #E3E3E3; stroke: #1F1F1F;}
               rect.text             {fill: none; stroke: none;}
               polygon.regexp        {fill: #EFEFEF; stroke: #1F1F1F;}

            </style>
         </defs>
::END
