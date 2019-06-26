
# In my setup, our qemu use virglrender to create opengl render
# so we need to use drm-backend to make weston launch
do_install_append_qemuall() {
        mkdir -p ${D}/${sysconfdir}/xdg/weston
        cat << EOF > ${D}/${sysconfdir}/xdg/weston/weston.ini
[core]
backend=drm-backend.so
EOF
}
