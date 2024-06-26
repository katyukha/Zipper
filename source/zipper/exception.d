module zipper.exception;

private import std.exception: enforce, basicExceptionCtors;
private import std.string: fromStringz;

private import zipper.lib;


/// Base exception class for Zipper errors
class ZipException : Exception
{
    mixin basicExceptionCtors;
}


/** Convert ZIP error specified by error_code to string
  *
  * Params:
  *     error_code = Code of error
  * Returns:
  *     string that contains error message
  **/
package string format_zip_error(int error_code) @trusted {
    zip_error_t error;
    zip_error_init_with_code(&error, error_code);
    scope(exit) zip_error_fini(&error);
    return zip_error_strerror(&error).fromStringz.idup;
}
