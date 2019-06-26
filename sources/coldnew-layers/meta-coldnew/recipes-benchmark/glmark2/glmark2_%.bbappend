
PACKAGECONFIG_qemuall = "drm-gles2 ${@bb.utils.contains('DISTRO_FEATURES', 'wayland opengl', 'wayland-gles2', '', d)}"