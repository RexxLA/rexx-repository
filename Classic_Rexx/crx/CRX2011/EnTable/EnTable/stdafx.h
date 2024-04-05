// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

unsigned const ProdLimit = 160;
unsigned const TermLimit = 160;
unsigned const ParseLimit = 320;

#include "targetver.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <bitset>
#include <set>
#include <list>
#include <vector>
#include <map>
#include <algorithm>

  typedef unsigned int GramNdx;  // Index into the grammar, e.g. Source.
  typedef unsigned int Index; // Subscript for productions or terminals element.  (Negative for notsuch)