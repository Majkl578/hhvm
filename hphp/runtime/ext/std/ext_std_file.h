/*
   +----------------------------------------------------------------------+
   | HipHop for PHP                                                       |
   +----------------------------------------------------------------------+
   | Copyright (c) 2010-2014 Facebook, Inc. (http://www.facebook.com)     |
   | Copyright (c) 1997-2010 The PHP Group                                |
   +----------------------------------------------------------------------+
   | This source file is subject to version 3.01 of the PHP license,      |
   | that is bundled with this package in the file LICENSE, and is        |
   | available through the world-wide-web at the following url:           |
   | http://www.php.net/license/3_01.txt                                  |
   | If you did not receive a copy of the PHP license and are unable to   |
   | obtain it through the world-wide-web, please send a note to          |
   | license@php.net so we can mail you a copy immediately.               |
   +----------------------------------------------------------------------+
*/

#ifndef incl_HPHP_EXT_STD_FILE_H_
#define incl_HPHP_EXT_STD_FILE_H_

#include "hphp/runtime/base/base-includes.h"
#include "hphp/runtime/ext/std/ext_std.h"

namespace HPHP {
///////////////////////////////////////////////////////////////////////////////
// constants

#define k_STDIN (BuiltinFiles::GetSTDIN())
#define k_STDOUT (BuiltinFiles::GetSTDOUT())
#define k_STDERR (BuiltinFiles::GetSTDERR())
extern const int64_t k_STREAM_URL_STAT_LINK;
extern const int64_t k_STREAM_URL_STAT_QUIET;
extern const int64_t k_SEEK_SET;
extern const int64_t k_INI_SCANNER_NORMAL;

///////////////////////////////////////////////////////////////////////////////
// file handle based file operations

Variant HHVM_FUNCTION(fopen, 
  const String& filename, const String& mode, bool use_include_path = false,
  const Variant& context = uninit_null());
bool HHVM_FUNCTION(fclose, const Resource& handle);
Variant HHVM_FUNCTION(fseek, const Resource& handle, int64_t offset, int64_t whence = k_SEEK_SET);
bool HHVM_FUNCTION(rewind, const Resource& handle);
Variant HHVM_FUNCTION(ftell, const Resource& handle);
bool HHVM_FUNCTION(feof, const Resource& handle);
Variant HHVM_FUNCTION(fstat, const Resource& handle);
Variant HHVM_FUNCTION(fread, const Resource& handle, int64_t length);
Variant HHVM_FUNCTION(fgetc, const Resource& handle);
Variant HHVM_FUNCTION(fgets, const Resource& handle, int64_t length = 0);
Variant HHVM_FUNCTION(fgetss, const Resource& handle, int64_t length = 0,
                      const String& allowable_tags = null_string);
Variant HHVM_FUNCTION(fpassthru, const Resource& handle);
Variant HHVM_FUNCTION(fwrite, const Resource& handle, const String& data, int64_t length = 0);

///////////////////////////////////////////////////////////////////////////////
// file name based file operations

Variant HHVM_FUNCTION(file_get_contents,
                      const String& filename, bool use_include_path = false,
                      const Variant& context = uninit_null(),
                      int64_t offset = -1, int64_t maxlen = -1);
Variant HHVM_FUNCTION(file,
                      const String& filename, int flags = 0, const Variant& context = uninit_null());
Variant HHVM_FUNCTION(readfile, const String& filename, bool use_include_path = false,
                      const Variant& context = uninit_null());
Variant HHVM_FUNCTION(parse_ini_file, const String& filename, bool process_sections = false,
                      int scanner_mode = k_INI_SCANNER_NORMAL);

///////////////////////////////////////////////////////////////////////////////
// shell commands

bool HHVM_FUNCTION(copy, const String& source, const String& dest,
                   const Variant& context = uninit_null());
bool HHVM_FUNCTION(rename, const String& oldname, const String& newname,
                   const Variant& context = uninit_null());
bool HHVM_FUNCTION(unlink, const String& filename, const Variant& context = uninit_null());
String HHVM_FUNCTION(basename, const String& path, const String& suffix = null_string);
Variant HHVM_FUNCTION(glob, const String& pattern, int flags = 0);

///////////////////////////////////////////////////////////////////////////////
// stats functions

bool HHVM_FUNCTION(is_writable, const String& filename);
bool HHVM_FUNCTION(is_writeable, const String& filename);
bool HHVM_FUNCTION(is_readable, const String& filename);
bool HHVM_FUNCTION(is_file, const String& filename);
bool HHVM_FUNCTION(is_dir, const String& filename);
bool HHVM_FUNCTION(file_exists, const String& filename);
Variant HHVM_FUNCTION(readlink_internal, const String& path, bool warning_compliance);
Variant HHVM_FUNCTION(readlink, const String& path);
Variant HHVM_FUNCTION(realpath, const String& path);
Variant HHVM_FUNCTION(pathinfo, const String& path, int opt = 15);

///////////////////////////////////////////////////////////////////////////////
// directory functions

bool HHVM_FUNCTION(mkdir, const String& pathname, int64_t mode = 0777,
                   bool recursive = false, const Variant& context = uninit_null());
String HHVM_FUNCTION(dirname, const String& path);
Variant HHVM_FUNCTION(getcwd);
Variant HHVM_FUNCTION(opendir, const String& path, const Variant& context = uninit_null());
Variant HHVM_FUNCTION(readdir, const Resource& dir_handle = null_resource);
Variant HHVM_FUNCTION(scandir, const String& directory, bool descending = false,
                      const Variant& context = uninit_null());
void HHVM_FUNCTION(closedir, const Resource& dir_handle = null_resource);

///////////////////////////////////////////////////////////////////////////////
}

#endif // incl_HPHP_EXT_STD_FILE_H_
