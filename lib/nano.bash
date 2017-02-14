[[ -n ${_nano:-} ]] && return
readonly _nano=loaded

_errexit () { _putserr "$1"; exit "${2:-1}" ;}

_joina () {
  local IFS=$1
  local _refs="$2[*]"
  local _ref=$3

  local "$_ref" || return
  _ret "$_ref" "${!_refs}"
}

_puts    () { printf '%s\n' "$1"  ;}
_putserr () { _puts "$1" >&2      ;}

_ret () {
  [[ $(__type "$2") == [aA] ]] && { __seta "$@"; return ;}
  __sets "$@"
}

__seta () {
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

__sets () {
  unset  -v "$1" || return
  printf -v "$1" '%s' "$2"
}

_splits () {
  local delimiter=$1
  local string=$2
  local ref=$3
  local result=()

  IFS=$delimiter read -ra result <<<"$string" ||:

  local "$ref" || return
  _ret "$ref" result
}

__type () {
  local declaration

  declaration=$(declare -p "$1" 2>/dev/null) || return
  echo "${declaration:9:1}"
}
