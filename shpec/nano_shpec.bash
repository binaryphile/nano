library=./shpec-helper.bash
source "$library" 2>/dev/null || source "${BASH_SOURCE%/*}/$library"
unset -v library

shpec_source lib/nano.bash

describe '_joina'
  it "joins an array with a delimiter"
    samples=( one two )
    result=''
    _joina '@' samples result
    assert equal 'one@two' "$result"
  end
end
