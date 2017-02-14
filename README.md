nano
====

A nano-sized bash library

Defines a handful of less-visible (with leading underscores) functions
that are useful for writing other libraries.

API
===

- **`_puts <string>`** - prints `<string>` with a newline

    Unlike `echo`, `string` must be a single argument.

- **`_putserr <string>`** - prints `<string>` with a newline to stderr

    Unlike `echo`, `string` must be a single argument.

- **`_ret <return_variable_name> <string_value|array_name|hash_name>`**
  - return a value via a named reference variable

    `return_variable_name` must exist outside of your function
    (usually declared by its caller) and be the appropriate type
    (scalar, array, hash).  A hash is more properly known as an
    associative array.

    `return_variable_name` is therefore usually passed into your
    function.  Example:

        myfunc () {
          return_variable_name=$1

          local "$return_variable_name" || return
          _ret "$return_variable_name" 'my_value'
        }

    Before calling `_ret`, your function must also declare
    `return_variable_name` locally.  Since the variable name may not
    be a valid identifier string, this is usually done with a `return`
    clause in case it errors.

    The returned value may be a scalar literal, or may be contained in a
    named array or hash.  If passing back an array or hash, simply pass
    the name as the second argument.  If passing back a scalar value,
    use the value, not the variable name.

    As a corollary, the `_ret` function is unable to pass back the names
    of valid arrays or hashes as scalar values.  They will always be
    passed as their array values.
