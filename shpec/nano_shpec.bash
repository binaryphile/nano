library=../lib/nano.bash
source "$library" 2>/dev/null || source "${BASH_SOURCE%/*}/$library"
unset -v library

describe die
  it "exits without an error message"; (
    # stop_on_error off
    result=$(die 2>&1)
    assert equal '' "$result"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "exits with a default error code of 1"; (
    # stop_on_error off
    (die 2>&1)
    assert equal 1 $?
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
    assert equal 2 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe grab
  it "instantiates a key/value pair from a hash literal as a local"
    result=$(grab one from '([one]=1)')
    assert equal 'eval local one=1' "$result"
  end

  it "instantiates more than one key/value pair from a hash literal"
    result=$(grab '(one two)' from '([one]=1 [two]=2)')
    assert equal 'eval local one=1;local two=2' "$result"
  end

  it "instantiates all key/value pairs from a hash literal"
    result=$(grab '*' from '([one]=1 [two]=2 [three]=3)')
    assert equal 'eval local one=1;local two=2;local three=3' "$result"
  end

  it "instantiates a key/value pair from a hash literal reference"
    sample='([one]=1)'
    result=$(grab one from sample)
    assert equal 'eval local one=1' "$result"
  end

  it "instantiates more than one key/value pair from a hash literal reference"
    sample='([one]=1 [two]=2)'
    result=$(grab '(one two)' from sample)
    assert equal 'eval local one=1;local two=2' "$result"
  end

  it "instantiates all key/value pairs from a hash literal reference"
    sample='([one]=1 [two]=2 [three]=3)'
    result=$(grab '*' from sample)
    assert equal 'eval local one=1;local two=2;local three=3' "$result"
  end

  it "errors if \$3 isn't 'from'"; (
    # stop_on_error off
    grab one two
    assert unequal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "doesn't work if the first argument is a reference"
    sample=one
    result=$(grab sample from '([one]=1)')
    assert equal "eval local sample=''" "$result"
  end
end

describe options_new
  it "creates a definition of a flag option"; (
    get_here_ary samples <<'    EOS'
      ( f '' '' 'a flag' )
    EOS
    get_here_str expected <<'    EOS'
      ([0]="([argument]=\"\" [help]=\\"a flag\\" [short]=\\"f\\" [long]=\\"\\" )")
    EOS
    inspect samples
    options_new __
    $(grab defn from "${!__}")
    assert equal "$expected" "$defn"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates a definition of a flag option"; (
    get_here_ary samples <<'    EOS'
      ( f '' '' 'a flag' )
    EOS
    get_here_str expected <<'    EOS'
      ([0]="([argument]=\"\" [help]=\\"a flag\\" [short]=\\"f\\" [long]=\\"\\" )")
    EOS
    inspect samples
    options_new __
    $(grab defn from "${!__}")
    assert equal "$expected" "$defn"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

# describe options_parse
#   it "accepts flag options"; (
#     get_ary samples <<'    EOS'
#       (f '' '' 'a flag')
#     EOS
#     inspect samples
#     options_new __
#     options_parse "$__" -f
#     declare -A resulth=$__
#     assert equal 1 "${resulth[flag_f]}"
#     return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
#   end
# end
#
describe part
  it "splits a string on a delimiter"
    part one@two on @
    assert equal '([0]="one" [1]="two")' "$__"
  end

  it "doesn't split a string by name with a delimiter"
    sample=one@two
    part sample on @
    assert equal '([0]="sample")' "$__"
  end
end

describe wed
  it "joins an array literal with a delimiter"
    wed '( one two )' with @
    assert equal one@two "$__"
  end

  it "joins an array literal by name with a delimiter"
    sample='( one two )'
    wed sample with @
    assert equal one@two "$__"
  end
end
