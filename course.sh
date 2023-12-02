#!/bin/bash

# проверка наличия двух аргументов
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 $1 $2"
  exit 1
fi

# создание временного файла
tmpfile=$(mktemp)

# загрузка страницы с курсом валюты с Google Finance
wget -q -O "$tmpfile" "https://www.x-rates.com/calculator/?from=${1,,}&to=${2,,}"

# парсинг курса валюты с помощью grep
currency_rate=$(grep -oP '<span class="ccOutputRslt">\K[^<]+' "$tmpfile")

# вывод результата
if [ -n "$currency_rate" ]; then
  echo "Currency rate for $1 to $2: $currency_rate"
else
  echo "Error: Unable to retrieve currency rate."
fi

# удаление временного файла
rm -- "$tmpfile"

