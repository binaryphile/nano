library=../lib/nano.bash
source "$library" 2>/dev/null || source "${BASH_SOURCE%/*}/$library"
unset -v library

describe 'couple'
  it "joins an array literal with a delimiter"
    couple '( one two )' with @
    assert equal one@two "$__"
  end

  it "joins an array literal by name with a delimiter"
    sample='( one two )'
    couple sample with @
    assert equal one@two "$__"
  end
end

describe 'die'
  it "exits without an error message"; (
    # stop_on_error off
    result=$(die 2>&1)
    assert equal '' "$result"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "exits with a default error code of 1"; (
    # stop_on_error off
    (die 2>&1)
    assert equal 1 "$?"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "exits with an error message"; (
    # stop_on_error off
    result=$(die 'aaaaagh' 2>&1)
    assert equal 'Error: aaaaagh' "$result"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "exits with an error code"; (
    # stop_on_error off
    (die '' 2 2>&1)
    assert equal 2 "$?"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe 'decouple'
  it "splits a string on a delimiter"
    decouple one@two on @
    assert equal '([0]="one" [1]="two")' "$__"
  end

  it "doesn't split a string by name with a delimiter"
    sample=one@two
    decouple sample on '@'
    assert equal '([0]="sample")' "$__"
  end
end
