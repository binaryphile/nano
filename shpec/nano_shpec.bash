library=./shpec-helper.bash
source "$library" 2>/dev/null || source "${BASH_SOURCE%/*}/$library"
unset -v library

shpec_source lib/nano.bash

describe 'joina'
  it "joins an array with a delimiter"
    samples=( one two )
    result=''
    joina '@' samples result
    assert equal 'one@two' "$result"
  end

  it "joins an array with one item"
    samples=( one )
    result=''
    joina '@' samples result
    assert equal 'one' "$result"
  end
end

describe 'puts'
  it "outputs a string on stdout"
    assert equal sample "$(puts 'sample')"
  end
end

describe 'putserr'
  it "outputs a string on stderr"
    assert equal sample "$(putserr 'sample' 2>&1)"
  end
end

describe 'ret'
  it "returns an array in a named variable"
    results=()
    samplef () { local samples=( one ); local "$1" || return; ret "$1" samples ;}
    samplef results
    printf -v expected 'declare -a results=%s([0]="one")%s' \' \'
    assert equal "$expected" "$(declare -p results)"
  end

  it "returns an array in a named variable when the ref is used locally"
    results=()
    samplef () { local samples=( one ); local results=( two ); local "$1" || return; ret "$1" samples ;}
    samplef results
    printf -v expected 'declare -a results=%s([0]="one")%s' \' \'
    assert equal "$expected" "$(declare -p results)"
  end

  it "returns an array in a named variable when the ref is the same as the return variable"
    results=()
    samplef () { local results=( one ); local "$1" || return; ret "$1" results ;}
    samplef results
    printf -v expected 'declare -a results=%s([0]="one")%s' \' \'
    assert equal "$expected" "$(declare -p results)"
  end

  it "returns a hash in a named variable"
    declare -A resulth=()
    samplef () { local -A sampleh=( [one]=1 ); local "$1" || return; ret "$1" sampleh ;}
    samplef resulth
    printf -v expected 'declare -A resulth=%s([one]="1" )%s' \' \'
    assert equal "$expected" "$(declare -p resulth)"
  end

  it "returns a hash in a named variable when the ref is used locally"
    declare -A resulth=()
    samplef () { local -A sampleh=( [one]=1 ); local -A resulth=( [two]=2 ); local "$1" || return; ret "$1" sampleh ;}
    samplef resulth
    printf -v expected 'declare -A resulth=%s([one]="1" )%s' \' \'
    assert equal "$expected" "$(declare -p resulth)"
  end

  it "returns a hash in a named variable when the ref is the same as the return variable"
    declare -A resulth=()
    samplef () { local -A resulth=( [one]=1 ); local "$1" || return; ret "$1" resulth ;}
    samplef resulth
    printf -v expected 'declare -A resulth=%s([one]="1" )%s' \' \'
    assert equal "$expected" "$(declare -p resulth)"
  end

  it "returns a value in a named variable"
    result=''
    samplef () { local "$1" || return; ret "$1" one ;}
    samplef result
    assert equal one "$result"
  end

  it "returns a value in a named variable when the ref is used locally"
    result=''
    samplef () { local result=one; local "$1" || return; ret "$1" "$result" ;}
    samplef result
    assert equal one "$result"
  end
end

describe 'splits'
  it "splits a string into an array on a partition character"
    results=()
    sample='a=b'
    splits '=' "$sample" results
    printf -v expected 'declare -a results=%s([0]="a" [1]="b")%s' \' \'
    assert equal "$expected" "$(declare -p results)"
  end
end

describe '_type'
  it "identifies a string by name"
    sample=''
    assert equal - "$(_type sample)"
  end

  it "identifies an array by name"
    samples=()
    assert equal a "$(_type samples)"
  end

  it "identifies a hash by name"
    declare -A sampleh=()
    assert equal A "$(_type sampleh)"
  end
end
