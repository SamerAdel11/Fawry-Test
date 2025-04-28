# Parse Options
parse_options_and_args() {
  while getopts "nv" opt; do
    case $opt in
      n) n_flag=true ;;
      v) v_flag=true ;;
      *) echo "Usage: $0 [-n] [-v] search_word filepath"; exit 1 ;;
    esac
  done
}

# Validate passed arguments
validate_input() {
  if [ $# -lt 2 ]; then
    echo "Must have 2 arguments, $# specified"
    exit 1
  fi
}

# Iterate over the file line by line
find_word() {
  line_index=0
  while read -r line; do
    process_line "$line" "$line_index"
    ((line_index++))
  done < "$1"
}

# Search for the word
process_line() {
  local line="$1"
  local line_index="$2"
  local found_word=false

  for word in $line; do
    lowercase_word=$(echo $word | tr 'A-Z' 'a-z')
    if $v_flag; then
      if [ "$lowercase_search_word" == "$lowercase_word" ]; then
        found_word=true
        break
      fi
    else
      if [ "$lowercase_search_word" == "$lowercase_word" ]; then
        highlight_and_print "$line" "$line_index" "$word"
        found_word=true
        break
      fi
    fi
  done

  if $v_flag && ! $found_word; then
    print_line "$line" "$line_index"
  fi
}

# HIghlight the matched word and echo the line if found
highlight_and_print() {
  local line="$1"
  local line_index="$2"
  local word="$3"
  highlighted_line=$(echo -e "$line" | sed "s/\b$word\b/\\\e[31m&\\\e[0m/g")
  if $n_flag; then
    echo -e "$((line_index + 1)): $highlighted_line"
  else
    echo -e "$highlighted_line"
  fi
}
# Print the line as it is 
print_line() {
  local line="$1"
  local line_index="$2"
  if $n_flag; then
    echo "$((line_index + 1)): $line"
  else
    echo "$line"
  fi
}

# Main function
main() {
  n_flag=false
  v_flag=false

  parse_options_and_args "$@"
  shift $((OPTIND - 1))
  validate_input "$@"

  search_word=$1
  file_path=$2
  lowercase_search_word=$(echo "$search_word" | tr 'A-Z' 'a-z')

  find_word "$file_path"
}

main "$@"
