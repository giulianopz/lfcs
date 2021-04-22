## Compare and manipulate file content

Create a file: `touch <filename>`

Or: `echo "you've got to hide your love away" > filename`

Compare two files: `diff <file1> <file2>`

Compare two dirs: `diff -ur <dir1> <dir2>`

Report or remove repeated lines: `uniq <filename>`

Sort lines by reverse numeric order: `ps aux | sort -k2 -r -n`

Print second and third columns from file using comma as a field separator: `cut -d ',' -f 2,3 <file.csv>`

Replace comma with semicolon as field separator: `tr ',' ';' < <file.csv>`

Replace all consecutive occurrences of space with a single space: `cat file | tr -s ' '`

Print file with line numbers: `nl -ba <filename>`

Count lines in a file: `wc -l <filename>`

Identify the type of a file:
```
file <file>.csv 
<file>.csv: CSV text
```

Display text both in character and octal format: `od -bc <filename.txt>`

> Tip: Useful for debugging texts for unwanted chars or to visualize data encoded in a non-human readable format (e.g. a binary file).

Change file name (`-n` for dry-run): `rename -n "s/cat/dog/g" cat.txt`

Apply uniform spacing between words and sentencese: `fmt -u <filename>`

Merge file side by side: `paste <file1> <file2>`

Paginate a file for printing: `pr <filename>`

Join two files which have a common join field:
```
cat foodtypes.txt
>1 Protein
>2 Carbohydrate
>3 Fat

cat foods.txt
>1 Cheese 
>2 Potato
>3 Butter

join foodtypes.txt foods.txt
>1 Protein Cheese
>2 Carbohydrate Potato
>3 Fat Butter
```

To join files using different fields, the `-1` and `-2` flags (or `-j` if it's the same char or position) options can be passed to join:
```
cat wine.txt
>Red Beaunes France
>White Reisling Germany
>Red Riocha Spain

cat reviews.txt
>Beaunes Great!
>Reisling Terrible!
>Riocha Meh

join -1 2 -2 1 wine.txt reviews.txt
>Beaunes Red France Great!
>Reisling White Germany Terrible!
>Riocha Red Spain Meh
```

Join expects that files will be sorted before joining, so you have to sort them if the lines are not in the right order:
`join -1 2 -2 1 <(sort -k 2 wine.txt) <(sort reviews.txt)`

Split a file into N files based on size of input: `split -n <x> <filename>`

Use `expand` or `unexpand` to convert from tabs to the (equivalent number of) spaces and viceversa.

To tabs N characters apart, instead of the default of 8: `expand --tabs=<n> <filename>`