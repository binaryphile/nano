[[ -n ${_nano:-} ]] && return
readonly _nano=loaded

errexit () { putserr "$1"; exit "${2:-1}" ;}

includes () {
  local search_item=$1; shift
  local item

  for item in "$@"; do
    [[ $item == "$search_item" ]] && return
  done
  return 1
}

joina () {
  local IFS=$1
  local _refs="$2[*]"
  local _ref=$3

  local "$_ref" || return
  ret "$_ref" "${!_refs}"
}

puts    () { printf '%s\n' "$1"             ;}
putserr () { puts "$1" >&2                  ;}

ret () {
  [[ $(_type "$2") == [aA] ]] && { _set_ary "$@"; return ;}
  _set_scalar "$@"
}

_set_ary () {
  if [[ $1 == "$2" ]]; then
    local _ref
    _ref=$(declare -p "$2")
    eval "${_ref/$2/_ref}"
  else
    local -n _ref=$2
  fi
  local _key

  unset -v "$1" || return
  eval "$1=()"
  for _key in "${!_ref[@]}"; do
    printf -v "$1[$_key]" '%s' "${_ref[$_key]}"
  done
}

_set_scalar () {
  unset  -v "$1" || return
  printf -v "$1" '%s' "$2"
}

splits () {
  local delimiter=$1
  local string=$2
  local ref=$3
  local result=()

  IFS=$delimiter read -ra result <<<"$string" ||:

  local "$ref" || return
  ret "$ref" result
}

_type () {
  local declaration

  declaration=$(declare -p "$1" 2>/dev/null) || return
  echo "${declaration:9:1}"
}
