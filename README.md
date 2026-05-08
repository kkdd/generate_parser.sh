# generate_parser.sh

The script converts declarative option definitions into portable `while-case` style parsing code.


### example definition for input
```
OPTIONS="Options:
  -h, --help         Show this usage and exit. (variable 'help_enabled')
  -d, --debug        Enable debug mode. (variable 'debug_enabled')
  -l, --loops N      Set the number of loops. (variable 'loops_var')
  -m, --mammal NAME  Set mammal name. (variable 'mammal_var')
"
```
