# The encoding/decoding model

This directory contains the main encoding class, ``Encoding.cls``, and a growing set of particular encoding classes. 

## The Encoding class

The Encoding class is the base class for all encodings, and all encoding classes should subclass Encoding.

The Encoding class implements a series of services common to all encodings (like _the encoding registry_), and defines a set of common interfaces (a contract) that all encodings have to follow.

### The Encoding registry and contract

The Encoding class and its subclasses operate under the following contract. All subclasses must adhere to this contract to work properly.

* Subclasses of ``Encoding`` must reside each in a separate ``.cls`` file, and these files must be located in the same directory where ``Encoding.cls`` is located.
* At initialization time, the ``Encoding`` class will register itself in the ``.local`` directory by using ``.local~encoding = .Encoding``.
  This allows encoding subclasses to subclass Encoding without having to use the ``::Requires`` directive.
* ``Encoding`` will then call all the ``.cls`` files that reside in its own directory, except itself. This will give all subclasses an opportunity to register with the ``Encoding`` class.
* Each subclass ``myEncoding`` must use its prolog to register with the ``Encoding`` class, by issuing the following method call: ``.Encoding~register(.myEncoding)``.
* ``Encoding`` will then inspect the ``name`` and ``aliases`` constants of the ``myEncoding`` class, check that there are no duplicates, and, if no errors are found, it will register these names appropriately.
* From then on, the new ``myEncoding`` encoding will be accesible as the value of the ``.Encoding[name]`` method call (note the square brackets), where ``name``
  is the (case-insensitive) value of ``myEncoding``'s name, or of any of its ``aliases``.
