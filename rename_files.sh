#!/bin/bash

dry_run=false
verbose=false
fl=false
list_of_files=()

# обработка аргументов командной строки
while [[ $# -gt 0 ]]; do
  case $1 in
    -h)
      echo "Usage: rename_files [-h] [-d] [-v] [--] suffix [files ...]. The entry order is arbitrary."
      exit 0
      ;;
    -d)
      dry_run=true
      ;;
    -v)
      verbose=true
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Error: Invalid option: $1" >&2
      exit 2
      ;;
    *)
      if [ "$fl" == false ]; then
        suffix=$1
        fl=true
      else
        list_of_files+=("$1")
      fi
      ;;
  esac
  shift
done

# если остались файлы после -- (если он был), то записываем их в массив
while [[ $# -gt 0 ]]; do
  list_of_files+=("$1")
  shift
done

# проверка наличия файла
for file in "${list_of_files[@]}"; do
  ffl=false
  for arg in *; do
    if [ "$arg" == "$file" ]; then
      ffl=true
    fi
  done
  
  if [ "$ffl" == false ]; then
    echo "Error: File not found: $file" >&2
    exit 2
  fi
done

# Проверка наличия суффикса
if [ -z "$suffix" ]; then
  echo "Error: Suffix is missing." >&2
  exit 2
fi

# Проверка наличия списка файлов
if [ "${#list_of_files[@]}" -eq 0 ]; then
  echo "Error: No files provided." >&2
  exit 2
fi

# Функция для переименования файлов
rename_files() {
  local suffix=$1
  shift
  for file in "${list_of_files[@]}"; do
    if [[ "$file" =~ \. ]]; then
      new_name="${file%.*}$suffix.${file##*.}"
    else
      new_name="${file%.*}$suffix"
    fi
    
    if [ "$file" == "rename_files.sh" ]; then
      continue
    fi
    
    if [ "$dry_run" == true ]; then
      echo "$file -> $new_name"
    else
      if [ "$verbose" = true ]; then
          echo "$file"
      fi
      mv -- "$file" "$new_name"
    fi
  done
}

# Переименование файлов
rename_files "$suffix" "${list_of_files[@]}"
