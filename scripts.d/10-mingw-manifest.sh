#!/bin/bash

MANIFEST_OPATH_DIR="${FFBUILD_PREFIX}/lib/ffmpeg.exe.manifest"
MANIFEST_OPATH="${MANIFEST_OPATH_DIR}/manifest.o"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir -p $MANIFEST_OPATH_DIR
    mkdir manifest-build && cd manifest-build

cat <<EOF >"./ffmpeg.exe.manifest.rc"
1 24 "ffmpeg.exe.manifest"
EOF

cat <<EOF >"./ffmpeg.exe.manifest"
<?xml version="1.0" encoding="utf-8"?>
<assembly manifestVersion="1.0" xmlns="urn:schemas-microsoft-com:asm.v1">
  <assemblyIdentity version="5.1.0.0" name="FFmpeg"/>
  <application xmlns="urn:schemas-microsoft-com:asm.v3">
    <windowsSettings>
      <dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">true</dpiAware>
    </windowsSettings>
  </application>
</assembly>
EOF

    $RC_COMPILER ./ffmpeg.exe.manifest.rc $MANIFEST_OPATH

    cd ..
    rm -rf ./manifest-build
}

ffbuild_libs() {
    echo $MANIFEST_OPATH
}
