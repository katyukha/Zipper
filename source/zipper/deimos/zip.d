module zipper.deimos.zip;

/*
  zip.h -- exported declarations.
  Copyright (C) 1999-2021 Dieter Baron and Thomas Klausner

  This file is part of libzip, a library to manipulate ZIP archives.
  The authors can be contacted at <info@libzip.org>

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:
  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.
  3. The names of the authors may not be used to endorse or promote
     products derived from this software without specific prior
     written permission.

  THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS
  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Added here to make available usage of FILE and time_t
public import core.stdc.time;
public import core.stdc.stdio;

/* Notes

Following definitions relaced by standard d types.
Possibly it have sense to revert this change, and use aliases instead.
    ZIP_UINT16_MAX = ushort.max
    zip_int64_t = long
    zip_uint64_t = ulong
    zip_uint32_t = uint
    zip_uint16_t = ushort
    zip_uint8_t = ubyte
*/

extern (C):
@nogc nothrow:

/* flags for zip_open */

enum ZIP_CREATE = 1;
enum ZIP_EXCL = 2;
enum ZIP_CHECKCONS = 4;
enum ZIP_TRUNCATE = 8;
enum ZIP_RDONLY = 16;


/* flags for zip_name_locate, zip_fopen, zip_stat, ... */

enum ZIP_FL_NOCASE = 1u       /* ignore case on name lookup */;
enum ZIP_FL_NODIR = 2u        /* ignore directory component */;
enum ZIP_FL_COMPRESSED = 4u   /* read compressed data */;
enum ZIP_FL_UNCHANGED = 8u    /* use original data, ignoring changes */;
enum ZIP_FL_RECOMPRESS = 16u  /* force recompression of data */;
enum ZIP_FL_ENCRYPTED = 32u   /* read encrypted data (implies ZIP_FL_COMPRESSED) */;
enum ZIP_FL_ENC_GUESS = 0u    /* guess string encoding (is default) */;
enum ZIP_FL_ENC_RAW = 64u     /* get unmodified string */;
enum ZIP_FL_ENC_STRICT = 128u /* follow specification strictly */;
enum ZIP_FL_LOCAL = 256u      /* in local header */;
enum ZIP_FL_CENTRAL = 512u    /* in central directory */;
/*                           1024u    reserved for internal use */
enum ZIP_FL_ENC_UTF_8 = 2048u /* string is UTF-8 encoded */;
enum ZIP_FL_ENC_CP437 = 4096u /* string is CP437 encoded */;
enum ZIP_FL_OVERWRITE = 8192u /* zip_file_add: if file with name exists, overwrite (replace) it */;

/* archive global flags flags */

enum ZIP_AFL_RDONLY = 2u /* read only -- cannot be cleared */;


/* create a new extra field */

enum ZIP_EXTRA_FIELD_ALL = ushort.max;  //ZIP_UINT16_MAX;
enum ZIP_EXTRA_FIELD_NEW = ushort.max;  //ZIP_UINT16_MAX;


/* libzip error codes */

enum ZIP_ER_OK = 0               /* N No error */;
enum ZIP_ER_MULTIDISK = 1        /* N Multi-disk zip archives not supported */;
enum ZIP_ER_RENAME = 2           /* S Renaming temporary file failed */;
enum ZIP_ER_CLOSE = 3            /* S Closing zip archive failed */;
enum ZIP_ER_SEEK = 4             /* S Seek error */;
enum ZIP_ER_READ = 5             /* S Read error */;
enum ZIP_ER_WRITE = 6            /* S Write error */;
enum ZIP_ER_CRC = 7              /* N CRC error */;
enum ZIP_ER_ZIPCLOSED = 8        /* N Containing zip archive was closed */;
enum ZIP_ER_NOENT = 9            /* N No such file */;
enum ZIP_ER_EXISTS = 10          /* N File already exists */;
enum ZIP_ER_OPEN = 11            /* S Can't open file */;
enum ZIP_ER_TMPOPEN = 12         /* S Failure to create temporary file */;
enum ZIP_ER_ZLIB = 13            /* Z Zlib error */;
enum ZIP_ER_MEMORY = 14          /* N Malloc failure */;
enum ZIP_ER_CHANGED = 15         /* N Entry has been changed */;
enum ZIP_ER_COMPNOTSUPP = 16     /* N Compression method not supported */;
enum ZIP_ER_EOF = 17             /* N Premature end of file */;
enum ZIP_ER_INVAL = 18           /* N Invalid argument */;
enum ZIP_ER_NOZIP = 19           /* N Not a zip archive */;
enum ZIP_ER_INTERNAL = 20        /* N Internal error */;
enum ZIP_ER_INCONS = 21          /* L Zip archive inconsistent */;
enum ZIP_ER_REMOVE = 22          /* S Can't remove file */;
enum ZIP_ER_DELETED = 23         /* N Entry has been deleted */;
enum ZIP_ER_ENCRNOTSUPP = 24     /* N Encryption method not supported */;
enum ZIP_ER_RDONLY = 25          /* N Read-only archive */;
enum ZIP_ER_NOPASSWD = 26        /* N No password provided */;
enum ZIP_ER_WRONGPASSWD = 27     /* N Wrong password provided */;
enum ZIP_ER_OPNOTSUPP = 28       /* N Operation not supported */;
enum ZIP_ER_INUSE = 29           /* N Resource still in use */;
enum ZIP_ER_TELL = 30            /* S Tell error */;
enum ZIP_ER_COMPRESSED_DATA = 31 /* N Compressed data invalid */;
enum ZIP_ER_CANCELLED = 32       /* N Operation cancelled */;

/* type of system error value */

enum ZIP_ET_NONE = 0   /* sys_err unused */;
enum ZIP_ET_SYS = 1    /* sys_err is errno */;
enum ZIP_ET_ZLIB = 2   /* sys_err is zlib error code */;
enum ZIP_ET_LIBZIP = 3 /* sys_err is libzip error code */;

/* compression methods */

enum ZIP_CM_DEFAULT = -1 /* better of deflate or store */;
enum ZIP_CM_STORE = 0    /* stored (uncompressed) */;
enum ZIP_CM_SHRINK = 1   /* shrunk */;
enum ZIP_CM_REDUCE_1 = 2 /* reduced with factor 1 */;
enum ZIP_CM_REDUCE_2 = 3 /* reduced with factor 2 */;
enum ZIP_CM_REDUCE_3 = 4 /* reduced with factor 3 */;
enum ZIP_CM_REDUCE_4 = 5 /* reduced with factor 4 */;
enum ZIP_CM_IMPLODE = 6  /* imploded */;
/* 7 - Reserved for Tokenizing compression algorithm */
enum ZIP_CM_DEFLATE = 8         /* deflated */;
enum ZIP_CM_DEFLATE64 = 9       /* deflate64 */;
enum ZIP_CM_PKWARE_IMPLODE = 10 /* PKWARE imploding */;
/* 11 - Reserved by PKWARE */
enum ZIP_CM_BZIP2 = 12 /* compressed using BZIP2 algorithm */;
/* 13 - Reserved by PKWARE */
enum ZIP_CM_LZMA = 14 /* LZMA (EFS) */;
/* 15-17 - Reserved by PKWARE */
enum ZIP_CM_TERSE = 18 /* compressed using IBM TERSE (new) */;
enum ZIP_CM_LZ77 = 19  /* IBM LZ77 z Architecture (PFS) */;
/* 20 - old value for Zstandard */
enum ZIP_CM_LZMA2 = 33;
enum ZIP_CM_ZSTD = 93    /* Zstandard compressed data */;
enum ZIP_CM_XZ = 95      /* XZ compressed data */;
enum ZIP_CM_JPEG = 96    /* Compressed Jpeg data */;
enum ZIP_CM_WAVPACK = 97 /* WavPack compressed data */;
enum ZIP_CM_PPMD = 98    /* PPMd version I, Rev 1 */;

/* encryption methods */

enum ZIP_EM_NONE = 0         /* not encrypted */;
enum ZIP_EM_TRAD_PKWARE = 1  /* traditional PKWARE encryption */;
// #if 0                         /* Strong Encryption Header not parsed yet */
// #define ZIP_EM_DES 0x6601     /* strong encryption: DES */
// #define ZIP_EM_RC2_OLD 0x6602 /* strong encryption: RC2, version < 5.2 */
// #define ZIP_EM_3DES_168 0x6603
// #define ZIP_EM_3DES_112 0x6609
// #define ZIP_EM_PKZIP_AES_128 0x660e
// #define ZIP_EM_PKZIP_AES_192 0x660f
// #define ZIP_EM_PKZIP_AES_256 0x6610
// #define ZIP_EM_RC2 0x6702 /* strong encryption: RC2, version >= 5.2 */
// #define ZIP_EM_RC4 0x6801
// #endif
enum ZIP_EM_AES_128 = 0x0101 /* Winzip AES encryption */;
enum ZIP_EM_AES_192 = 0x0102;
enum ZIP_EM_AES_256 = 0x0103;
enum ZIP_EM_UNKNOWN = 0xffff /* unknown algorithm */;

enum ZIP_OPSYS_DOS = 0x00u;
enum ZIP_OPSYS_AMIGA = 0x01u;
enum ZIP_OPSYS_OPENVMS = 0x02u;
enum ZIP_OPSYS_UNIX = 0x03u;
enum ZIP_OPSYS_VM_CMS = 0x04u;
enum ZIP_OPSYS_ATARI_ST = 0x05u;
enum ZIP_OPSYS_OS_2 = 0x06u;
enum ZIP_OPSYS_MACINTOSH = 0x07u;
enum ZIP_OPSYS_Z_SYSTEM = 0x08u;
enum ZIP_OPSYS_CPM = 0x09u;
enum ZIP_OPSYS_WINDOWS_NTFS = 0x0au;
enum ZIP_OPSYS_MVS = 0x0bu;
enum ZIP_OPSYS_VSE = 0x0cu;
enum ZIP_OPSYS_ACORN_RISC = 0x0du;
enum ZIP_OPSYS_VFAT = 0x0eu;
enum ZIP_OPSYS_ALTERNATE_MVS = 0x0fu;
enum ZIP_OPSYS_BEOS = 0x10u;
enum ZIP_OPSYS_TANDEM = 0x11u;
enum ZIP_OPSYS_OS_400 = 0x12u;
enum ZIP_OPSYS_OS_X = 0x13u;

enum ZIP_OPSYS_DEFAULT = ZIP_OPSYS_UNIX;
// end

enum zip_source_cmd {
    ZIP_SOURCE_OPEN,                /* prepare for reading */
    ZIP_SOURCE_READ,                /* read data */
    ZIP_SOURCE_CLOSE,               /* reading is done */
    ZIP_SOURCE_STAT,                /* get meta information */
    ZIP_SOURCE_ERROR,               /* get error information */
    ZIP_SOURCE_FREE,                /* cleanup and free resources */
    ZIP_SOURCE_SEEK,                /* set position for reading */
    ZIP_SOURCE_TELL,                /* get read position */
    ZIP_SOURCE_BEGIN_WRITE,         /* prepare for writing */
    ZIP_SOURCE_COMMIT_WRITE,        /* writing is done */
    ZIP_SOURCE_ROLLBACK_WRITE,      /* discard written changes */
    ZIP_SOURCE_WRITE,               /* write data */
    ZIP_SOURCE_SEEK_WRITE,          /* set position for writing */
    ZIP_SOURCE_TELL_WRITE,          /* get write position */
    ZIP_SOURCE_SUPPORTS,            /* check whether source supports command */
    ZIP_SOURCE_REMOVE,              /* remove file */
    ZIP_SOURCE_RESERVED_1,          /* previously used internally */
    ZIP_SOURCE_BEGIN_WRITE_CLONING, /* like ZIP_SOURCE_BEGIN_WRITE, but keep part of original file */
    ZIP_SOURCE_ACCEPT_EMPTY,        /* whether empty files are valid archives */
    ZIP_SOURCE_GET_FILE_ATTRIBUTES  /* get additional file attributes */
};
alias zip_source_cmd_t = zip_source_cmd;

extern (D) auto ZIP_SOURCE_MAKE_COMMAND_BITMASK(T)(auto ref T cmd)
{
    return (cast(long) 1) << cmd;
}

extern (D) auto ZIP_SOURCE_CHECK_SUPPORTED(T0, T1)(auto ref T0 supported, auto ref T1 cmd)
{
    return (supported & ZIP_SOURCE_MAKE_COMMAND_BITMASK(cmd)) != 0;
}

/* clang-format off */

enum ZIP_SOURCE_SUPPORTS_READABLE = ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_OPEN) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_READ) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_CLOSE) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_STAT) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_ERROR) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_FREE);

enum ZIP_SOURCE_SUPPORTS_SEEKABLE = ZIP_SOURCE_SUPPORTS_READABLE | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_SEEK) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_TELL) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_SUPPORTS);

enum ZIP_SOURCE_SUPPORTS_WRITABLE = ZIP_SOURCE_SUPPORTS_SEEKABLE | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_BEGIN_WRITE) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_COMMIT_WRITE) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_ROLLBACK_WRITE) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_WRITE) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_SEEK_WRITE) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_TELL_WRITE) | ZIP_SOURCE_MAKE_COMMAND_BITMASK(zip_source_cmd_t.ZIP_SOURCE_REMOVE);

/* clang-format on */

/* for use by sources */
struct zip_source_args_seek {
    long offset;
    int whence;
};

alias zip_source_args_seek_t = zip_source_args_seek;

/* error information */
/* use zip_error_*() to access */
struct zip_error {
    int zip_err;         /* libzip error code (ZIP_ER_*) */
    int sys_err;         /* copy of errno (E*) or zlib error code */
    char* str; /* string representation or NULL */
};

enum ZIP_STAT_NAME = 0x0001u;
enum ZIP_STAT_INDEX = 0x0002u;
enum ZIP_STAT_SIZE = 0x0004u;
enum ZIP_STAT_COMP_SIZE = 0x0008u;
enum ZIP_STAT_MTIME = 0x0010u;
enum ZIP_STAT_CRC = 0x0020u;
enum ZIP_STAT_COMP_METHOD = 0x0040u;
enum ZIP_STAT_ENCRYPTION_METHOD = 0x0080u;
enum ZIP_STAT_FLAGS = 0x0100u;

// Port note: Renamed because of conflic with zip_stat func.
struct zip_stat_t {
    ulong valid;             /* which fields have valid values */
    const char* name;     /* name of the file */
    ulong index;             /* index within archive */
    ulong size;              /* size of file (uncompressed) */
    ulong comp_size;         /* size of file (compressed) */
    time_t mtime;                   /* modification time */
    uint crc;               /* crc of file data */
    ushort comp_method;       /* compression method used */
    ushort encryption_method; /* encryption method used */
    uint flags;             /* reserved for future use */
};

struct zip_buffer_fragment {
    ubyte * data;
    ulong length;
};

struct zip_file_attributes {
    ulong valid;                     /* which fields have valid values */
    ubyte _version;                   /* version of this struct, currently 1 */
    ubyte host_system;                /* host system on which file was created */
    ubyte ascii;                      /* flag whether file is ASCII text */
    ubyte version_needed;             /* minimum version needed to extract file */
    uint external_file_attributes;  /* external file attributes (host-system specific) */
    ushort general_purpose_bit_flags; /* general purpose big flags, only some bits are honored */
    ushort general_purpose_bit_mask;  /* which bits in general_purpose_bit_flags are valid */
};


enum ZIP_FILE_ATTRIBUTES_HOST_SYSTEM = 0x0001u;
enum ZIP_FILE_ATTRIBUTES_ASCII = 0x0002u;
enum ZIP_FILE_ATTRIBUTES_VERSION_NEEDED = 0x0004u;
enum ZIP_FILE_ATTRIBUTES_EXTERNAL_FILE_ATTRIBUTES = 0x0008u;
enum ZIP_FILE_ATTRIBUTES_GENERAL_PURPOSE_BIT_FLAGS = 0x0010u;

struct zip;
struct zip_file;
struct zip_source;

alias zip_t = zip;
alias zip_error_t = zip_error;
alias zip_file_t = zip_file;
alias zip_file_attributes_t = zip_file_attributes;
alias zip_source_t = zip_source;
alias zip_buffer_fragment_t = zip_buffer_fragment;

alias zip_flags_t = uint;

alias zip_source_callback = long function(void*, void*, ulong, zip_source_cmd_t);
alias zip_progress_callback = void function(zip_t*, double, void*);
alias zip_cancel_callback = int function(zip_t*, void*);

// Disabis deprecated functions. Currently they are just commented. Possibly it have sense to use custom configuration version here
// version(_ZIP_COMPILING_DEPRECATED) {
// #ifndef ZIP_DISABLE_DEPRECATED
// typedef void (*zip_progress_callback_t)(double);
// ZIP_EXTERN void zip_register_progress_callback(zip_t *_Nonnull, zip_progress_callback_t _Nullable); /* use zip_register_progress_callback_with_state */

// ZIP_EXTERN zip_int64_t zip_add(zip_t *_Nonnull, const char *_Nonnull, zip_source_t *_Nonnull);             /* use zip_file_add */
// ZIP_EXTERN zip_int64_t zip_add_dir(zip_t *_Nonnull, const char *_Nonnull);                                 /* use zip_dir_add */
// ZIP_EXTERN const char *_Nullable zip_get_file_comment(zip_t *_Nonnull, zip_uint64_t, int *_Nullable, int); /* use zip_file_get_comment */
// ZIP_EXTERN int zip_get_num_files(zip_t *_Nonnull);                                                         /* use zip_get_num_entries instead */
// ZIP_EXTERN int zip_rename(zip_t *_Nonnull, zip_uint64_t, const char *_Nonnull);                            /* use zip_file_rename */
// ZIP_EXTERN int zip_replace(zip_t *_Nonnull, zip_uint64_t, zip_source_t *_Nonnull);                         /* use zip_file_replace */
// ZIP_EXTERN int zip_set_file_comment(zip_t *_Nonnull, zip_uint64_t, const char *_Nullable, int);            /* use zip_file_set_comment */
// ZIP_EXTERN int zip_error_get_sys_type(int);                                                                /* use zip_error_system_type */
// ZIP_EXTERN void zip_error_get(zip_t *_Nonnull, int *_Nullable, int *_Nullable);                            /* use zip_get_error, zip_error_code_zip / zip_error_code_system */
// ZIP_EXTERN int zip_error_to_str(char *_Nonnull, zip_uint64_t, int, int);                                   /* use zip_error_init_with_code / zip_error_strerror */
// ZIP_EXTERN void zip_file_error_get(zip_file_t *_Nonnull, int *_Nullable, int *_Nullable);                  /* use zip_file_get_error, zip_error_code_zip / zip_error_code_system */
// #endif
// }

int zip_close(zip_t *);
int zip_delete(zip_t *, ulong);
long zip_dir_add(zip_t *, const char *, zip_flags_t);
void zip_discard(zip_t *);

zip_error_t * zip_get_error(zip_t *);
void zip_error_clear(zip_t *);
int zip_error_code_zip(const zip_error_t *);
int zip_error_code_system(const zip_error_t *);
void zip_error_fini(zip_error_t *);
void zip_error_init(zip_error_t *);
void zip_error_init_with_code(zip_error_t *, int);
void zip_error_set(zip_error_t *, int, int);
const(char*) zip_error_strerror(zip_error_t *);
int zip_error_system_type(const zip_error_t *);
long zip_error_to_data(const zip_error_t *, void *, ulong);

int zip_fclose(zip_file_t *);
zip_t * zip_fdopen(int, int, int *);
long zip_file_add(zip_t *, const char *, zip_source_t *, zip_flags_t);
void zip_file_attributes_init(zip_file_attributes_t *);
void zip_file_error_clear(zip_file_t *);
int zip_file_extra_field_delete(zip_t *, ulong, ushort, zip_flags_t);
int zip_file_extra_field_delete_by_id(zip_t *, ulong, ushort, ushort, zip_flags_t);
int zip_file_extra_field_set(zip_t *, ulong, ushort, ushort, const ubyte *, ushort, zip_flags_t);
short zip_file_extra_fields_count(zip_t *, ulong, zip_flags_t);
short zip_file_extra_fields_count_by_id(zip_t *, ulong, ushort, zip_flags_t);
const(ubyte*) zip_file_extra_field_get(zip_t *, ulong, ushort, ushort *, ushort *, zip_flags_t);
const(ubyte*) zip_file_extra_field_get_by_id(zip_t *, ulong, ushort, ushort, ushort *, zip_flags_t);
const(char*) zip_file_get_comment(zip_t *, ulong, uint *, zip_flags_t);
zip_error_t * zip_file_get_error(zip_file_t *);
int zip_file_get_external_attributes(zip_t *, ulong, zip_flags_t, ubyte *, uint *);
int zip_file_is_seekable(zip_file_t *);
int zip_file_rename(zip_t *, ulong, const char *, zip_flags_t);
int zip_file_replace(zip_t *, ulong, zip_source_t *, zip_flags_t);
int zip_file_set_comment(zip_t *, ulong, const char *, ushort, zip_flags_t);
int zip_file_set_dostime(zip_t *, ulong, ushort, ushort, zip_flags_t);
int zip_file_set_encryption(zip_t *, ulong, ushort, const char *);
int zip_file_set_external_attributes(zip_t *, ulong, zip_flags_t, ubyte, uint);
int zip_file_set_mtime(zip_t *, ulong, time_t, zip_flags_t);
const (char*) zip_file_strerror(zip_file_t *);
zip_file_t * zip_fopen(zip_t *, const char *, zip_flags_t);
zip_file_t * zip_fopen_encrypted(zip_t *, const char *, zip_flags_t, const char *);
zip_file_t * zip_fopen_index(zip_t *, ulong, zip_flags_t);
zip_file_t * zip_fopen_index_encrypted(zip_t *, ulong, zip_flags_t, const char *);
long zip_fread(zip_file_t *, void *, ulong);
byte zip_fseek(zip_file_t *, long, int);
long zip_ftell(zip_file_t *);
const(char*) zip_get_archive_comment(zip_t *, int *, zip_flags_t);
int zip_get_archive_flag(zip_t *, zip_flags_t, zip_flags_t);
const (char*) zip_get_name(zip_t *, ulong, zip_flags_t);
long zip_get_num_entries(zip_t *, zip_flags_t);
const(char*) zip_libzip_version();
long zip_name_locate(zip_t *, const char *, zip_flags_t);
zip_t * zip_open(const char *, int, int *);
zip_t * zip_open_from_source(zip_source_t *, int, zip_error_t *);

int zip_register_progress_callback_with_state(zip_t *, double, zip_progress_callback , void function(void*), void *);
int zip_register_cancel_callback_with_state(zip_t *, zip_cancel_callback , void function(void*), void *);

int zip_set_archive_comment(zip_t *, const char *, ushort);
int zip_set_archive_flag(zip_t *, zip_flags_t, int);
int zip_set_default_password(zip_t *, const char *);
int zip_set_file_compression(zip_t *, ulong, int, uint);
int zip_source_begin_write(zip_source_t *);
int zip_source_begin_write_cloning(zip_source_t *, ulong);
zip_source_t * zip_source_buffer(zip_t *, const void *, ulong, int);
zip_source_t * zip_source_buffer_create(const void *, ulong, int, zip_error_t *);
zip_source_t * zip_source_buffer_fragment(zip_t *, const zip_buffer_fragment_t *, ulong, int);
zip_source_t * zip_source_buffer_fragment_create(const zip_buffer_fragment_t *, ulong, int, zip_error_t *);
int zip_source_close(zip_source_t *);
int zip_source_commit_write(zip_source_t *);
zip_error_t * zip_source_error(zip_source_t *);
zip_source_t * zip_source_file(zip_t *, const char *, ulong, long);
zip_source_t * zip_source_file_create(const char *, ulong, long, zip_error_t *);
zip_source_t * zip_source_filep(zip_t *, FILE *, ulong, long);
zip_source_t * zip_source_filep_create(FILE *, ulong, long, zip_error_t *);
void zip_source_free(zip_source_t *);
zip_source_t * zip_source_function(zip_t *, zip_source_callback , void *);
zip_source_t * zip_source_function_create(zip_source_callback , void *, zip_error_t *);
int zip_source_get_file_attributes(zip_source_t *, zip_file_attributes_t *);
int zip_source_is_deleted(zip_source_t *);
void zip_source_keep(zip_source_t *);
long zip_source_make_command_bitmap(zip_source_cmd_t, ...);
int zip_source_open(zip_source_t *);
long zip_source_read(zip_source_t *, void *, ulong);
void zip_source_rollback_write(zip_source_t *);
int zip_source_seek(zip_source_t *, long, int);
long zip_source_seek_compute_offset(ulong, ulong, void *, ulong, zip_error_t *);
int zip_source_seek_write(zip_source_t *, long, int);
int zip_source_stat(zip_source_t *, zip_stat_t *);
long zip_source_tell(zip_source_t *);
long zip_source_tell_write(zip_source_t *);
version(Windows){
zip_source_t *zip_source_win32a(zip_t *, const char *, ulong, long);
zip_source_t *zip_source_win32a_create(const char *, ulong, long, zip_error_t *);
zip_source_t *zip_source_win32handle(zip_t *, void *, ulong, long);
zip_source_t *zip_source_win32handle_create(void *, ulong, long, zip_error_t *);
zip_source_t *zip_source_win32w(zip_t *, const wchar_t *, ulong, long);
zip_source_t *zip_source_win32w_create(const wchar_t *, ulong, long, zip_error_t *);
}
zip_source_t * zip_source_window_create(zip_source_t *, ulong, long, zip_error_t *);
long zip_source_write(zip_source_t *, const void *, ulong);
zip_source_t * zip_source_zip(zip_t *, zip_t *, ulong, zip_flags_t, ulong, long);
zip_source_t * zip_source_zip_create(zip_t *, ulong, zip_flags_t, ulong, long, zip_error_t *);
int zip_stat(zip_t *, const char *, zip_flags_t, zip_stat_t *);
int zip_stat_index(zip_t *, ulong, zip_flags_t, zip_stat_t *);
void zip_stat_init(zip_stat_t *);
const(char*) zip_strerror(zip_t *);
int zip_unchange(zip_t *, ulong);
int zip_unchange_all(zip_t *);
int zip_unchange_archive(zip_t *);
int zip_compression_method_supported(int method, int compress);
int zip_encryption_method_supported(ushort method, int encode);


