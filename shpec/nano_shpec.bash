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
  it "instantiates a key/value pair from a hash literal as a local"; (
    $(grab one from '([one]=1)')
    assert equal 1 "$one"
    return "$_shpec_failures" ); : $(( _shpec_failures+= $? ))
  end

  it "instantiates more than one key/value pair from a hash literal"; (
    $(grab '(one two)' from '([one]=1 [two]=2)')
    assert equal '1 2' "$one $two"
    return "$_shpec_failures" ); : $(( _shpec_failures+= $? ))
  end

  it "instantiates all key/value pairs from a hash literal"; (
    $(grab '*' from '([one]=1 [two]=2 [three]=3)')
    assert equal '1 2 3' "$one $two $three"
    return "$_shpec_failures" ); : $(( _shpec_failures+= $? ))
  end

  it "instantiates a key/value pair from a hash literal reference"; (
    sample='([one]=1)'
    $(grab one from sample)
    assert equal 1 "$one"
    return "$_shpec_failures" ); : $(( _shpec_failures+= $? ))
  end

  it "instantiates more than one key/value pair from a hash literal reference"; (
    sample='([one]=1 [two]=2)'
    $(grab '(one two)' from sample)
    assert equal '1 2' "$one $two"
    return "$_shpec_failures" ); : $(( _shpec_failures+= $? ))
  end

  it "instantiates all key/value pairs from a hash literal reference"; (
    sample='([one]=1 [two]=2 [three]=3)'
    $(grab '*' from sample)
    assert equal '1 2 3' "$one $two $three"
    return "$_shpec_failures" ); : $(( _shpec_failures+= $? ))
  end

  it "errors if \$3 isn't 'from'"; (
    # stop_on_error off
    grab one two
    assert unequal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "doesn't work if the first argument is a reference"; (
    sample=one
    result=$(grab sample from '([one]=1)')
    assert equal "eval local sample=''" "$result"
    return "$_shpec_failures" ); : $(( _shpec_failures+= $? ))
  end
end

describe options_new
  it "creates an entry for a short flag option"; (
    get_here_ary samples <<'    EOS'
      ( -o '' '' 'a flag' )
    EOS
    inspect samples
    options_new __
    $(grab o from "${!__}")
    $(grab '( help name )' from o)
    assert equal "a flag o" "$help $name"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates an entry for a short argument option"; (
    get_here_ary samples <<'    EOS'
      ( -o '' argument 'an argument' )
    EOS
    inspect samples
    options_new __
    $(grab o from "${!__}")
    $(grab '( argument name help )' from o)
    assert equal "argument o an argument" "$argument $name $help"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates an entry for a long flag option"; (
    get_here_ary samples <<'    EOS'
      ( '' --option '' 'a flag' )
    EOS
    inspect samples
    options_new __
    $(grab option from "${!__}")
    $(grab '( argument name help )' from option)
    assert equal " option a flag" "$argument $name $help"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates an entry for a long argument option"; (
    get_here_ary samples <<'    EOS'
      ( '' --option argument 'an argument' )
    EOS
    inspect samples
    options_new __
    $(grab option from "${!__}")
    $(grab '( argument name help )' from option)
    assert equal "argument option an argument" "$argument $name $help"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates an entry for a long flag option"; (
    get_here_ary samples <<'    EOS'
      ( '' --option '' 'a flag' )
    EOS
    inspect samples
    options_new __
    $(grab option from "${!__}")
    $(grab '( argument name help )' from option)
    assert equal " option a flag" "$argument $name $help"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates an entry for a long argument option"; (
    get_here_ary samples <<'    EOS'
      ( '' --option argument 'an argument' )
    EOS
    inspect samples
    options_new __
    $(grab option from "${!__}")
    $(grab '( argument name help )' from option)
    assert equal "argument option an argument" "$argument $name $help"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates entries for a flag option with long and short"; (
    get_here_ary samples <<'    EOS'
      ( -o --option '' 'a flag' )
    EOS
    inspect samples
    options_new __
    result=$__
    get_here_str format <<'    EOS'
      %s %s
      %%s %%s
    EOS
    $(grab option from "${!result}")
    $(grab '( help name )' from option)
    printf -v format "$format" "$help" "$name"
    $(grab o from "${!result}")
    $(grab '( help name )' from o)
    printf -v result "$format" "$help" "$name"
    get_here_str expected <<'    EOS'
      a flag option
      a flag option
    EOS
    assert equal "$expected" "$result"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates entries for an argument option with long and short"; (
    get_here_ary samples <<'    EOS'
      ( -o --option argument 'an argument' )
    EOS
    inspect samples
    options_new __
    result=$__
    get_here_str format <<'    EOS'
      %s %s %s
      %%s %%s %%s
    EOS
    $(grab option from "${!result}")
    $(grab '( argument help name )' from option)
    printf -v format "$format" "$argument" "$help" "$name"
    $(grab o from "${!result}")
    $(grab '( argument help name )' from o)
    printf -v result "$format" "$argument" "$help" "$name"
    get_here_str expected <<'    EOS'
      argument an argument option
      argument an argument option
    EOS
    assert equal "$expected" "$result"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe options_parse
  it "accepts flag options"; (
    get_here_ary samples <<'    EOS'
      ( -o '' '' 'a flag' )
    EOS
    inspect samples
    options_new __
    options_parse "$__" -o
    $(grab flag_o from __)
    assert equal 1 "$flag_o"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

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
