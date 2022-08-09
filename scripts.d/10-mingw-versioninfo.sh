#!/bin/bash

VERSIONINFO_OPATH_DIR="${FFBUILD_PREFIX}/lib/ffmpeg.versioninfo"
VERSIONINFO_OPATH="${VERSIONINFO_OPATH_DIR}/versioninfo.o"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir -p $VERSIONINFO_OPATH_DIR
    mkdir versioninfo-build && cd versioninfo-build

    VERSION_STRING="${ADDINS_STR:-git}"

    if [[ -n $ADDINS_STR ]]; then
      VERSION_MAJOR="$(cut -d. -f1 <<<"$ADDINS_STR")"
      VERSION_MINOR="$(cut -d. -f2 <<<"$ADDINS_STR")"
    fi
    VERSION_MAJOR="${VERSION_MAJOR:-0}"
    VERSION_MINOR="${VERSION_MINOR:-0}"

cat << EOF > ./ffmpeg-versioninfo.rc
#include <winres.h>

#define VER_FILEVERSION             ${VERSION_MAJOR},${VERSION_MINOR},0,0
#define VER_FILEVERSION_STR         "${VERSION_STRING}\0"

#define VER_PRODUCTVERSION          ${VERSION_MAJOR},${VERSION_MINOR},0,0
#define VER_PRODUCTVERSION_STR      "${VERSION_STRING}\0"

#ifndef DEBUG
#define VER_DEBUG                   0
#else
#define VER_DEBUG                   VS_FF_DEBUG
#endif

VS_VERSION_INFO VERSIONINFO
FILEVERSION     VER_FILEVERSION
PRODUCTVERSION  VER_PRODUCTVERSION
FILEFLAGSMASK   VS_FFI_FILEFLAGSMASK
FILEFLAGS       (VS_FF_PRIVATEBUILD|VER_DEBUG)
FILEOS          VOS__WINDOWS32
FILETYPE        VFT_APP
FILESUBTYPE     VFT2_UNKNOWN
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904E4"
        BEGIN
            VALUE "CompanyName",      "ShareX Team"
            VALUE "FileDescription",  "Very fast video and audio converter"
            VALUE "FileVersion",      VER_FILEVERSION_STR
            VALUE "InternalName",     "ffmpeg"
            VALUE "LegalCopyright",   "Copyright FFmpeg"
            VALUE "OriginalFilename", "ffmpeg.exe"
            VALUE "ProductName",      "FFmpeg"
            VALUE "ProductVersion",   VER_PRODUCTVERSION_STR
            VALUE "PrivateBuild",     "Built by L1Q for ShareX\0"

            // VALUE "LegalTrademarks1", VER_LEGALTRADEMARKS1_STR
            // VALUE "LegalTrademarks2", VER_LEGALTRADEMARKS2_STR
        END
    END

    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 1252
    END
END
EOF

    $RC_COMPILER ./ffmpeg-versioninfo.rc $VERSIONINFO_OPATH

    cd ..
    rm -rf ./versioninfo-build
}

ffbuild_libs() {
    echo $VERSIONINFO_OPATH
}
