[[ -n ${_nano:-} ]] && return
readonly _nano=loaded

couple () {
  [[ $2 == 'with' ]] || return
  [[ $1 == '('*')' ]] && local -a ary=$1 || local -a ary=${!1}
  local IFS=$3

  __=${ary[*]}
}

die () { [[ -n $1 ]] && puterr "$1"; exit "${2:-1}" ;}

decouple () {
  [[ $2 == 'on' ]] || return
  local IFS=$3
  local results=()

  results=( $1 )
  ret results
}

grab () {
  [[ $2 == 'from'   ]] || return
  [[ $3 == '('*')'  ]] && local -A argh=$3 || local -A argh=${!3}
  case $1 in
    '('*')' ) local -a vars=$1                ;;
    '*'     ) local -a vars=( "${!argh[@]}" ) ;;
    *       ) local -a vars=( "$1"          ) ;;
  esac
  local var
  local statement
  local statements=()
  local IFS=$IFS

  for var in "${vars[@]}"; do
    printf -v statement 'local %s=%q' "$var" "${argh[$var]}"
    statements+=( "$statement" )
  done
  IFS=';'
  echo "eval ${statements[*]}"
}

instantiate () { printf -v "$1" '%s' "$(eval "echo ${!1}")" ;}

parse_options () {
  local -A optionh
  local args=()
  local flags=()

  while (( $# )); do
    case $1 in
      --*=*   ) set -- "${1%%=*}" "${1#*=}" "${@:2}";;
      -[^-]?* )
        [[ $1 =~ ${1//?/(.)} ]]
        flags=( $(printf -- '-%s ' "${BASH_REMATCH[@]:2}") )
        set -- "${flags[@]}" "${@:2}"
        ;;
    esac
    case $1 in
      '-c' | '--config-file'  ) optionh[config_file]=$2         ; shift                 ;;
      '-a' | '--app'          ) optionh[app]=$2                 ; shift                 ;;
      '-d' | '--dev-channel'  ) optionh[dev_channel]=$2         ; shift                 ;;
      '--'                    ) shift                           ; args+=( "$@" ); break ;;
      -*                      ) puterr "unsupported option $1"  ; return 1              ;;
      *                       ) args+=( "$@" )                  ; break                 ;;
    esac
    shift
  done
  ret args
  optionh[arg]=$__
  ret optionh
}

project () {
  local project_name=$1
  local depth=${2:-1}
  local IFS=$IFS
  local i
  local path=''
  local statements=()

  get_ary statements <<'  EOS'
    [[ -n ${_%s:-} && -z ${reload:-}  ]] && return
    [[ -n ${reload:-}                 ]] && { unset -v reload && echo reloaded || return ;}
    [[ -z ${_%s:-}                    ]] && readonly _%s=loaded

    %s_ROOT=$(readlink -f "$(dirname "$(readlink -f "$BASH_SOURCE")")"%s)
  EOS
  (( depth )) && for (( i = 0; i < depth; i++ )); do path+=/..; done
  IFS=';'
  printf "eval ${statements[*]}\n" "$project_name" "$project_name" "$project_name" "${project_name^^}" "$path"
}

put     () { printf '%s\n' "$@"   ;}
puterr  () { put "Error: $1" >&2  ;}
get_ary () { IFS=$'\n' read -rd '' -a "$1" ||: ;}
get_str () { read -rd '' "$1" ||: ;}

ret () {
  local ref=$1
  local quote

  __=$(declare -p "$ref" 2>/dev/null) || return
  [[ ${__:9:1} == [aA] ]] && quote=\' || quote=\"
  __=${__#*=}
  __=${__#$quote}
  __=${__%$quote}
}

return_if_sourced () { echo 'eval return 0 2>/dev/null ||:' ;}

strict_mode () {
  local status=$1
  local IFS=$IFS
  local callback
  local option
  local statements=()

  get_ary statements <<'  EOS' ||:
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

stuff () {
  [[ $2 == 'into'   ]] || return
  [[ $1 == '('*')'  ]] && local -a refs=$1    || local -a refs=( "$1" )
  [[ $3 == '('*')'  ]] && local -A resulth=$3 || local -A resulth=${!3}
  local ref

  for ref in "${refs[@]}"; do
    resulth[$ref]=${!ref}
  done
  ret resulth
}

traceback () {
  local frame
  local val

  $(strict_mode off)
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

update () {
  [[ $2 == 'with'   ]] || return
  [[ $1 == '('*')'  ]] && local -A hash=$1     || local -A hash=${!1}
  [[ $3 == '('*')'  ]] && local -A updateh=$3  || local -A updateh=${!3}
  local key

  for key in "${!updateh[@]}"; do
    hash[$key]=${updateh[$key]}
  done
  ret hash
}

with () { ret "$1"; grab '*' from "$__" ;}
