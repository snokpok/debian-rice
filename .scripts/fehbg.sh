#!/bin/bash

function trim() {
  echo "$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'<<<"$1")"
}

function write_exc() {
  printf "ERROR: $1" >&2
  return 1
}

function set_bg_dmenu() {
  BGS_DIR=$1
  IMG_FILES=($(find $BGS_DIR -type f -exec file --mime-type {} \+ | awk -F: '{if ($2 ~/image\//) print $1}'))
  IMG_NAMES="$(for ((i=0; i < ${#IMG_FILES[@]}; i++)); do
    file=${IMG_FILES[i]}
    if [[ -n $file ]]; then
      trimmed=$(trim $(basename $file))
      if [[ i -ne ${#IMG_FILES[@]}-1 ]]; then
        trimmed+="\n"
      fi
      echo $trimmed
    fi
  done
  )"

  # must be a directory
  if [[ ! $1 ]]; then
    write_exc "Please provide a path to the background images directory"
  fi

  if [[ ! -d $BGS_DIR ]]; then 
    write_exc "$BGS_DIR is not a directory!"
  elif [[ ${#IMG_FILES[@]} -eq 0 ]]; then
    write_exc "$BGS_DIR has no compatible background images in it (.png,.jpeg,.jpg)"
  fi
  
  # option to set by dmenu
  if [[ -n $2 ]]; then
    if [[ $2 == "set" ]]; then
      selected=$(echo -e $IMG_NAMES | dmenu)
      for file in ${IMG_FILES[@]}; do
        if [[ $(trim $selected) == $(trim $(basename $file)) ]]; then
          feh --bg-scale $file
          echo "Successfully set background image to $file"
        fi
      done
    elif [[ $2 != "set" ]]; then
      write_exc "Invalid second command; must be 'set'"
    fi
  else
    # by default if no set then it takes the first one in the `find` cmd
    echo "Successfully set background image to $IMG_FILES"
  fi
}

set_bg_dmenu $1 $2
