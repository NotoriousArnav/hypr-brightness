#!/usr/bin/env sh
set +e

usage="Usage: $0 [+] or [-]"

# Check Dependencies and update the flag
flag=0

if ! command -v jq &> /dev/null
then
  flag=1
fi

if ! command -v ddcutil &> /dev/null
then
  flag=1
fi

if ! command -v brillo &> /dev/null
then
  flag=1
fi

if ! command -v hyprctl &> /dev/null
then
  flag=1
fi

if [ $flag -eq 1 ]; then
  # Check if Arch linux
  if [ -f /etc/os-release ]; then
    if grep -q "ID=arch" /etc/os-release; then
      # Check if yay or any other AUR helper is installed
      if command -v yay &> /dev/null; then
        yay -S jq ddcutil brillo hyprland
      else
        echo "yay is not installed"
        exit 1
      fi
    fi
  fi
fi

if [ "$#" -ne 1 ]; then
    echo "No direction parameter provided"
    echo "$usage"
    exit 1
fi

arg="$1"

if [ "$arg" == "help" ] || [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
    echo "$usage"
    exit 0
fi

if [ "$arg" != "+" ] && [ "$arg" != "-" ]; then
    echo "Direction parameter must be '+' or '-'"
    echo $usage 
    exit 1
fi

direction=$arg

monitor_data=$(hyprctl monitors -j)
focused_name=$(echo $monitor_data | jq -r '.[] | select(.focused == true) | .name' | tr -d '\n')

if [ "$focused_name" == "eDP-1" ]; then
    if [ "$direction" == "-" ]; then
        brillo -u 150000 -U 8
    else
        brillo -u 150000 -A 8
    fi
else
    focused_id=$(echo $monitor_data | jq -r '.[] | select(.focused == true) | .id')
    ddcutil --sleep-multiplier=.2 --display=$focused_id setvcp 10 $direction 15
fi
