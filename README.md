# bashlib

The reusability of Bash can be debated[1] but there _are_ times when I'd like to document some of my more heroic efforts. This is my attempt to do so.

## `format_seconds()`

> `usage: format_seconds <seconds>`

*Example:*

```sh
$ format_seconds 86399
23h59m59s
```

## `compare_versions()`

> `usage: compare_versions <version1> <version2>`

*Example:*

```sh
$ compare_versions "1.0" "1.0"
$ echo $?
0

$ compare_versions "1.0" "2.0"
$ echo $?
1

$ compare_versions "3.0.0.0" "2.0"
$ echo $?
2
```

```sh
result=$(compare_versions "${installed}" "${target}"; echo $?)
```

## `check_dependencies()`

> `usage: check_dependencies <space separated list of external programs>`

*Example:*

```sh
check_dependencies "aws black cat docker find git grep python3 sed shellcheck tee xargs"
...
my_great_script.sh: Could not find "aws" in $PATH. Please verify that "aws" is installed before running this script
```

## `prompt()`

> `usage: prompt <message>`

*Example:*

```sh
$ prompt "Is this a good prompt message?"
Is this a good prompt message? [y/n] n
$ echo $?
1

$ prompt "Is this a good prompt message?"
Is this a good prompt message? [y/n] y
$ echo $?
0
```

## `top_level_parent_pid()`

> `usage: top_level_parent_pid [pid]`

*Example:*

```sh
$ echo $PPID
40105
$ echo $$
40106
$ bash
$ echo $PPID
40106
$ echo $$
40109
$ top_level_parent_pid
3357
$ pstree --show-parents $$ --show-pids
systemd(1)───sshd(3357)───sshd(40098)───sshd(40105)───bash(40106)───bash(40109)───pstree(40121)
```

## `exit_with_error()`

> `usage: exit_with_error <message>`

*Example:*

```sh
my_very_important_command || exit_with_error "[CRITICAL]\tAn error has occured."
```

## `exit_with_usage()`

> `usage: exit_with_usage()`

```sh
Usage: my_great_script.sh [options] <arg>

Options:
    -a N, --apple=N    Do a thing
    -b,   --banana     Do another thing
```

---

## Footnotes

* [1] <http://mywiki.wooledge.org/BashWeaknesses>

> Bash's "functions" have several issues:
>
> **Code reusability:** Bash functions don't return anything; they only produce output streams. Every reasonable method of capturing that stream and either assigning it to a variable or passing it as an argument requires a SubShell, which breaks all assignments to outer scopes. (See also BashFAQ/084 for tricks to retrieve results from a function.) Thus, libraries of reusable functions are not feasible, as you can't ask a function to store its results in a variable whose name is passed as an argument (except by performing eval backflips).
>
> **Scope:** Bash has a simple system of local scope which roughly resembles "dynamic scope" (e.g. Javascript, elisp). Functions see the locals of their callers (like Python's "nonlocal" keyword), but can't access a caller's positional parameters (except through BASH_ARGV if extdebug is enabled). Reusable functions can't be guaranteed free of namespace collisions unless you resort to weird naming rules to make conflicts sufficiently unlikely. This is particularly a problem if implementing functions that expect to be acting upon variable names from frame n-3 which may have been overwritten by your reusable function at n-2. Ksh93 can use the more common lexical scope rules by declaring functions with the "function name { ... }" syntax (Bash can't, but supports this syntax anyway).
>
> **Closures:** In Bash, functions themselves are always global (have "file scope"), so no closures. Function definitions may be nested, but these are not closures, though they look very much the same. Functions are not "passable" (first-class), and there are no anonymous functions (lambdas). In fact, nothing is "passable", especially not arrays. Bash uses strictly call-by-value semantics (magic alias hack excepted).
>
> There are many more complications involving: subshells; exported functions; "function collapsing" (functions that define or redefine other functions or themselves); traps (and their inheritance); and the way functions interact with stdio. Don't bite the newbie for not understanding all this. Shell functions are totally f***ed.
