# The encoding/decoding model

This directory contains the main encoding class, ``Encoding.cls``, and a growing set of particular encoding classes. 

## The Encoding class

The Encoding class is the base class for all encodings, and all encoding classes should subclass Encoding.

The Encoding class implements a series of services common to all encodings (like _the encoding registry_), and defines a set of common interfaces (a contract) that all encodings have to follow.

## The Encoding registry and contract

The Encoding class and its subclasses operate under the following contract. All subclasses must adhere to this contract to work properly.

* Subclasses of ``Encoding`` must reside each in a separate ``.cls`` file, and these files must be located in the same directory where ``Encoding.cls`` is located.
* At initialization time, the ``Encoding`` class will register itself in the ``.local`` directory by using ``.local~encoding = .Encoding``.
  This allows encoding subclasses to subclass Encoding without having to use the ``::Requires`` directive.
* ``Encoding`` will then call all the ``.cls`` files that reside in its own directory, except itself. This will give all subclasses an opportunity to register with the ``Encoding`` class.
* Each subclass ``myEncoding`` must use its prolog to register with the ``Encoding`` class, by issuing the following method call: ``.Encoding~register(.myEncoding)``.
* ``Encoding`` will then inspect the ``name`` and ``aliases`` constants of the ``myEncoding`` class, check that there are no duplicates, and, if no errors are found, it will register these names appropriately.
* From then on, the new ``myEncoding`` encoding will be accesible as the value of the ``.Encoding[name]`` method call (note the square brackets), where ``name``
  is the (case-insensitive) value of ``myEncoding``'s name, or of any of its ``aliases``.

## Attributes and methods

### [] (class method)

```
   ╭───╮  ┌──────┐                       ╭───╮
▸▸─┤ [ ├──┤ name ├─┬───────────────────┬─┤ ] ├─▸◂
   ╰───╯  └──────┘ │ ╭───╮  ┌────────┐ │ ╰───╯
                   └─┤ , ├──┤ option ├─┘
                     ╰───╯  └────────┘
```

Returns the encoding class object uniquely identified by _name_, the encoding name or alias to resolve, according to the ``Encoding`` refistry. The behaviour of the method
when _name_ is not found depends on the value of the optional argument _option_. When _option_ is __SYNTAX__ (the default) and _name_ is not
found, a syntax error is raised. When _option_ is __NULL__ or the null string (__""__), a null string is returned.

### aliases (abstract getter class method)

```
   ╭─────────╮             
▸▸─┤ aliases ├──▸◂
   ╰─────────╯  
```

In addition to a _name_, an encoding may also have a set of case-insensitive _aliases_. The encoding can be uniquely identified by its _name_, or by any of its _aliases_. The ``Encoding`` class keeps a registry of all the names and aliases of all encodings, takes care that there are no duplicates, and resolves names to their corresponding classes.

Aliases can specified either as a one-dimensional array of strings, or as a blank separated string of words.

### bytesNeededForChar (abstract class method)

```
   ╭─────────────────────╮  ┌────────┐  ╭───╮
▸▸─┤ bytesNeededForChar( ├──┤ string ├──┤ ) ├─▸◂
   ╰─────────────────────╯  └────────┘  ╰───╯
```

Returns 0 if _string_ is a complete character, or the number of bytes remaining to get a complete character. For example, if the encoding is UTF-16 and the argument _string_ is a lone high surrogate, 
the _bytesNeededForChar_ method will return __2__.

Please note that the fact that a character is complete does not imply that it is well-formed or valid.

### bytesPerChar (abstract getter class method)

```
   ╭──────────────╮             
▸▸─┤ bytesPerChar ├──▸◂
   ╰──────────────╯  
```

For fixed-length encodings, this is the length in bytes of one character. For variable-length encodings, this is the minimum length in bytes of a character.

### bytesNeededForChar (class method)

```
   ╭────────────╮  ┌──────┐  ╭───╮
▸▸─┤ checkCode( ├──┤ code ├──┤ ) ├─▸◂
   ╰────────────╯  └──────┘  ╰───╯
```

This utility method checks to see if its its argument, _code_, is a valid hexadecimal Unicode codepoint, and raises a syntax condition if it is not. Surrogate codepoints are only accepted when the _allowSurrogates_ constant is set to ``.true`` for this particular class.

### endOfLine (abstract getter class method)

```
   ╭───────────╮             
▸▸─┤ endOfLine ├──▸◂
   ╰───────────╯  
```

Each encoding can define its own end-of-line sequence.

### isFixedLength (abstract getter class method)

```
   ╭───────────────╮             
▸▸─┤ isFixedLength ├──▸◂
   ╰───────────────╯  
```

An encoding can be __fixed-__ or __variable length__. For example, IBM850 is (1-byte) fixed length, as is UTF-32 (4-byte), but UTF-8 is variable-length (1 to 4 bytes).

The fact that an encoding is variable-length can have notable influence on the behaviour and performance of certain stream BIFs. In particular, some of these behaviours can become extremely expensive, and others may be entirely disallowed by the implementation.

### maxBytesPerChar (abstract getter class method)

```
   ╭─────────────────╮             
▸▸─┤ maxBytesPerChar ├──▸◂
   ╰─────────────────╯  
```

For fixed-length encodings, this is the length in bytes of one character. For variable-length encodings, this is the maximum length in bytes of a character.

### name (abstract getter class method)

```
   ╭──────╮             
▸▸─┤ name ├──▸◂
   ╰──────╯  
```

An encoding has an official _name_, a case-insensitive label by which it may be uniquely identified.
