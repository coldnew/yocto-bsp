# Copyright (C) 2019 coldnew - Yen-Chin, Lee

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#### QEMU

PACKAGECONFIG_GL_qemuall = "gles2 kms eglfs"
PACKAGECONFIG_append_qemuall = " libinput accessibility glib freetype fontconfig widgets "

# Disable build with sse3
QT_CONFIG_FLAGS_append_qemuall = " -no-sse3 "

## Qt5.6.3's openssl can't support openssl-1.1.x
PACKAGECONFIG_remove += " openssl "
