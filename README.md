nano
====

A nano-sized bash library

Defines a handful of less-visible (with leading underscores) functions
which are useful for writing other libraries.

API
===

- **`_puts <string>`** - prints `<string>` with a newline

    Uses the POSIX-recommended `printf` function instead of `echo`.
    Unlike `echo`, `string` must be a single argument.

- **`_putserr <string>`** - prints `<string>` with a newline to stderr

    `string` must be a single argument.

- **`_ret <return_variable_name> <string_value|array_name|hash_name>`** -
  return a value via a named reference variable

    `return_variable_name` must exist outside of your function scope,
    usually declared by its caller.  It must also be the appropriate
    type; scalar, array or hash.  (A hash is more properly known as an
    associative array)

    `return_variable_name` is therefore usually passed into your
    function.  Example:

        myfunc () {
          return_variable_name=$1

          local "$return_variable_name" || return
          _ret "$return_variable_name" 'my_value'
        }

    Before calling `_ret`, your function must also declare
    `return_variable_name` locally, as shown.  Since the variable name
    may not be a valid identifier string, this is usually done with a
    `return` clause in case it errors.  This should also only be done
    right before calling `_ret`.

    Calling `_ret` unsets the named value in your function's scope.  If
    the variable name is used by one of your local variables (always
    possible), then your variable will be unset.  Therefore you may not
    be able to rely on variables after calling `_ret`, so you should
    only do so right before your function returns.

    The returned value(s) may be a scalar literal, or may be contained
    in a named array or hash.  If passing back an array or hash, simply
    pass the variable name as the second argument.  If passing back a
    scalar value, use the value, not the variable name.

    As a corollary, the `_ret` function is unable to pass back the names
    of arrays or hashes as scalar values.  They will always be passed as
    their array values.  Caveat emptor.
