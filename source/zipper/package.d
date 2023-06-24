module zipper;

public import zipper.zipper: Zipper;
public import zipper.internal: ZipMode;
public import zipper.exception: ZipException;


private import deimos.zip: zip_libzip_version;

/// Returns version of libzip library
string getLibZipVersion() {
    import std.string;
    return zip_libzip_version.fromStringz.idup;
}

