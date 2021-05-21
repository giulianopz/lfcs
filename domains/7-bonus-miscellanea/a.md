## bash

Variables have a dual nature since eache variable is also an array.

To define a variable, simply: `foo=42`

To reference the value of a variable: `echo $foo`

To remove a variable= `unset foo`

To assign a value which contains spaces, quote it: `foo="x j z"`

Since every variable is an array, the variable itself is an implicit reference to the first index (0), so:
```
echo $foo
# equals to
echo ${foo[0]}
```

> Note: Wrap the variable into curly braces for variable/array manipulation.

You can declare an array with explicitly or with parenthes:
```
declare -a array_name
array_name[index_1]=value_1
array_name[index_2]=value_2
array_name[index_n]=value_n
# or
array_name=(value_1, value_2, value_n)
```

To access all elements in an array:
```
echo ${array[@]}
# or
echo ${array[*]}
```

To copy an array: `copy=("${array[@]}")`

> Note: double quotes are needed for values conaining white spaces.

Special variables for grabbing arguments in functions and scripts:
```
$0          # script or shell name
$[1-9]      # print the nth arg (1 <= n <= 9)
$#          # the number of args
$@          # all args passed
$*          # same, but with a subtle difference, see below
$?          # exit status of the previously run command (if !=0, it's an error)
$$          # PID of the current shell
$!          # PID of the most recently backgrounded process
```

> Note: To know if you are in a subshell: `echo $SHLVL`

bash can operate on the value of a variable while deferencing that same variable:
```
foo="I'm a cat"
echo ${foo/cat/dog}
```

To replace all instances of a string: `echo ${foo//cat/dog}`

> Note: a replacement operation does not modify the value of the variable.

To delete a substring: `echo ${foo/cat}`

`#` and `##` remove the shortest and longest prefix of a variable matching a certain pattern:
```
path="/usr/bin:/bin:/sbin"
echo ${path#/usr}           # prints out "/bin:/bin:/sbin"
echo ${path#*/bin}          # prints out ":/bin:/sbin"
echo ${path##*/bin}         # prints out ":/sbin"

```

Similarly, `%` is used for suffuxes.

bash operators operate on both strings and array, so avoid common mistakes such as:
```
echo ${#array}          # wrong: prints out the length of the first element of the array (chars in a string)
echo ${#array[@]}       # right: prints out the size of the array
```

To slice strings and arrays:
```
echo ${string:6:3}          # the first num is the start index, the second one is the size of slice
echo ${array[@]:3:2} 
```

Existence testing operators:
```
echo ${username-defualt}        # prints "default" if username var in unset
echo ${username:-defualt}       # checks both for existence and emptiness
echo ${unsetvar:=resetvar}      # like "-", but sets the var if it doesn't have a value
echo ${foo+42}                  # prints "42" if foo is set
echo ${foo?failure: no args}    # crashes the program with the given message, if the var is unset
```

`!` operator is used for **indirect lookup** or (indirect reference):
```
foo=bar
bar=42
echo ${!foo}        # print $bar, that is "42"
```

similarly, with arrays:
```
letters=(a b c d e)
char=letters[1]
echo ${!char}       # prints "b"
```

As to string declaration, you can use:

- single quotes (`'`) for literal strings
- double quotes (`"`) for interpolated strings

Mathematical expressions can be declared as follows:
```
echo $((3 + 3))
# or
((x = 3 + 3)); echo $x
```

To explicitly declare an integer variable:
```
declare -i number
number=2+4*10
```

To dump textual content directly into stdin:
```
# a file
grep [pattern] < myfile.txt
# a string
grep [pattern] <<< "this is a string"
# a here-document
grep [pattern] <<EOF
first line
second line
etc
EOF
```

The notation `M>&N` redirects the output of channel M to channel N, e.g. to redirect stderr to stdout: `2>&1`

> Note: in bash, `&>` equals to `2>&1`.

> Note: `>` is the same as `1>`.

To learn more about redirections, look [here](../1-essential-commands/e.md).

Capturing stdout can be accomplished as:
```
echo `date`
# or
echo $(date)
```

**Process substitution** involves expanding output of a command into a temporary file which can be read from a command which expects a file to be passed:
```
cat <(uptime)
# which works as
uptime | cat
```

`wait` command waits for a PID's associated process to terminate, but without a PID it waits for all child processes to finish (e.g, it can be used after multiple processes are launched in a for loop):
```
time-consuming-command &
pid=$!
wait $pid
echo Process $pid finished!

for f in *.jpg
do 
  convert $f ${f%.jpg}.png &
done 
wait
echo All images have been converted!
```

**Glob patterns** are automatically expanded to an array of matching strings:

- `*`, any string
- `?`, a single char
- `[aGfz]`, any char between square brackets
- `[a-d]`, any char between `a` and `d`

**Brace expansion** is used to expand elements inside curly braces into a set or sequence:
```
mkdir /opt/{zotero, skype, office}
# or
echo {0..10}
```

### Control Structures

Conditions are expressed as a command (such as `test`) whose exit status is mapped to true/false (0/non-zero):
```
if http -k start
then 
  echo OK
else
  echo KO
fi
# or

if [ "$1" = "-v" ]
then
  echo "switching to verbose output"
fi
```

> Note: An alternative syntax for `test [args]` is `[args]`.

> Tip: Double brackets are safer than single brackets:
  ```
  [ $a = $b ]         # will fail if one of the two variables is empty or contains a whitespace
  [ "$a" = "$b" ]     # you have to double-quote them to avoid this problem
  [[ $a = $b ]]       # this instead won't fail
  ``` 
> Tip: Additionally, double brackets support:
  ```
  [[ $a = ?at ]]      # glob patterns
  [[ $a < $b ]]       # lexicographical comparison
  [[ $a =~ ^.at ]]    # regex patterns with the operator "=~"
  ```
  To learn more, look [here](https://scriptingosx.com/2018/02/single-brackets-vs-double-brackets/).

Iterations are declared as follows.
```
while [command]; do [command]; done
# or
for [var] in [array]; do [command]; done
```

Subroutine (functions) act almost like a separate script. They can see and modify variable defined in the outer scope:
```
funcion <name> {
  # commands
}

# or

<name> () {
  # commands
}
```

### Array syntax

```
arr=()                  # creates an empty array
arr=(1 2 3)             # creates and initializes an array
${arr[2]}               # retrieves the 3rd element
${arr[@]}               # retrieves all element
${!arr[@]}              # retrieves array indices
${#arr[@]}              # get array size
arr[0]=3                # overwrites first element
arr+=(4)                # appends a value
arr=($(ls))             # saves ls output as an array of filenames
${arr[@]:s:n}           # retieves [n] elements starting at index [s]
```

> Note: Beware of array quirks  when using `@` vs. `*`:
  - `*` combines all args into a single string, while `@` requotes the individual args
  - if the var IFS (internal field separator) is set, then elements in `$*` are separated by this deimiter value.

### Test flag operators

```
# boolean conditions
-a      # &&
-o      # ||

# integer comparison
-eq     # "equals to"
-ne     # "not equal"
-gt     # >
-ge     # >=
-lt     # <
-le     # <=

# string comparison
=
==      # the pattern is literla if within double brackets and variables/string are within double quotes
!=
<       # alphabetical order
>       # must be escaped if within single brackets, e.g. "\>"
-z      # string is null
-n      # string is not null

# file test

-e      # file exists
-f      # file is a regular file
-d      # is a directory
-h/-L   # is a symlink
-s      # is not zero-size
-r      # has read permissions
-w      # has write permissions
-x      # has execute permissions
-u      # SUDI bit is active
-g      # SGID bit is active
-k      # sticky bit is active
-nt/ot  # is newer/older than
```

---

This refresher is mostly based on a nice [guide](http://matt.might.net/articles/bash-by-example/) written by Matt Might.

You can find [here](https://github.com/dylanaraps/pure-bash-bible) a huge collection of bash gems.