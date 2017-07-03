[[ -n ${_nano:-} ]] && return
readonly _nano=loaded

project () {
  local project_name=$1
  local depth=${2:-1}
  local IFS=$IFS
  local i
  local path=''
  local statements=()

  IFS=$'\n' read -rd '' -a statements <<'  EOS' ||:
    [[ -n "${_%s-}" && -z "${reload-}"  ]] && return
    [[ -n "${reload-}"                  ]] && { unset -v reload && echo reloaded || return ;}
    [[ -z "${_%s-}"                     ]] && readonly _%s=loaded

    %s_ROOT=$(readlink -f "$(dirname "$(readlink -f "$BASH_SOURCE")")"%s)
  EOS
  (( depth )) && for i in $(eval "echo {1..$depth}"); do path+=/..; done
  IFS=';'
  printf "eval ${statements[*]}\n" "$project_name" "$project_name" "$project_name" "${project_name^^}" "$path"
}

return_if_sourced () { echo 'eval return 0 2>/dev/null ||:' ;}

strict_mode () {
  local status=$1
  local IFS=$IFS
  local callback
  local option
  local statements=()

  IFS=$'\n' read -rd '' -a statements <<'  EOS' ||:
    set %so errexit
    set %so errtrace
    set %so nounset
    set %so pipefail

    trap %s ERR
  EOS
  case $status in
    'on'  ) option=-; callback=traceback  ;;
    'off' ) option=+; callback=-          ;;
    *     ) return 1                      ;;
  esac
  IFS=';'
  printf "eval ${statements[*]}\n" "$option" "$option" "$option" "$option" "$callback"
}

traceback () {
  local frame
  local val

  set +o errexit
  trap - ERR
  printf '\nTraceback:  '
  frame=0
  while val=$(caller "$frame"); do
    set -- $val
    (( frame == 0 )) && sed -n "$1"' s/^[[:space:]]*// p' "$3"
    (( ${#3} > 30 )) && set -- "$1" "$2" [...]"${3:${#3}-25:25}"
    printf "  %s:%s:in '%s'\n" "$3" "$1" "$2"
    : $(( frame++ ))
  done
  exit 1
}
