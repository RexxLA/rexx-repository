# The #include C/C++ directive in Visual Studio

The #include directive allows two forms:

* `#include <path-spec>` (the "quoted form"), and
* `#include "path-spec"` (the "angle bracket form").

Here's the description of the search order for the quoted form ([source](https://learn.microsoft.com/en-us/cpp/preprocessor/hash-include-directive-c-cpp?view=msvc-170))

> The preprocessor searches for include files in this order:
>
>1. In the same directory as the file that contains the `#include` statement.
>2. In the directories of the currently opened include files, in the reverse order in which they were opened. The search begins in the directory of the parent include file and continues upward through the directories of any grandparent include files.
>3. Along the path that's specified by each `/I` compiler option.
>4. Along the paths that are specified by the `INCLUDE` environment variable.

The angle bracket form uses only the last two items of the above search.

Points to note:

1. The notion of the "same" directory appears naturally in the field of compiled languages.
2. Item no. 2 of the search order above is _recursive_. This means that the set of "known" places to search, in itself an extension of the "same" directory, growns dynamically as the different include levels are being processed.

