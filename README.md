# Zipper

The wrapper for [libzip](https://libzip.org/) that allows to deal with zip-archives with ease.

## Project status

Currently project is in alpha stage, thus everything may be changed.

## Examples

```d
// Read zip archive
auto zip = Zipper(Path("test-data", "test-zip.zip"));

zip.num_entries;  // returns number of entries

foreach(entry; zip.entries) {  // List content of zip repo
    writeln(entry.name, entry.size);
}

// Read the entry from zip archive as array of chars.
// Currently there is no checks for type provided for template.
// Seems to be working with char and byte types.
zip["path/to/entry"].readFull!char;  

// Extract archive to some destination
zip.extractTo(Path("path", "to", "dest"));

// There is no need to close archive, it will be closed automatically
// when last reference to zip will be destroyed (in this case when zip var
// will be destroyed
```

```d
// Create new archive
auto zip = Zipper(Path("test-data", "test-zip.zip"), ZipMode.CREATE);

// Create directory inside archive
zip.addEntryDirectory("my-dir");

// Add file to archive
zip.addEntryFile(Path("path", "to", "file"), "my-dir/my-file.txt");

// Note that all changes will be written when archve close.
// Also, Zipper archive will be automatically closed when last reference
// to archive destroyed (Zipper uses RefCounted struct over libzip's zip_t
// object).

```

## License

This library is licensed under MPL-2.0 license.
The [libzip](https://libzip.org/) library is licensed under [MIT license](https://libzip.org/license/).
