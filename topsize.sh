#!/bin/bash

# кол-во файлов в каталоге и в подкаталогах
N=0
minsize=0
human_readable=false
directories=()
valid_options=("--help" "-h" "-[0-9]+" "-s [0-9]+" "--")

i_vd_optns=0
fl=false
# Обработка аргументов командной строки
while [[ $# -gt 0 ]]; do

  found=false
  for ((i="$i_vd_optns"; i<${#valid_options[@]}; i++)); do
  if [[ "$1" =~ ^- ]]; then
    i_vd_optns="$i"
    pattern="^${valid_options[i]}$"

    if [[ $1 =~ $pattern && $1 != "-s" ]] || [[ $1 == "-s" && $2 =~ ^[0-9]+$ && "$i" -ge 3 ]]; then
      found=true
      break
    fi
  fi  
  done
  
  if [ "$found" == false ] && [ "$fl" == false ] && [ "$1" != "-s" ] && [[ "$1" =~ ^- ]]; then
    echo "Error: Invalid input format. Enter --help option for more information." >&2
    exit 2
  fi
  
  
  case $1 in
    --help)
      echo "Usage: topsize [--help] [-h] [-N] [-s minsize] [--] [dir...]"
      exit 0
      ;;
    -h)
      human_readable=true
      ;;
    -[0-9]*)
      N=$(($1 * -1))
      ;;
    -s)
      while getopts ":s:" opt; do
          case $opt in
            s)
              minsize="$OPTARG" # записываем аргумент опции -s в minsize
              #отдельая проверка на то, является ли аргумет числом
              if [[ ! "$minsize" =~ ^[0-9]+$ ]]; then
                echo "Option -s requires an argument." >&2
                exit 1
              fi
              ;;
            :)
              echo "Option -s requires an argument." >&2
              exit 1
              ;;
          esac
      done
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      directories+=("$1")
      ;;
  esac
  shift
done

# если остались директории после -- (если он был), то записываем их в массив
while [[ $# -gt 0 ]]; do
  directories+=("$1")
  shift
done

# если не указаны каталоги, используем текущий
if [ ${#directories[@]} -eq 0 ]; then
  directories=(".")
fi

for dir in "${directories[@]}"; do
    count=$(find "$dir" -type f | wc -l)
    N=$((N + count))
done

# функция для получения размера файла в человекочитаемом формате
get_file_size() {
  local file=$1
  local size=$(du -b -- "$file" | cut -f1)
  
  if $human_readable; then
    size=$(du -h -- "$file" | cut -f1)
  fi

  echo "$size"
}

# функция для обработки найденных файлов
process_files() {
  local files=($@)
  
  for file in "${files[@]}"; do
    local size=$(get_file_size "$file")
    echo "$size $file"
  done
}

# функция для вывода N наибольших файлов
output_top_files() {
  local files=($@)
  
  if [ $N -eq -1 ]; then
    process_files "${files[@]}"
  else
    process_files "${files[@]}" | sort -n -r | head -n $N
  fi
}

# пооиск файлов в указанных каталогах с размером больше minsize
found_files=()
for dir in "${directories[@]}"; do
  files_in_dir=$(find "$dir" -type f -size +"$minsize"c)
  found_files+=($files_in_dir)
done

# вывод N наибольших файлов
output_top_files "${found_files[@]}"

