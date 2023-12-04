#!/bin/bash

display_sizes=false
display_total=false
total_size=0
exts=0

check_and_process_file() {
  local file="$1"

  # Проверка наличия файла
  fl=false
  for arg in *; do
    if [ "$arg" == "$file" ]; then
      fl=true
    fi
  done
  
  if [ "$file" == "--" ]; then
    return
  fi
  
  if [ "$fl" == false ]; then
    echo "Error: File not found: $file" >&2
    exts=1
    return
  fi

  # Получение размера файла с использованием stat
  size=""
  if [[ "$file" == --* || "$file" == -* ]]; then
    size=$(stat -c %s "./$file")
  else
    size=$(stat -c %s "$file")
  fi

  # Вывод информации о размере файла, если опция -s активирована
  if [ "$display_total" != true ]; then
    echo "$size" "$file"
  fi

  # Обновление суммарного размера файла
  total_size=$((total_size + size))
}

# Цикл для обработки опций
for arg in "$@"; do
  case $arg in
    -s)
      display_sizes=true
      ;;
    -S)
      display_total=true
      ;;
    --usage)
      echo "$0 [-s] [-S] file1 [file2 ...]"
      exit 0
      ;;
    --help)
      echo "Display detailed help."
      exit 0
      ;;
    --)
      break;
      ;;
    -*)
      if [[ ! "$arg" =~ \. ]] && [ "$arg" != "--" ]; then
        echo "Error. Unsupported option: $arg" >&2
        exit 2
      fi
      ;;
  esac
done

# Цикл для обработки параметров (файлов)
fl=false
for file in "$@"; do
  if [ fl == true ]; then
    check_and_process_file "$file"
  else  
  case $file in
    --)
      fl=true
      ;;
    -*)
      if [[ "$file" =~ \. ]] || [ "$fl" == true ]; then
        check_and_process_file "$file"
      fi
      ;;
    *)
      check_and_process_file "$file"
      ;;
  esac
  fi
done

# Вывод суммарного размера файлов, если опция -s активирована
if [ "$display_sizes" == true ] && [ "$display_total" != true ]; then
  echo "Total: $total_size"
fi

# Вывод суммарного размера файлов, если опция -S активирована
if [ "$display_total" == true ]; then
  echo "$total_size"
fi

# Завершение сценария с соответствующим кодом возврата
exit "$exts"
