while true; do
  inotifywait -r -e modify,create,delete ./src > /dev/null 2>&1

  clear
  echo "Compiling..."
  output=$(v . 2>&1)

  if [[ -z "$output" ]]; then
    echo -e "\033[32m✔ Build successful\033[0m"
  else
    echo -e "\033[31m✖ Errors:\033[0m"
    echo "$output" | awk '
      BEGIN { count = 0; context = 0 }
      /^[^ ]/ { context = 0 }
      { print }
      /error:/ {
        count++
        context = 7
      }
      { if (context > 0) context-- }
      count >= 6 { exit }
    '
  fi

  sleep 0.5
done
