#!/bin/bash

show_summary=
show_only_summary=
error_flag=

for argument in "$@"; do
  case $argument in
    --usage)
      echo "$0 [-s] [-S] file1 [file2 ...]"
      exit 0
      ;;
    --help)
      echo "Display detailed help."
      exit 0
      ;;
    --)
      break
      ;;
    -S)
      show_only_summary=1
      ;;
    -s)
      show_summary=1
      ;;
    -*)
      echo "Error. Unsupported option: $argument" >&2
      exit 2
      ;;
  esac
done

total_size=0
for file in "$@"; do
  if [[ "$file" == "--" ]]; then
    error_flag=1
    continue
  fi

  if [[ $error_flag || "${file:0:1}" != "-" ]]; then
    if [[ ! -e "$file" ]]; then
      echo "Error: file not found - $file" >&2
      exit_code=1
      continue
    else
      size=$(stat -c %s -- "$file")
      if [[ ! $show_only_summary ]]; then
        echo "$size" "$file"
      fi
      total_size=$((total_size + size))
    fi
  fi
done

if [[ $show_summary || $show_only_summary ]]; then
  echo "Total size: $total_size"
fi

exit ${exit_code:-0}
