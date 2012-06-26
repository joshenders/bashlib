bashlib
=======

The reusability of Bash can be debated but there _are_ times when I'd like to
document some of my more heroic efforts. This is my attempt to do so.

> Functions. Bash's "functions" have several issues:
> * **Code reusability:** Bash functions don't return anything; they only produce output streams. Every reasonable method of capturing that stream and either assigning it to a variable or passing it as an argument requires a SubShell, which breaks all assignments to outer scopes. (See also BashFAQ/084 for tricks to retrieve results from a function.) Thus, libraries of reusable functions are not feasible, as you can't ask a function to store its results in a variable whose name is passed as an argument (except by performing eval backflips).
> * **Scope:** Bash has a simple system of local scope which roughly resembles "dynamic scope" (e.g. Javascript, elisp). Functions see the locals of their callers (like Python's "nonlocal" keyword), but can't access a caller's positional parameters (except through BASH_ARGV if extdebug is enabled). Reusable functions can't be guaranteed free of namespace collisions unless you resort to weird naming rules to make conflicts sufficiently unlikely. This is particularly a problem if implementing functions that expect to be acting upon variable names from frame n-3 which may have been overwritten by your reusable function at n-2. Ksh93 can use the more common lexical scope rules by declaring functions with the "function name { ... }" syntax (Bash can't, but supports this syntax anyway).
> * **Closures:** In Bash, functions themselves are always global (have "file scope"), so no closures. Function definitions may be nested, but these are not closures, though they look very much the same. Functions are not "passable" (first-class), and there are no anonymous functions (lambdas). In fact, nothing is "passable", especially not arrays. Bash uses strictly call-by-value semantics (magic alias hack excepted).
>
> There are many more complications involving: subshells; exported functions; "function collapsing" (functions that define or redefine other functions or themselves); traps (and their inheritance); and the way functions interact with stdio. Don't bite the newbie for not understanding all this. Shell functions are totally f***ed.

-- http://mywiki.wooledge.org/BashWeaknesses