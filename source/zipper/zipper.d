module zipper.zipper;

version(ZipperEnableLogger) private import std.logger;
private import std.typecons;
private import std.exception: enforce;
private import std.algorithm: canFind;
private import std.string: toStringz, join;
private import std.format: format;
private import std.algorithm.searching: endsWith, startsWith;

private import thepath: Path;

private import zipper.lib;

private import zipper;
private import zipper.entry;
private import zipper.internal;
private import zipper.exception;


/// Use this struct to deal with zip archives
struct Zipper {

    private:
        ZipPtr _zip_ptr;

        /// locate entry index by name
        auto locateByName(in string name) {
            // TODO: Handle errors (ZIP_ER_INVAL, ZIP_ER_MEMORY, ZIP_ER_NOENT)
            // See: https://libzip.org/documentation/zip_name_locate.html#ERRORS
            return zip_name_locate(
                _zip_ptr.zip_ptr, name.toStringz, ZIP_FL_ENC_GUESS);
        }
    public:
        /// Initialize zip archive
        this(in Path path, in ZipMode mode = ZipMode.READONLY) {
            int error_code;
            auto zip_obj = zip_open(
                path.toStringz, mode, &error_code);
            scope(failure) zip_close(zip_obj);
            enforce!ZipException(
                !error_code,
                "Cannot open zip archive %s in mode %s: %s".format(
                    path, mode, format_zip_error(error_code)));
            _zip_ptr = ZipPtr(zip_obj);
        }

        /// Get num entried
        auto num_entries() {
            return zip_get_num_entries(_zip_ptr.zip_ptr, ZIP_FL_ENC_GUESS);
        }

        /// Iterate over entries
        auto entries () {

            // Range iterator that allows to iterate over entries of zip archive
            struct ZipEntryIterator {
                private ZipPtr _zip_ptr;
                private ulong _index;
                private ulong _max_entries;
                private Nullable!ZipEntry _entry;

                this(ZipPtr zip_file, in ulong index=0) {
                    _zip_ptr = zip_file;
                    _index = index;
                    _max_entries = zip_get_num_entries(
                        _zip_ptr.zip_ptr, ZIP_FL_ENC_GUESS);
                }

                /** Check if iterator is consumed
                  **/
                bool empty() { return _index >= _max_entries; }

                /** Return front entry (if evalable)
                  **/
                auto front() {
                    if (_entry.isNull && _index < _max_entries)
                        _entry = ZipEntry(_zip_ptr, _index).nullable;
                    return _entry.get;
                }

                /** Pop front entry from iterator
                  **/
                void popFront() {
                    _entry.nullify;
                    _index++;
                }
            }

            return ZipEntryIterator(_zip_ptr);
        }

        /// Get entry by index or name
        auto entry(in ulong index) {
            return ZipEntry(_zip_ptr, index);
        }

        // TODO: Handle Path as a key for entry
        /// ditto
        auto entry(in string name) {
            auto index = locateByName(name);
            enforce!ZipException(
                index != -1,
                "Cannot locate %s in zip archive!".format(name));
            return entry(index);
        }

        /// Check if zip archive contains entry
        bool hasEntry(in string name) {
            auto index = locateByName(name);
            // if index is equal to -1, then such entry was not found
            return index >= 0;
        }

        /// Operator overload to easier access entries
        auto opIndex(in ulong index) {
            return entry(index);
        }

        /// ditto
        auto opIndex(in string name) {
            return entry(name);
        }

        /** Extract zip archive to destination directory

            Also, if zip folder contains single directory, Zipper can
            unpack its content directly to destination directory.
            To enable this feature, set **unfold_path** param to True.

            Params:
                destination = path to destination where to extract archive.
                unfold_path = if set, then unfold this path when unpacking.
        **/
        void extractTo(
                in Path destination,
                in string unfold_path=null) {
            enforce!ZipException(
                destination.isValid,
                "Destination path %s is not valid!".format(destination));

            // TODO: Add protection for unzipping out of destinantion

            // TODO: Do we need this?
            auto dest = destination.toAbsolute;

            // Check if we can unfold path
            if (unfold_path) {
                enforce!ZipException(
                    unfold_path.endsWith("/"),
                    "Unfold path must be ended with '/'");
                foreach(entry; this.entries) {
                    enforce!ZipException(
                        entry.name.startsWith(unfold_path),
                        "Cannot unfold path %s, because there is entry %s that is not under this path".format(
                            unfold_path, entry.name));
                }
            }

            // Create destination directory if not exists
            dest.mkdir(true);

            foreach(entry; this.entries) {
                string entry_name = entry.name.dup;

                if (unfold_path) {
                    if (entry_name == unfold_path) {
                        // Skip unfolded directory
                        continue;
                    }
                    entry_name = entry_name[unfold_path.length .. $];
                    enforce!ZipException(
                        entry_name,
                        "Entry name is empty after unfolding!");
                }

                // Path to unzip entry to
                auto entry_dst = dest.join(entry_name);
                enforce!ZipException(
                    entry_dst.isInside(dest),
                    "Attempt to unzip entry %s out of scope of destination (%s)".format(
                        entry.name, dest));

                // Unzip entry
                entry.unzipTo(entry_dst);
            }
        }

        /** Add empty directory to zip archive
          *
          * Notes:
          *     Use '/' as directory separator for name.
          *
          * Params:
          *     name = name of directory inside archive.
          *
          * Returns:
          *     ZipEntry that represents created directory
          **/
        ZipEntry addEntryDirectory(in string name) {
            version(ZipperEnableLogger)
                infof("Adding directory %s into zip archive...", name);
            auto entry_index = zip_dir_add(
                _zip_ptr.zip_ptr, name.toStringz, ZIP_FL_ENC_GUESS);
            enforce!ZipException(
                entry_index >=0,
                "Cannot add directory %s to zip archive: %s".format(
                    name, _zip_ptr.getErrorMsg));
            return entry(entry_index);
        }

        /** Add new file to zip archive
          *
          * Params:
          *     entry_path = path to original file to add to archive
          *     name = name of file inside archive
          *
          * Returns:
          *     ZipEntry that represents created file
          **/
        ZipEntry addEntryFile(in Path entry_path, in string name) {
            version(ZipperEnableLogger)
                infof(
                    "Adding file %s as %s into zip archive...",
                    entry_path, name);
            enforce!ZipException(
                entry_path.exists(),
                "Cannot add file %s: does not exists!".format(entry_path));
            auto source = zip_source_file(
                _zip_ptr.zip_ptr, entry_path.toStringz, 0, 0);
            auto entry_index = zip_file_add(
                _zip_ptr.zip_ptr, name.toStringz, source,
                ZIP_FL_OVERWRITE | ZIP_FL_ENC_GUESS);
            enforce!ZipException(
                entry_index >=0,
                "Cannot add directory %s to zip archive: %s".format(
                    name, _zip_ptr.getErrorMsg));
            return entry(entry_index);
        }

        /** Add directory or file to zip archive
          *
          * Params:
          *     path = Path to directory or file to add into zip archive
          *     prefix = prefix to add to files or directories before adding
          *         to archive
          **/
        auto ref add(in Path path, in string prefix) {
            enforce!ZipException(
                !prefix.canFind("/"),
                "'/' in prefix is not supported in current version!");
            if (prefix.length > 0 && !hasEntry(prefix ~ "/"))
                addEntryDirectory(prefix);

            if (path.isFile) {
                enforce!ZipException(
                    !path.isSymlink,
                    "Archiving symlinks is not supported yet!");
                addEntryFile(
                    path,
                    prefix.length > 0 ?
                        prefix ~ "/" ~ path.baseName :
                        path.baseName);
            } else {
                const auto root_path = path.toAbsolute;
                foreach(p; root_path.walkBreadth) {
                    enforce!ZipException(
                        !p.isSymlink,
                        "Archiving symlinks is not supported yet!");
                    const string name = [
                        prefix,
                        p.relativeTo(root_path).segments.join("/"),
                    ].join("/");
                    if (p.isDir)
                        addEntryDirectory(name);
                    else
                        addEntryFile(p, name);
                }
            }
            return this;
        }

        /// ditto
        auto ref add(in Path path) {
            auto prefix = path.isDir ? path.baseName : "";
            return add(path, prefix);
        }
}

/// Example of analyzing archive
unittest {
    import unit_threaded.assertions;

    // Zipfile will be closed automatically when zip is out of scope.
    auto zip = Zipper(Path("test-data", "test-zip.zip"));

    zip.num_entries.shouldEqual(7);

    zip.hasEntry("test-zip/").shouldBeTrue();
    zip["test-zip/"].is_directory.shouldBeTrue();

    zip.hasEntry("test-zip/test.txt").shouldBeTrue();
    zip["test-zip/test.txt"].is_symlink.shouldBeFalse();
    zip["test-zip/test.txt"].readFull!char.shouldEqual("Test Root\n");

    zip.hasEntry("test-zip/test-dir/test.txt").shouldBeTrue();
    zip["test-zip/test-dir/test.txt"].is_symlink.shouldBeFalse();
    zip["test-zip/test-dir/test.txt"].readFull!char.shouldEqual("Hello World!\n");

    zip.hasEntry("test-zip/test-link-1.txt").shouldBeTrue();
    zip["test-zip/test-link-1.txt"].is_symlink.shouldBeTrue();
    zip["test-zip/test-link-1.txt"].readLink.shouldEqual(Path("test-dir", "test.txt"));
    zip["test-zip/test-link-1.txt"].readFull!char.shouldEqual("Hello World!\n");

    zip.hasEntry("test-zip/test-dir/test-link.txt").shouldBeTrue();
    zip["test-zip/test-dir/test-link.txt"].is_symlink.shouldBeTrue();
    zip["test-zip/test-dir/test-link.txt"].readLink.shouldEqual(Path("test.txt"));
    zip["test-zip/test-dir/test-link.txt"].readFull!char.shouldEqual("Hello World!\n");

    zip.hasEntry("test-zip/test-dir/test-parent.txt").shouldBeTrue();
    zip["test-zip/test-dir/test-parent.txt"].is_symlink.shouldBeTrue();
    zip["test-zip/test-dir/test-parent.txt"].readLink.shouldEqual(Path("..", "test.txt"));
    zip["test-zip/test-dir/test-parent.txt"].readFull!char.shouldEqual("Test Root\n");
}

/// Example of unarchiving archive
unittest {
    import unit_threaded.assertions;
    import thepath: createTempPath;

    Path temp_root = createTempPath("test-zip");
    scope(exit) temp_root.remove();

    Zipper(Path("test-data", "test-zip.zip")).extractTo(temp_root.join("res"));

    temp_root.join("res", "test-zip").exists().shouldBeTrue();
    temp_root.join("res", "test-zip").isDir().shouldBeTrue();

    temp_root.join("res", "test-zip", "test.txt").exists().shouldBeTrue();
    temp_root.join("res", "test-zip", "test.txt").isFile().shouldBeTrue();
    temp_root.join("res", "test-zip", "test.txt").readFileText().shouldEqual("Test Root\n");

    temp_root.join("res", "test-zip", "test-dir", "test.txt").exists().shouldBeTrue();
    temp_root.join("res", "test-zip", "test-dir", "test.txt").isFile().shouldBeTrue();
    temp_root.join("res", "test-zip", "test-dir", "test.txt").readFileText().shouldEqual("Hello World!\n");

    temp_root.join("res", "test-zip", "test-link-1.txt").exists().shouldBeTrue();
    temp_root.join("res", "test-zip", "test-link-1.txt").isSymlink().shouldBeTrue();
    temp_root.join("res", "test-zip", "test-link-1.txt").readLink().shouldEqual(
        Path("test-dir", "test.txt"));
    temp_root.join("res", "test-zip", "test-link-1.txt").readFileText().shouldEqual("Hello World!\n");

    temp_root.join("res", "test-zip", "test-dir", "test-link.txt").exists().shouldBeTrue();
    temp_root.join("res", "test-zip", "test-dir", "test-link.txt").isSymlink().shouldBeTrue();
    temp_root.join("res", "test-zip", "test-dir", "test-link.txt").readLink().shouldEqual(
        Path("test.txt"));
    temp_root.join("res", "test-zip", "test-dir", "test-link.txt").readFileText().shouldEqual("Hello World!\n");

    temp_root.join("res", "test-zip", "test-dir", "test-parent.txt").exists().shouldBeTrue();
    temp_root.join("res", "test-zip", "test-dir", "test-parent.txt").isSymlink().shouldBeTrue();
    temp_root.join("res", "test-zip", "test-dir", "test-parent.txt").readLink().shouldEqual(
        Path("..", "test.txt"));
    temp_root.join("res", "test-zip", "test-dir", "test-parent.txt").readFileText().shouldEqual("Test Root\n");
}

/// Example of unarchiving archive to already existing directory
unittest {
    import unit_threaded.assertions;
    import thepath: createTempPath;

    Path temp_root = createTempPath("test-zip");
    scope(exit) temp_root.remove();

    Zipper(Path("test-data", "test-zip.zip")).extractTo(temp_root);

    temp_root.join("test-zip").exists().shouldBeTrue();
    temp_root.join("test-zip").isDir().shouldBeTrue();

    temp_root.join("test-zip", "test.txt").exists().shouldBeTrue();
    temp_root.join("test-zip", "test.txt").isFile().shouldBeTrue();
    temp_root.join("test-zip", "test.txt").readFileText().shouldEqual("Test Root\n");

    temp_root.join("test-zip", "test-dir", "test.txt").exists().shouldBeTrue();
    temp_root.join("test-zip", "test-dir", "test.txt").isFile().shouldBeTrue();
    temp_root.join("test-zip", "test-dir", "test.txt").readFileText().shouldEqual("Hello World!\n");

    temp_root.join("test-zip", "test-link-1.txt").exists().shouldBeTrue();
    temp_root.join("test-zip", "test-link-1.txt").isSymlink().shouldBeTrue();
    temp_root.join("test-zip", "test-link-1.txt").readLink().shouldEqual(
        Path("test-dir", "test.txt"));
    temp_root.join("test-zip", "test-link-1.txt").readFileText().shouldEqual("Hello World!\n");

    temp_root.join("test-zip", "test-dir", "test-link.txt").exists().shouldBeTrue();
    temp_root.join("test-zip", "test-dir", "test-link.txt").isSymlink().shouldBeTrue();
    temp_root.join("test-zip", "test-dir", "test-link.txt").readLink().shouldEqual(
        Path("test.txt"));
    temp_root.join("test-zip", "test-dir", "test-link.txt").readFileText().shouldEqual("Hello World!\n");

    temp_root.join("test-zip", "test-dir", "test-parent.txt").exists().shouldBeTrue();
    temp_root.join("test-zip", "test-dir", "test-parent.txt").isSymlink().shouldBeTrue();
    temp_root.join("test-zip", "test-dir", "test-parent.txt").readLink().shouldEqual(
        Path("..", "test.txt"));
    temp_root.join("test-zip", "test-dir", "test-parent.txt").readFileText().shouldEqual("Test Root\n");
}

/// Example of creation of archive
unittest {
    import unit_threaded.assertions;
    import thepath: createTempPath;

    Path temp_root = createTempPath("test-zip");
    scope(exit) temp_root.remove();

    {
        // Do it in subscope to ensure that zip file closed when out of scope
        auto zip = Zipper(temp_root.join("my.zip"), ZipMode.CREATE);
        zip.addEntryDirectory("test-data");
        zip.addEntryFile(
            Path("test-data", "addons-list.txt"),
            "test-data/addons-list.txt");

        zip.addEntryFile(
            Path("test-data", "odoo.test.2.log"),
            "test-data/odoo.test.2.log");
    }

    auto zip = Zipper(temp_root.join("my.zip"));
    zip.num_entries.shouldEqual(3);

    zip.hasEntry("test-data/").shouldBeTrue();
    zip["test-data/"].is_directory.shouldBeTrue();

    zip.hasEntry("test-data/addons-list.txt").shouldBeTrue();
    zip["test-data/addons-list.txt"].readFull!char.shouldEqual(
        Path("test-data", "addons-list.txt").readFileText());

    zip.hasEntry("test-data/odoo.test.2.log").shouldBeTrue();
    zip["test-data/odoo.test.2.log"].readFull!char.shouldEqual(
        Path("test-data", "odoo.test.2.log").readFileText());
}

/// Test creation of archive, when one of items to be added removed before
/// archive closed (changes commited)
unittest {
    import unit_threaded.assertions;
    import thepath: createTempPath;

    Path temp_root = createTempPath("test-zip");
    scope(exit) temp_root.remove();

    temp_root.join("test-disapearing-item.txt").writeFile("Hello world!");

    () {
        // Do it in subscope to ensure that zip file closed when out of scope
        auto zip = Zipper(temp_root.join("my.zip"), ZipMode.CREATE);
        zip.addEntryDirectory("test-data");
        zip.addEntryFile(
            Path("test-data", "addons-list.txt"),
            "test-data/addons-list.txt");

        zip.addEntryFile(
            temp_root.join("test-disapearing-item.txt"),
            "test-data/test-disapearing-item.txt");

        temp_root.join("test-disapearing-item.txt").remove;

    }().shouldThrow!ZipException;
}


/// Example of creation of archive from directory
unittest {
    import unit_threaded.assertions;
    import thepath: createTempPath;

    Path temp_root = createTempPath("test-zip");
    scope(exit) temp_root.remove();

    {
        // Do it in subscope to ensure that zip file closed when out of scope
        auto zip = Zipper(temp_root.join("my.zip"), ZipMode.CREATE);
        zip.add(Path("test-data"));
    }

    auto zip = Zipper(temp_root.join("my.zip"));
    zip.num_entries.shouldEqual(4);

    zip.hasEntry("test-data/").shouldBeTrue();
    zip["test-data/"].is_directory.shouldBeTrue();

    zip.hasEntry("test-data/addons-list.txt").shouldBeTrue();
    zip["test-data/addons-list.txt"].readFull!char.shouldEqual(
        Path("test-data", "addons-list.txt").readFileText());

    zip.hasEntry("test-data/odoo.test.2.log").shouldBeTrue();
    zip["test-data/odoo.test.2.log"].readFull!char.shouldEqual(
        Path("test-data", "odoo.test.2.log").readFileText());

    zip.hasEntry("test-data/test-zip.zip").shouldBeTrue();
}


/// Example of creation of archive from files
unittest {
    import unit_threaded.assertions;
    import thepath: createTempPath;

    Path temp_root = createTempPath("test-zip");
    scope(exit) temp_root.remove();

    {
        // Do it in subscope to ensure that zip file closed when out of scope
        Zipper(temp_root.join("my.zip"), ZipMode.CREATE)
            .add(Path("test-data", "addons-list.txt"))
            .add(Path("test-data", "odoo.test.2.log"));
    }

    auto zip = Zipper(temp_root.join("my.zip"));
    zip.num_entries.shouldEqual(2);

    zip.hasEntry("addons-list.txt").shouldBeTrue();
    zip["addons-list.txt"].readFull!char.shouldEqual(
        Path("test-data", "addons-list.txt").readFileText());

    zip.hasEntry("odoo.test.2.log").shouldBeTrue();
    zip["odoo.test.2.log"].readFull!char.shouldEqual(
        Path("test-data", "odoo.test.2.log").readFileText());
}


/// Example of creation of archive from files with prefix
unittest {
    import unit_threaded.assertions;
    import thepath: createTempPath;

    Path temp_root = createTempPath("test-zip");
    scope(exit) temp_root.remove();

    {
        // Do it in subscope to ensure that zip file closed when out of scope
        Zipper(temp_root.join("my.zip"), ZipMode.CREATE)
            .add(Path("test-data", "addons-list.txt"), "my-dir")
            .add(Path("test-data", "odoo.test.2.log"), "my-dir");
    }

    auto zip = Zipper(temp_root.join("my.zip"));
    zip.num_entries.shouldEqual(3);

    zip.hasEntry("my-dir/addons-list.txt").shouldBeTrue();
    zip["my-dir/addons-list.txt"].readFull!char.shouldEqual(
        Path("test-data", "addons-list.txt").readFileText());

    zip.hasEntry("my-dir/odoo.test.2.log").shouldBeTrue();
    zip["my-dir/odoo.test.2.log"].readFull!char.shouldEqual(
        Path("test-data", "odoo.test.2.log").readFileText());
}
