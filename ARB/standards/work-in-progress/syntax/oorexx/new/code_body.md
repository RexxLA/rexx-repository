(From the ARB list, https://groups.io/g/rexxla-arb/message/1145. Mail from JMB 20251009.
The diagrams have been altered to make them equal to the ones present in this directory)

The ooRexx documentation _uses_ several concepts that it doesn't _define_ properly. 
I will pick some of these concepts to show what I mean, explain why this is a problem, 
and propose some solutions. 

## An example: code units and programs

(All the references below are to rexxref 5.2.0 beta)

* Chapter 3, "Directives", states that "A Rexx program contains one or more ***executable code units***. 
  Directive instructions separate these ***executable units***.
  A directive begins with a double colon (::) and is a nonexecutable instruction.
  For example, it cannot appear in a string for the INTERPRET instruction to be interpreted.
  The first directive instruction in a program marks the end of the
  ***main executable section*** of the program".
  The paragraph that immediately follows reads "For a program containing directives,
  all directives are processed first to set up the program's classes, methods, and routines.
  Then any program code in the ***main code unit*** (preceding the first directive) is processed.
  This code can use any classes, methods, and routines that the directives established".
* In note 3 of 3.1 "::ANNOTATE", we find "An annotation for an attribute, a method, or
  a routine should be placed after any attribute/method/routine ***code body***, as ::ANNOTATE,
  like any other directive, will end the ***code body***".
  Similarly, after example 3.2 in 3.2 "::ATTRIBUTE", we read
  "In that case, there is no method code body following the directive,
  so another directive (or the end of the program) must follow the ::ATTRIBUTE directive",
  and after example 3.3, we find "For ABSTRACT methods there is no method
  code body following the directive, so another directive (or the end of the program)
  must follow the ::ATTRIBUTE directive"; the same happens with 3.5 "::METHOD".
* Message 99.939 reads "External routines cannot have a code body".

We can see several expressions ("executable code unit", "executable unit", "(main) executable section", "main code unit", "code", "code body") which are obviously different but share the same reference: "a maximal piece of executable code separated by directives"

To complicate things further, some of these expressions are also used in several other contexts, but now with different meanings:

* For example, 5.1.5 "Package Class" says "A package instance holds all the routines,
  classes, and methods created from a ***source code unit*** and also manages
  external dependencies referenced by ::REQUIRES directives": here "(source) code unit"
  refers to the whole contents of a program file. 
* This very same concept (which is different from the code units/bodies/sections above)
  is more aptly called ***"source program"*** in other places:
  + 3.1 "::ANNOTATE" says "An annotation attribute, class, constant, method,
    and routine must be a valid class name, constant name, method name, or routine name
    defined with its respective directive in the same ***source program***".
  + 3.6 "::OPTIONS" says "PROLOG/NOPROLOG controls whether prolog code (any code in the
    ***source program*** that comes before the first directive) is run when another program
    requires it through a ::REQUIRES directive" and then adds "If ::OPTIONS PROLOG is in effect,
    any prolog code is run as usual when the ***source program*** is being required using
    a :REQUIRES directive. If ::OPTIONS NOPROLOG is in effect, any prolog code is not run.
    The default is ::OPTIONS PROLOG".
  + 3.8 "::RESOURCE" states that "The ::RESOURCE directive allows to include lines of
    resource_data of almost arbitrary form directly within the ***source program***".
  + 4.2 "Creating and Using Classes and Methods" says "To define a class using directives,
    you place a ::CLASS directive after the main part of your ***source program***".

Please note that neither "code", "code body", "code unit", "executable unit", 
"executable section", "source code", "source program" or "source unit" appear in the index.

## Why this is a problem

Object Rexx (and later ooRexx) builds over Classic Rexx by allowing 
complete Classic Rexx programs to be used as the bodies of new entities called 
prologs, routines and methods. Such bodies can use all the expressive power of 
Classic Rexx (including the `EXIT` instruction, which is not so easy to find 
in other languages), plus some enhancements like `EXPOSE`, which is necessary 
for the definition of methods, and several other extensions, like `RAISE`, `REPLY` 
or `GUARD`.

The manual makes continuous reference to these old-and-enhanced Classic Rexx bodies: 
it needs to, because otherwise it cannot reasonably explain how a ooRexx program 
should be written. But, since it does not have a formal definition of what a code body is, 
the nomenclature that it used varies from place to place: now it is a "code unit", 
now a "code body", now an "executable unit", and now simply "code".

Similarly, the concept of source program is also fundamental: 
in many cases, it contains the whole program, and in others, 
it's the basic programming unit of which a more complex ooRexx application is made. 
But, once more, the nomenclature changes: now it is a "source code unit", and now a "source program".

As it should be obvious, this is not good. Firstly, it has per force to badly 
confuse the student and the casual user: the fact that these concepts 
didn't make it to the index is specially problematic, and also very significant. 
And, second- and more importantly, it does not promote to a sufficiently visible 
place two concepts which are indeed fundamental. After all, the first thing 
you will have to do when writing a ooRexx application is to create one or more source programs, 
and these programs will for sure have to contain one or more code bodies.

This lack of definition will unavoidably carry over to the rest of the ooRexx literature, 
and to other applications designed for the ooRexx ecosystem.

For example, if I have to write a book about ooRexx, how should I call code bodies? 
I can of course repeat the same error of rexxref and call them by different names in my book; 
but, if I want to be coherent, I will have to make a choice. 
Say that I choose "code body", for example. But then my colleague X writes another book about ooRexx, 
and, since she is faced with the same problem, she decides to call these entities 
"code units" -- after all, she's justified in doing so. By rexxref itself. 
As I am too, of course. But then rexxref has become a source of confusion, 
which is contrary to its own spirit. 

Something similar happens with applications. For example, I wrote a parser for ooRexx, 
and I had to assign a name to every syntactical construct I had to handle. 
I chose "code bodies", but maybe I should have chosen "code units". 
I cannot know, because this is not defined. If one day the definitions
are standardized and "code unit" is elected as the name for the corresponding concept, 
I will have to revisit my code and update it accordingly.

Please note that some of these doubts and ambiguities are not new at all. 
For example, we can find an editorial comment in the Dallas draft of the 
Extended Rexx programming language that states that 
"There are terminology decisions to make about "files", "programs", and "packages". 
Possibly "program" is the thing you run (and we don't say what it means physically), 
"file" is a unit of scope (ROUTINEs in current file before those in REQUIREd), 
and "package" we don't use (since a software package from a shop would probably 
have several files but not everything to run a program.) Using "file" this way 
may not be too bad since we used "stream" rather than "file" in the classic definition".

## What I think should be done

I think we should:

+ Discuss and agree about some form of standard nomenclature about "code bodies" and "source programs" (and other concepts too,
  of course, but this will be the subject of subsequent emails).
+ Update the official ooRexx nomenclature accordingly.
+ Produce EBNF fragments defining these concepts. 
  + In some cases, these EBNF fragments should be produced in two different flavours:
    one for language and tool implementers, and another one to create nice railroad diagrams.
    In many cases, what's adequate to be shown on a page is unnatural for a formal EBNF document, and vice versa.

Please note that 

+ Classic Rexx has a BNF specification (in the ANSI standard), but this obviously does not cover ooRexx extensions.
+ The Dallas draft of the Extended Rexx language does have a EBNF, but this applies to a language
  which is different enough from ooRexx to render it useless for our purposes. 
+ The BNF fragments that do exist in the ooRexx source code tree are only there
  to produce the syntax diagrams which appear in the manuals,
  not as a language definition and reference.
  In particular, they are not available to the general user (without downloading the source code tree, that is).

To start the discussion, I would propose to standardize on "code bodies" 
("code units" would also be fine to me) and "source programs". And regarding the BNF, I would write

```ebnf
ooRexx_program ::= source_program
source_program ::= (prolog)? (directive [code_body])*
prolog         ::= code_body
```

Of course, we should differentiate between directives that allow a body afterwards, and directives that don't, but you get the idea.

What do you think? Ideas and comments welcome.
