nano
====

A nano-sized bash library

Defines a handful of less-visible (with leading underscores) functions
which are useful for writing other libraries.

nano API
========

- **`_joina <delimiter> <array_name> <return_variable>`** - joins the
  elements of the array `array_name` with the character `delimiter`

  *Returns*: the joined string in the variable `return_variable_name`

  `return_variable` must be declared by the function calling `_joina`.

- **`_puts <string>`** - prints `string` with a newline

  *Returns*: the string, with newline, on stdout

  Uses the POSIX-recommended `printf` function instead of `echo`.
  Unlike `echo`, `string` must be a single argument.

- **`_putserr <string>`** - prints `string` with a newline to stderr

  *Returns*: the string, with newline, on stderr

  `string` must be a single argument.

- **`_ret <return_variable> <string_value|array_name|hash_name>`** -
  return a value via a named return variable

  *Returns*: the value, in `return_variable`

  `return_variable` must exist outside of your function scope, usually
  declared by your function's caller.  The existing variable must also
  be the appropriate type; scalar, array or hash (a.k.a.  associative
  array).

  `return_variable` is therefore usually passed into your function as an
  argument, which is then passed onto `_ret`.

  Example:

      myfunc () {
        return_variable=$1

        local "$return_variable" || return
        _ret "$return_variable" 'my value' # pass back a string
      }

  You could accomplish the same thing without `_ret` by using a
  indirection via `local -n ref` or `${!ref}`, but both of these allow
  the referenced variable name to conflict with your local variables.
  `_ret` prevents naming conflicts with your local variables.

  Before calling `_ret`, your function must also declare
  `return_variable` locally, as shown.  Since the variable name may not
  be a valid identifier string, this is usually done with a `return`
  clause in case it errors.  This should only be done right before
  calling `_ret`.

  Calling `_ret` unsets the named variable in your function's scope.
  If the variable name is also used by one of your local variables
  (always possible), then your variable will be unset.  Therefore you
  may not be able to rely on variables after calling `_ret`, so you
  should only do so right before your function returns.

  The returned value(s) may be a scalar value, or may be contained in
  a named array or hash.  If passing an array or hash, simply use the
  variable name as the second argument.  If passing back a scalar
  value, use the value, not its variable name (if stored in a
  variable).

  As a corollary, the `_ret` function is unable to pass back the names
  of arrays or hashes as scalar values.  They will always be passed as
  their array values.  Be forewarned.

  `_ret` is based on the discussion [here], but is enhanced to pass
  arrays by name.

[here]: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
