/* This file is result of translation of zip.h file of libzip to D,
 * using BindBC to be able to load library dynamically.
 */
module zipper.lib.libzip;

// Added here to make available usage of FILE and time_t
public import core.stdc.time;
public import core.stdc.stdio;

private import bindbc.common.codegen: joinFnBinds, FnBind;

/* Notes

Following definitions relaced by standard D types.
Possibly it have sense to revert this change, and use aliases instead.
    ZIP_UINT16_MAX = ushort.max
    zip_int64_t = long
    zip_uint64_t = ulong
    zip_uint32_t = uint
    zip_uint16_t = ushort
    zip_uint8_t = ubyte
*/

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

extern (C):
nothrow:

enum staticBinding = (){
	version(BindBC_Static)      return true;
	else version(ZipperStatic) return true;
	else return false;
}();


mixin(joinFnBinds!staticBinding((){
    FnBind[] ret = [
        /// test
        {q{int}, q{zip_close}, q{zip_t *}},
        {q{int}, q{zip_delete}, q{zip_t *, ulong}},
        {q{long}, q{zip_dir_add}, q{zip_t *, const char *, zip_flags_t}},
        {q{void}, q{zip_discard}, q{zip_t *}},

        {q{zip_error_t*}, q{zip_get_error}, q{zip_t *}},
        {q{void}, q{zip_error_clear}, q{zip_t *}},
        {q{int}, q{zip_error_code_zip}, q{const zip_error_t *}},
        {q{int}, q{zip_error_code_system}, q{const zip_error_t *}},
        {q{void}, q{zip_error_fini}, q{zip_error_t *}},
        {q{void}, q{zip_error_init}, q{zip_error_t *}},
        {q{void}, q{zip_error_init_with_code}, q{zip_error_t *, int}},
        {q{void}, q{zip_error_set}, q{zip_error_t *, int, int}},
        {q{const(char*)}, q{zip_error_strerror}, q{zip_error_t *}},
        {q{int}, q{zip_error_system_type}, q{const zip_error_t *}},
        {q{long}, q{zip_error_to_data}, q{const zip_error_t *, void *, ulong}},

        {q{int}, q{zip_fclose}, q{zip_file_t *}},
        {q{zip_t*}, q{zip_fdopen}, q{int, int, int *}},
        {q{long}, q{zip_file_add}, q{zip_t *, const char *, zip_source_t *, zip_flags_t}},
        {q{void}, q{zip_file_attributes_init}, q{zip_file_attributes_t *}},
        {q{void}, q{zip_file_error_clear}, q{zip_file_t *}},
        {q{int}, q{zip_file_extra_field_delete}, q{zip_t *, ulong, ushort, zip_flags_t}},
        {q{int}, q{zip_file_extra_field_delete_by_id}, q{zip_t *, ulong, ushort, ushort, zip_flags_t}},
        {q{int}, q{zip_file_extra_field_set}, q{zip_t *, ulong, ushort, ushort, const ubyte *, ushort, zip_flags_t}},
        {q{short}, q{zip_file_extra_fields_count}, q{zip_t *, ulong, zip_flags_t}},
        {q{short}, q{zip_file_extra_fields_count_by_id}, q{zip_t *, ulong, ushort, zip_flags_t}},
        {q{const(ubyte*)}, q{zip_file_extra_field_get}, q{zip_t *, ulong, ushort, ushort *, ushort *, zip_flags_t}},
        {q{const(ubyte*)}, q{zip_file_extra_field_get_by_id}, q{zip_t *, ulong, ushort, ushort, ushort *, zip_flags_t}},
        {q{const(char*)}, q{zip_file_get_comment}, q{zip_t *, ulong, uint *, zip_flags_t}},
        {q{zip_error_t*}, q{zip_file_get_error}, q{zip_file_t *}},
        {q{int}, q{zip_file_get_external_attributes}, q{zip_t *, ulong, zip_flags_t, ubyte *, uint *}},
        {q{int}, q{zip_file_is_seekable}, q{zip_file_t *}},
        {q{int}, q{zip_file_rename}, q{zip_t *, ulong, const char *, zip_flags_t}},
        {q{int}, q{zip_file_replace}, q{zip_t *, ulong, zip_source_t *, zip_flags_t}},
        {q{int}, q{zip_file_set_comment}, q{zip_t *, ulong, const char *, ushort, zip_flags_t}},
        {q{int}, q{zip_file_set_dostime}, q{zip_t *, ulong, ushort, ushort, zip_flags_t}},
        {q{int}, q{zip_file_set_encryption}, q{zip_t *, ulong, ushort, const char *}},
        {q{int}, q{zip_file_set_external_attributes}, q{zip_t *, ulong, zip_flags_t, ubyte, uint}},
        {q{int}, q{zip_file_set_mtime}, q{zip_t *, ulong, time_t, zip_flags_t}},
        {q{const (char*)}, q{zip_file_strerror}, q{zip_file_t *}},
        {q{zip_file_t*}, q{zip_fopen}, q{zip_t *, const char *, zip_flags_t}},
        {q{zip_file_t*}, q{zip_fopen_encrypted}, q{zip_t *, const char *, zip_flags_t, const char *}},
        {q{zip_file_t*}, q{zip_fopen_index}, q{zip_t *, ulong, zip_flags_t}},
        {q{zip_file_t*}, q{zip_fopen_index_encrypted}, q{zip_t *, ulong, zip_flags_t, const char *}},
        {q{long}, q{zip_fread}, q{zip_file_t *, void *, ulong}},
        {q{byte}, q{zip_fseek}, q{zip_file_t *, long, int}},
        {q{long}, q{zip_ftell}, q{zip_file_t *}},
        {q{const(char*)}, q{zip_get_archive_comment}, q{zip_t *, int *, zip_flags_t}},
        {q{int}, q{zip_get_archive_flag}, q{zip_t *, zip_flags_t, zip_flags_t}},
        {q{const (char*)}, q{zip_get_name}, q{zip_t *, ulong, zip_flags_t}},
        {q{long}, q{zip_get_num_entries}, q{zip_t *, zip_flags_t}},
        {q{const(char*)}, q{zip_libzip_version}},
        {q{long}, q{zip_name_locate}, q{zip_t *, const char *, zip_flags_t}},
        {q{zip_t*}, q{zip_open}, q{const char *, int, int *}},
        {q{zip_t*}, q{zip_open_from_source}, q{zip_source_t *, int, zip_error_t *}},

        {q{int}, q{zip_register_progress_callback_with_state}, q{zip_t *, double, zip_progress_callback , void function(void*), void *}},
        {q{int}, q{zip_register_cancel_callback_with_state}, q{zip_t *, zip_cancel_callback , void function(void*), void *}},

        {q{int}, q{zip_set_archive_comment}, q{zip_t *, const char *, ushort}},
        {q{int}, q{zip_set_archive_flag}, q{zip_t *, zip_flags_t, int}},
        {q{int}, q{zip_set_default_password}, q{zip_t *, const char *}},
        {q{int}, q{zip_set_file_compression}, q{zip_t *, ulong, int, uint}},
        {q{int}, q{zip_source_begin_write}, q{zip_source_t *}},
        {q{int}, q{zip_source_begin_write_cloning}, q{zip_source_t *, ulong}},
        {q{zip_source_t*}, q{zip_source_buffer}, q{zip_t *, const void *, ulong, int}},
        {q{zip_source_t*}, q{zip_source_buffer_create}, q{const void *, ulong, int, zip_error_t *}},
        {q{zip_source_t*}, q{zip_source_buffer_fragment}, q{zip_t *, const zip_buffer_fragment_t *, ulong, int}},
        {q{zip_source_t*}, q{zip_source_buffer_fragment_create}, q{const zip_buffer_fragment_t *, ulong, int, zip_error_t *}},
        {q{int}, q{zip_source_close}, q{zip_source_t *}},
        {q{int}, q{zip_source_commit_write}, q{zip_source_t *}},
        {q{zip_error_t*}, q{zip_source_error}, q{zip_source_t *}},
        {q{zip_source_t*}, q{zip_source_file}, q{zip_t *, const char *, ulong, long}},
        {q{zip_source_t*}, q{zip_source_file_create}, q{const char *, ulong, long, zip_error_t *}},
        {q{zip_source_t*}, q{zip_source_filep}, q{zip_t *, FILE *, ulong, long}},
        {q{zip_source_t*}, q{zip_source_filep_create}, q{FILE *, ulong, long, zip_error_t *}},
        {q{void}, q{zip_source_free}, q{zip_source_t *}},
        {q{zip_source_t*}, q{zip_source_function}, q{zip_t *, zip_source_callback , void *}},
        {q{zip_source_t*}, q{zip_source_function_create}, q{zip_source_callback , void *, zip_error_t *}},
        {q{int}, q{zip_source_get_file_attributes}, q{zip_source_t *, zip_file_attributes_t *}},
        {q{int}, q{zip_source_is_deleted}, q{zip_source_t *}},
        {q{void}, q{zip_source_keep}, q{zip_source_t *}},
        //{q{long}, q{zip_source_make_command_bitmap}, q{zip_source_cmd_t, ...}},
        {q{int}, q{zip_source_open}, q{zip_source_t *}},
        {q{long}, q{zip_source_read}, q{zip_source_t *, void *, ulong}},
        {q{void}, q{zip_source_rollback_write}, q{zip_source_t *}},
        {q{int}, q{zip_source_seek}, q{zip_source_t *, long, int}},
        {q{long}, q{zip_source_seek_compute_offset}, q{ulong, ulong, void *, ulong, zip_error_t *}},
        {q{int}, q{zip_source_seek_write}, q{zip_source_t *, long, int}},
        {q{int}, q{zip_source_stat}, q{zip_source_t *, zip_stat_t *}},
        {q{long}, q{zip_source_tell}, q{zip_source_t *}},
        {q{long}, q{zip_source_tell_write}, q{zip_source_t *}},

        {q{zip_source_t*}, q{zip_source_window_create}, q{zip_source_t *, ulong, long, zip_error_t *}},
        {q{long}, q{zip_source_write}, q{zip_source_t *, const void *, ulong}},
        {q{zip_source_t*}, q{zip_source_zip}, q{zip_t *, zip_t *, ulong, zip_flags_t, ulong, long}},
        {q{zip_source_t*}, q{zip_source_zip_create}, q{zip_t *, ulong, zip_flags_t, ulong, long, zip_error_t *}},
        {q{int}, q{zip_stat}, q{zip_t *, const char *, zip_flags_t, zip_stat_t *}},
        {q{int}, q{zip_stat_index}, q{zip_t *, ulong, zip_flags_t, zip_stat_t *}},
        {q{void}, q{zip_stat_init}, q{zip_stat_t *}},
        {q{const(char*)}, q{zip_strerror}, q{zip_t *}},
        {q{int}, q{zip_unchange}, q{zip_t *, ulong}},
        {q{int}, q{zip_unchange_all}, q{zip_t *}},
        {q{int}, q{zip_unchange_archive}, q{zip_t *}},
        {q{int}, q{zip_compression_method_supported}, q{int method, int compress}},
        {q{int}, q{zip_encryption_method_supported}, q{ushort method, int encode}},
    ];

    version(Windows){
        FnBind[] win_fn = [
            {q{zip_source_t*}, q{zip_source_win32a}, q{zip_t *, const char *, ulong, long}},
            {q{zip_source_t*}, q{zip_source_win32a_create}, q{const char *, ulong, long, zip_error_t *}},
            {q{zip_source_t*}, q{zip_source_win32handle}, q{zip_t *, void *, ulong, long}},
            {q{zip_source_t*}, q{zip_source_win32handle_create}, q{void *, ulong, long, zip_error_t *}},
            {q{zip_source_t*}, q{zip_source_win32w}, q{zip_t *, const wchar_t *, ulong, long}},
            {q{zip_source_t*}, q{zip_source_win32w_create}, q{const wchar_t *, ulong, long, zip_error_t *}},
        ];
        ret ~= win_fn;
    }
    return ret;
}()));
