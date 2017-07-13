[[ -n ${_nano:-} ]] && return
readonly _nano=loaded

die () { [[ -n $1 ]] && puterr "$1"; exit "${2:-1}" ;}

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

  for var in "${vars[@]}"; do
    printf -v statement '%slocal %s=%q\n' "$statement" "$var" "${argh[$var]}"
  done
  echo "eval $statement"
}

index () {
  :
}

instantiate () { printf -v "$1" '%s' "$(eval "echo ${!1}")" ;}

options_new () {
  [[ $1 == '('*')' ]] && local -a defns=$1  || local -a defns=${!1}
  declare -p __instanceh >/dev/null 2>&1    || declare -Ag __instanceh=([next_id]=0)
  local -A optionh=()
  local -a options=()
  local argument
  local defn
  local help
  local long
  local short
  local spaces

  for defn in "${defns[@]}"; do
    local -a items=$defn
    short=${items[0]}
    long=${items[1]}
    argument=${items[2]}
    help=${items[3]}
    stuff '(short long argument help)' into '()'
    options+=( "$__" )
  done

  inspect __instanceh
  $(grab next_id from __)
  [[ -z ${__instanceh[$next_id]} ]] || return
  inspect options
  optionh=( [defn]=$__ )
  inspect optionh
  __instanceh[$next_id]=$__
  __=__instanceh["$next_id"]
  __instanceh[next_id]=$(( next_id++ ))
}

options_parse () {
  local self=$1; shift
  local -A optionh
  local args=()
  local flags=()
  local i

  $(grab '( option type )' from "${!self}")
  local -a options=$option
  local -a types=$type

  while (( $# )); do
    case $1 in
      --*=*   ) set -- "${1%%=*}" "${1#*=}" "${@:2}";;
      -[^-]?* )
        [[ $1 =~ ${1//?/(.)} ]]
        flags=( $(printf -- '-%s ' "${BASH_REMATCH[@]:2}") )
        set -- "${flags[@]}" "${@:2}"
        ;;
    esac
    index options "$1" && {
      i=$__
      option=${options[i]}
      case ${types[i]} in
        'flag'      ) optionh[flag_$option]=1         ;;
        'argument'  ) optionh[$option]=$2     ; shift ;;
      esac
      shift
      continue
    }
    case $1 in
      '--'  ) shift                           ; args+=( "$@" ); break ;;
      -*    ) puterr "unsupported option $1"  ; return 1              ;;
      *     ) args+=( "$@" )                  ; break                 ;;
    esac
    shift
  done
  inspect args
  optionh[arg]=$__
  inspect optionh
}

part () {
  [[ $2 == 'on' ]] || return
  local IFS=$3
  local results=()

  results=( $1 )
  inspect results
}

project () {
  local project_name=$1
  local depth=${2:-1}
  local i
  local path
  local statements=()

  get_here_str statement <<'  EOS'
    [[ -n ${_%s:-} && -z ${reload:-}  ]] && return
    [[ -n ${reload:-}                 ]] && { unset -v reload && echo reloaded || return ;}
    [[ -z ${_%s:-}                    ]] && readonly _%s=loaded

    %s_ROOT=$(readlink -f "$(dirname "$(readlink -f "$BASH_SOURCE")")"%s)
  EOS
  path=''
  (( depth )) && for (( i = 0; i < depth; i++ )); do path+=/..; done
  printf "$statement\n" "$project_name" "$project_name" "$project_name" "${project_name^^}" "$path"
}

put     () { printf '%s\n' "$@"   ;}
puterr  () { put "Error: $1" >&2  ;}
get_ary () { IFS=$'\n' read -rd '' -a "$1" ||: ;}

get_here_ary () {
  get_here_str  "$1"
  get_ary       "$1" <<<"${!1}"
}

get_here_str () {
  get_str "$1"
  set -- "$1" "${!1%%[^[:space:]]*}"
  printf -v "$1" '%s' "${!1:${#2}}"
  printf -v "$1" '%s' "${!1//$'\n'$2/$'\n'}"
}

get_str () { IFS=$'\n' read -rd '' "$1" ||: ;}

inspect () {
  __=$(declare -p "$1" 2>/dev/null) || return
  [[ ${__:9:1} == [aA] ]] && {
    __=${__#*=}
    __=${__#\'}
    __=${__%\'}
    __=${__//\'\\\'\'/\'}
    return
  }
  __=${__#*=}
  __=${__#\"}
  __=${__%\"}
}

return_if_sourced () { echo 'eval return 0 2>/dev/null ||:' ;}

strict_mode () {
  local status=$1
  local IFS=$IFS
  local callback
  local option
  local statements=()

  get_here_str statement <<'  EOS'
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
  printf "eval $statement\n" "$option" "$option" "$option" "$option" "$callback"
}

stuff () {
  [[ $2 == 'into'   ]] || return
  [[ $1 == '('*')'  ]] && local -a refs=$1    || local -a refs=( "$1" )
  [[ $3 == '('*')'  ]] && local -A resulth=$3 || local -A resulth=${!3}
  local ref

  for ref in "${refs[@]}"; do
    resulth[$ref]=${!ref}
  done
  inspect resulth
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
  inspect hash
}

wed () {
  [[ $2 == 'with' ]] || return
  [[ $1 == '('*')' ]] && local -a ary=$1 || local -a ary=${!1}
  local IFS=$3

  __=${ary[*]}
}

with () { inspect "$1"; grab '*' from "$__" ;}
