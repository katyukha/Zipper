module zipper.internal;

private import std.typecons;
private import std.string: fromStringz;
private import std.format: format;

private import zipper.deimos.zip;

private import zipper.exception;

immutable BUF_SIZE = 1024;

enum ZipMode {
    CREATE = ZIP_CREATE,
    EXCLUSIVE = ZIP_EXCL,
    TRUNCATE = ZIP_TRUNCATE,
    READONLY = ZIP_RDONLY,
    CHECK_CONSISTENCY = ZIP_CHECKCONS,
};

package:

    /** Payload of ref-counted struct for zip-archive pointer
      **/
    private struct ZipPtrInternal {
        private zip_t* _zip_ptr;

        this(zip_t* zip_ptr) {
            this._zip_ptr = zip_ptr;
        }

        ~this() {
            if (_zip_ptr !is null) {
                close();
            }
        }

        // Must not be copiable
        @disable this(this);

        // Must not be assignable
        @disable void opAssign(typeof(this));

        zip_t* zip_ptr() { return _zip_ptr; }

        // getErrorMsg
        auto getErrorMsg() {
            auto error_msg = zip_error_strerror(
                zip_get_error(_zip_ptr)
            ).fromStringz;
            return error_msg;
        }

        void close() {
            if (zip_close(_zip_ptr) != 0) {
                auto error_msg = getErrorMsg();
                zip_discard(_zip_ptr);
                _zip_ptr = null;
                throw new ZipException(
                    "Cannot close zip archive: %s".format(error_msg));
            }
            _zip_ptr = null;
        }
    }

    /// Ref-counted pointer to zip archive
    alias RefCounted!(ZipPtrInternal, RefCountedAutoInitialize.no) ZipPtr;
