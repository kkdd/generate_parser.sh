#!/bin/sh

# usage
#  $ echo "$OPTIONS" | ./generate_parser.sh

# sample input
OPTIONS="Options:
  -h, --help         Show this usage and exit. (variable 'help_enabled')
  -d, --debug        Enable debug mode. (variable 'debug_enabled')
  -l, --loops N      Set the number of loops. (variable 'loops_var')
  -m, --mammal NAME  Set mammal name. (variable 'mammal_var')
"

OPTIONS="$(cat "$@")"

# generate arg_parser.sh
printf '%s\n\n' '#!/bin/sh
TRUE="true"
warning=""
append_warning_f() { [ -z "$warning" ] && warning="$1" || warning="$warning$(printf "\n%s" "$1")"; }'

# while-case loop with shift
printf '%s\n' 'while [ $# -gt 0 ]; do
  case "$1" in'

printf '%s\n' "$OPTIONS" |
while IFS= read -r line; do
  case "$line" in
    *"(variable '"*"')"*) ;;
    *) continue ;;
  esac

  # remove leading spaces
  line=${line#"${line%%[! ]*}"}

  # extract variable name
  var=${line##*"(variable '"}
  var=${var%%"')"*}

  # extract option specification part
  spec=${line%%"  "*}

  # remove commas
  spec=$(printf '%s\n' "$spec" | tr -d ',')

  # split words
  set -- $spec

  short_opt=$1
  long_opt=$2

  # detect argument existence
  if [ $# -le 2 ]; then  # noarg
    printf '    %s|%s)  %s=$TRUE;;\n' "$short_opt" "$long_opt" "$var"
  else
    printf '    %s|%s)  { [ $# -ge 2 ] && [ "${2#-}" = "$2" ]; } && { %s=$2; shift; } || append_warning_f "missing value for $1";;\n' "$short_opt" "$long_opt" "$var"
    printf '    %s*|%s=*) %s="$1"; for p in %s %s=; do %s="${%s#"$p"}"; done;;\n' "$short_opt" "$long_opt" "$var" "$short_opt" "$long_opt" "$var" "$var"
  fi
done

printf '%s\n\n' '    -[!-][!-]*)  rest_flags=${1#??}; first_flag="${1%"$rest_flags"}"; shift; set -- "$first_flag" "-$rest_flags" "$@"; continue;;
    --)  shift; break;;
    -*)  append_warning_f "unknown option: $1";;
    *)  break;;
  esac
  shift
done'

printf '%s\n' '[ -n "$warning" ] && { printf "%s\n" "$warning" | sed "s/^/- /" >&2; exit 1; }'
