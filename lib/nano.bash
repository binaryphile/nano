[[ -n ${_nano:-} ]] && return
readonly _nano=loaded

_puts    () { printf '%s\n' "$1"  ;}

_ret () {
  [[ $(__type "$2") == [aA] ]] && { __seta "$@"; return ;}
  __sets "$@"
}

__seta () {
  local _key

  if [[ $1 == "$2" ]]; then
    local _ref
    _ref=$(declare -p "$2")
    eval "${_ref/$2/_ref}"
  else
    local -n _ref=$2
  fi

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

__type () {
  local declaration

  declaration=$(declare -p "$1" 2>/dev/null) || return
  _puts "${declaration:9:1}"
}
