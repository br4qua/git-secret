#!/usr/bin/env bash


function remove {
  local clean=0

  OPTIND=1

  while getopts 'ch' opt; do
    case "$opt" in
      c) clean=1;;

      h) _show_manual_for 'remove';;
    esac
  done

  shift $((OPTIND-1))
  [ "$1" = '--' ] && shift

  # Validate if user exists:
  _user_required

  # Command logic:

  local path_mappings
  path_mappings=$(_get_secrets_dir_paths_mapping)

  for item in "$@"; do
    local path # absolute path
    local normalized_path # relative to .git folder
    normalized_path=$(_git_normalize_filename "$item")
    path=$(_append_root_path "$normalized_path")

    echo "$item -> $normalized_path -> $path"

    # Checking if file exists:
    if [[ ! -f "$path" ]]; then
      _abort "$item is not a file."
    fi

    # Deleting it from path mappings:
    _delete_line "$normalized_path" "$path_mappings"
    rm -f "${path_mappings}.bak"  # not all systems create '.bak'

    # Optional clean:
    if [[ "$clean" -eq 1 ]]; then
      local encrypted_filename
      encrypted_filename=$(_get_encrypted_filename "$path")

      rm "$encrypted_filename" # fail on error
    fi
  done

  echo 'removed from index.'
  echo "ensure that files: [$*] are now not ignored."
}
