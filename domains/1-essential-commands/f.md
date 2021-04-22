## Analyze text using basic regular expressions

A regular expression (shortened as **regex**) is a sequence of characters that specifies a search pattern. For an overview on regular expressions, look [here](https://www.regular-expressions.info/quickstart.html). [Here](https://regexone.com/) you can find an interactive tutorial to learn the basic of regex syntax.

Common regex characters:

| Symbol | Function |
| ----------- | ----------- |
| `.` | matches any single character (except newlines, normally) |
| `\` | escape a special character (e.g. `\.` matches a literal dot) |
| `?` | the preceding character may or may not be present (e.g. `/hell?o/` would match `hello` or `helo`) |
| `*` | any number of the preceding character is allowed (e.g. `.*` will match any single-line string, including an empty string, and gets used a lot) |
| `+` | one or more of the preceding character (`.+` is the same as `.*` except that it won’t match an empty string) |
| `|` | “or”, matches the preceding section or the following section (e.g. `hello|mad` will match `hello` or `mad`) |
| `()` | group a section together, this can be useful for conditionals (`(a|b)`), multipliers (`(hello)+`), or to create groups for substitutions |
| `{}` | specify how many of the preceding character (e.g. `a{12}` matches 12 `a`s in a row) |
| `[]` | match any character in this set. - defines ranges (e.g. `[a-z]` is any lowercase letter), `^` means "not" (e.g. `[^,]+` match any number of non-commas in a row) |
| `^` | beginning of line |
| `$` | end of line |

The three major dialects every programmer should know are:

- basic regular expressions (BRE)
- extended regular expressions (ERE)
- Perl-compatible regular expressions (PCRE).

Essentials text stream processing tools to use in conjunction with regex patterns are:

- **grep**, filters its input against a pattern;
- **sed**, applies transformation rules to each line; and
- **awk**, manipulates an ad hoc database stored as text, e.g. CSV files.

### 1. grep

The `grep` tool can filter a file, line by line, against a pattern. By default, grep uses basic regular expressions (BRE). BRE differs syntactically in several key ways. Specifically, the operators `{}`, `()`, `+`, `|` and `?` must be escaped with `\`.

Useful grep flags:

- `-v`, inverts the match
- `--color(==always)`, colors the matched text
- `-F`, interprets the pattern as a literal string
- `-H`, `-h`, prints (or doesn't print) the matched filename
- `-i`, matches case insensitively
- `-l`, prints names of files that match instead
- `-n`, prints the line number
- `-w`, forces the pattern to match an entire word
- `-x`, forces patterns to match the whole line.

The `egrep` tool is identical to grep, except that it uses extended regular expressions (actually, equivalent to `grep -E`). Extended regular expressions are identical to basic regular expressions, but the operators `{}`, `()`, `+`, `|` and `?` should not be escaped. 

PCREs can be used by means of the `-P` flag of `grep`. Perl has a richer and more predictable syntax than even the extended regular expressions syntax. 

>Tip: If you have a choice, always use Perl-style regex.

Examples:
```
# search for a string in one or more files
----------------------------------------
grep 'fred' /etc/passwd                             # search for lines containing 'fred' in /etc/passwd
grep fred /etc/passwd                               # quotes usually not when you don't use regex patterns
grep null *.scala                                   # search multiple files

# case-insensitive
----------------
grep -i joe users.txt                               # find joe, Joe, JOe, JOE, etc.

# regular expressions
-------------------
grep '^fred' /etc/passwd                            # find 'fred', but only at the start of a line
grep '[FG]oo' *                                     # find Foo or Goo in all files in the current dir
grep '[0-9][0-9][0-9]' *                            # find all lines in all files in the current dir with three numbers in a row

# display matching filenames, not lines
-------------------------------------
grep -l StartInterval *.plist                       # show all filenames containing the string 'StartInterval'

# show matching line numbers
--------------------------
grep -n we gettysburg-address.txt                   # show line numbers as well as the matching lines

# lines before and after grep match
---------------------------------
grep -B5 "the living" gettysburg-address.txt        # show all matches, and five lines before each match
grep -A10 "the living" gettysburg-address.txt       # show all matches, and ten lines after each match
grep -B5 -A5 "the living" gettysburg-address.txt    # five lines before and ten lines after

# invert the sense of matching
-------------------
grep -v fred /etc/passwd                            # find any line *not* containing 'fred'
grep -vi fred /etc/passwd                           # same thing, case-insensitive

# grep in a pipeline
------------------
ps aux | grep httpd                                 # all processes containing 'httpd'
ps aux | grep -i java                               # all processes containing 'java', ignoring case
ls -al | grep '^d'                                  # list all dirs in the current dir

# search for multiple patterns
----------------------------
egrep 'apple|banana|orange' *                       # search for multiple patterns, all files in current dir

# grep + find
-----------
find . -type f -exec grep -il 'foo' {} \;           # print all filenames of files under current dir containing 'foo', case-insensitive

# recursive grep search
---------------------
grep -rl 'null' .                                   # similar to the previous find command; does a recursive search
grep -ril 'null' /home/al/sarah /var/www            # search multiple dirs
egrep -ril 'aja|alvin' .                            # multiple patterns, recursive

# grep gzipped files
---------------
zgrep foo myfile.gz                                 # all lines containing the pattern 'foo'
zgrep 'GET /blog' access_log.gz                     # all lines containing 'GET /blog'
zgrep 'GET /blog' access_log.gz | less              # same thing, case-insensitive

# submatch backreferences to print out words that repeat themselves:
---------------
grep '^\(.*\)\1$' /usr/share/dict/words             # prints "beriberi, bonbon, cancan, ..."

# match text after a string, but excluding this string from the captured text (so called, "positive look-behind")
---------------
grep -P '(?<=name=)[ A-Za-z0-9]*' filename
```

For grep advanced features, look [here](https://caspar.bgsu.edu/~courses/Stats/Labs/Handouts/grepadvanced.htm).

### 2. sed

`sed` is a "stream editor", which reads a file line-by-line, conditionally applying a sequence of operations to each line and (possibly) printing the result.

By default, sed uses basic regular expression syntax. To use the (more comfortable) extended syntax, supply the flag `-E`.

Most sed programs consist of a single sed command: substitute (`s`). But a proper sed program is a sequence of sed commands. Most sed commands have one of three forms:

- *operation*, apply this operation to the current line
- *address operation*, apply this operation to the current line if at the specified address
- *address1,address2 operation*, apply this operation to the current line if between the specified addresses.
 
Useful operations:

- `{ operation1 ; ... ; operationN }`, executes all of the specified operations, in order, on the given address
- `s/pattern/replacement/arguments`, replaces instances of pattern with replacement according to the arguments in the current line (in the replacement, `\n` stands for the nth submatch, while `&` represents the entire match)
- `b`, branches to a label, and if none is specified, then sed skips to processing the next line (think of this as a break operation)
- `y/from/to/`, transliterates the characters in "from" to their corresponding character in "to"
- `q`, quits sed
- `d`, deletes the current line
- `w`, file writes the current line to the specified file.

Common arguments to the substitute operation:

- the most common argument to the substitute command is `g`, which means "globally" replace all matches on the current line, instead of just the first
- `n`, tells sed to replace the nth match only, instead of the first
- `p`, prints out the result if there is a substitution
- `i`, ignores case during the match
- `w file`, writes the current line to file.

Useful flags:

- `-n` suppresses automatic printing of each result; to print a result, use command `p`.
- `-f filename` uses the given file as the sed program.

Examples:
```
sed -n '1,13p;40p' <file>
sed '12q' <file>
sed -n '1,+4p' <file>
sed -n '1~5p' <file>   # "first~step" pattern matches a line every 5 lines starting from the first line
sed '1,3d' <file>   # deletes the first 3 lines from stdout (to overwrite the source file, use '-i' flag or '-i.bck' to backup the original file)
# do not use '-n' with (d), otherwise the original file wil be overriden with the empty stdout
sed '/pattern/d' <file> # delete all the lines matched by the given pattern
sed 's/up/down/' <file> # substitues the first occurence matched by the pattern on every line
sed 's/up/down/2' <file> # substitues only the second occurence on a line
sed -n 's/up/down/2p' <file>    # to see which lines would be modified
sed 's/^.*at/(&)/' <file>   # wraps the matched text into parentheses
sed -E 's/([A-Z][a-z]*), ([A-Z][a-z]*( [A-Z][a-z]*[.]?)?)/\2 \1/g' <file>  # use '\n' to reference the groups in the regex pattern
>Might, Matthew B.
>Matthew B. Might
```

### 3. awk

The `awk` command provides a more traditional programming language for text processing than `sed`. Those accustomed to seeing only hairy awk one-liners might not even realize that awk is a real programming language.

The major difference in philosophy between awk and sed is that awk is record-oriented rather than line-oriented. Each line of the input to awk is treated like a delimited record. The awk philosophy melds well with the Unix tradition of storing data in ad hoc line-oriented databases, e.g., /etc/passwd. The command line parameter `-F regex` sets the regular expression *regex* to be the field delimiter. 

An awk program consists of pattern-action pairs: `pattern { statements }`, followed by an (optional) sequence of function definitions.

In fact, an action is optional, and a pattern by itself is equivalent to: `pattern { print }`. As each record is read, each pattern is checked in order, and if it matches, then the corresponding action is executed. 

The form for function defintion is: `function name(arg1,...,argN) { statements }`

The patterns can have forms such as:

- `/regex/`, which matches if the regex matches something on the line
- `expression`, which matches if expression is non-zero or non-null
- `pattern1, pattern2`, a range pattern which matches all records (inclusive) between *pattern1* and *pattern2*
- `BEGIN`, which matches before the first line is read
- `END`, which matches after the last line is read.

Some implementations of awk, like `gawk`, provide additional patterns:

- `BEGINFILE`, which matches before a new file is read
- `ENDFILE`, which matches after a file is read.

A basic awk expression is either:

- a special variable (`$1` or `NF`)
- a regular variable (`foo`)
- a string literal (`"foobar"`)
- a numeric constant (`3`, `3.1`)
- a regex constant (`/foo|bar/`).

There are several special variables in AWK:

| Variable | Meaning |
| ----------- | ----------- |
| $0 | the entire text of the matched record |
| $n | the nth entry in the current record |
| FILENAME | name of current file |
| NR | number of records seen so far |
| FNR |number of records so far in this file |
| NF | number of fields in current record |
| FS | input field delimiter, defaults to whitespace |
| RS | record delimiter, defaults to newline |
| OFS | output field delimiter, defaults to space |
| ORS | output record delimiter, defaults to newline |

awk is a small language, with only a handful of forms for statements.

The man page lists all of them:

- if (expression) statement [ else statement ]
- while (expression) statement
- for (expression; expression; expression) statement
- for (var in array) statement
- do statement while (expression)
- break
- continue
- { [ statement ... ] }
- expression  
- print [ expression-list ] [ > expression ]
- printf format [ , expression-list ] [ > expression ]
- return [ expression ]
- next             
- nextfile
- delete array[expression]
- delete array            
- exit [ expression ] 

The most common statement is `print`, which is equivalent to `print $0`. 

Useful flags:

- `-f filename`, uses the provided file as the awk program
- `-F regex`, sets the input field separator
- `-v var=value`, sets a global variable (multiple `-v` flags are allowed).

Examples:
```
ps aux | awk '{print $1}'   # prints the first column
ps aux | awk '{printf("%-40s %s\n", $2, $11)}' # prints the first column with a 40 chars right-padding
ps aux | awk '/firefox/' # filters records by regex pattern
ps aux | awk '$2==1645'  # filters records by field comparison
ps aux | awk '$2 > 2100'    # filters records by numeric comparison
ps aux | awk '/firefox/ && $2 > 2100' # combines a regex pattern with a math operator
ps aux | awk 'BEGIN {printf("%-26s %s\n", "Command", "CPU")} $3>10 {print $11, $3}' # adds a header before processing any data
ps aux | awk '{printf("%s %4.0f MB\n", $11, $6/1024)}'  # controls scale and rounds up
ps aux | awk 'BEGIN {sum=0} /firefox/ {sum+=$6} END {printf("Total memory consumed by Firefox: %.0f MB\n", sum/1024)}'  # sums field values in a column
ps aux | awk 'BEGIN {i=1; while (i<6) {print "Square of", i, "is", i*i; ++i}}'  # to use a while loop
```