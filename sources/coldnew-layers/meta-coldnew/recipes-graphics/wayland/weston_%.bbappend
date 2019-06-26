FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

PACKAGECONFIG_qemuall = "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'kms wayland egl', '', d)} \
                         ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)} \
                         ${@bb.utils.filter('DISTRO_FEATURES', 'pam systemd x11', d)} \
                         clients launch"
