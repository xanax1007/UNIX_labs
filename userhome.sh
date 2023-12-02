#!/bin/bash

file="/etc/passwd"
login=$USER

#обработка -f
while getopts ":f:" opt; do
  case $opt in
    f)
      file="$OPTARG" #записываем аргумет опции -f в файл
      ;;
    \?) #обработка неизвестной опции. OPTARG - текущая обработанная опция
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :) #обработка опции без аргумента
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# переход к аргументу login после обработки опций. $1 указывает на логин
shift $((OPTIND - 1))

# проверка наличия файла
fl=false
for arg in *; do
    if [ "$arg" == "$file" ]; then
      fl=true
    fi
done

if [ "$fl" == false ] && [ "$file" != "/etc/passwd" ]; then
  echo "Error: File not found: $file" >&2
  exit 2
fi

# если указан логин, используем его. после сдвига кол-во аргументов равно 1
if [ $# == 1 ]; then
  login=$1
fi

# поиск домашнего каталога пользователя
home_directory=$(grep "^$login:" "$file" | cut -d: -f6)


# проверка наличия пользователя. проверка переменной на пустоту
if [ -z "$home_directory" ]; then 
  echo "Error: User not found: $login" >&2
  exit 1
fi

# Вывод домашнего каталога
echo "$home_directory"
exit 0

