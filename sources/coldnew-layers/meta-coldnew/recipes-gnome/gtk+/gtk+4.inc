SUMMARY = "Multi-platform toolkit for creating GUIs"
DESCRIPTION = "GTK+ is a multi-platform toolkit for creating graphical user interfaces. Offering a complete \
set of widgets, GTK+ is suitable for projects ranging from small one-off projects to complete application suites."
HOMEPAGE = "http://www.gtk.org"
BUGTRACKER = "https://bugzilla.gnome.org/"
SECTION = "libs"

DEPENDS = "glib-2.0 cairo pango atk jpeg libpng gdk-pixbuf \
           gdk-pixbuf-native graphene libepoxy sassc-native"

LICENSE = "LGPLv2 & LGPLv2+ & LGPLv2.1+"

inherit meson gettext pkgconfig update-alternatives gtk-immodules-cache gsettings features_check gobject-introspection

BBCLASSEXTEND = "native nativesdk"

GSETTINGS_PACKAGE_class-native = ""

# versions >= 3.90 are development versions, otherwise like upstream-version-is-even
UPSTREAM_CHECK_REGEX = "[^\d\.](?P<pver>3\.([1-8]?[02468])+(\.\d+)+)\.tar"

ANY_OF_DISTRO_FEATURES = "${GTK3DISTROFEATURES}"

# This should be in autotools.bbclass, but until something elses uses it putting
# it here avoids rebuilding everything.
export PKG_CONFIG_FOR_BUILD = "${STAGING_BINDIR_NATIVE}/pkg-config-native"

do_configure_prepend() {
    # Do this because the configure script is running ./libtool directly
    rm -f libtool
    ln -s ${TARGET_PREFIX}libtool libtool
    #delete a file that will get confused with generated one in ${B}
    rm -f ${S}/gtk/gtktypefuncs.c
}

EXTRA_OECONF += " \
                 --disable-glibtest \
                 --disable-xinerama \
                 --enable-modules \
                 --disable-colord \
                 ${@bb.utils.contains("DISTRO_FEATURES", "x11", "", "--disable-gtk-doc", d)} \
                 "

do_compile_prepend() {
        export GIR_EXTRA_LIBS_PATH="${B}/gdk/.libs"
}

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'wayland x11 vulkan', d)} \
                   cups gstreamer demos"

PACKAGECONFIG[x11] = "-Dx11-backend=true,-Dx11-backend=false,at-spi2-atk fontconfig libx11 libxext libxcursor libxi libxdamage libxrandr libxrender libxcomposite libxfixes"
PACKAGECONFIG[wayland] = "-Dwayland-backend=true,-Dwayland-backend=false,wayland wayland-protocols libxkbcommon virtual/egl virtual/libgles2 wayland-native"
PACKAGECONFIG[vulkan] = "-Dvulkan=yes,-Dvulkan=no,vulkan-loader"
PACKAGECONFIG[demos] = "-Ddemos=true,-Ddemos=false"
PACKAGECONFIG[cups] = "-Dprint-backends=cups,-Dprint-backends=none,cups"
PACKAGECONFIG[gstreamer] = "-Dmedia=gstreamer,-Dmedia=none,gstreamer1.0-plugins-bad"

prepare_gtk_scripts() {
    mv ${D}${bindir}/gtk4-update-icon-cache ${D}${bindir}/gtk-update-icon-cache-4.0

    # duplicate gtk-query-immodules for post install script update_gtk_immodules_cache
    #mkdir -p ${D}${libexecdir}
    #ln ${D}${bindir}/gtk-query-immodules-4.0 ${D}${libexecdir}/${MLPREFIX}gtk-query-immodules-4.0
}

do_install_append_class-target() {
    prepare_gtk_scripts
}

do_install_append_class-nativesdk() {
    prepare_gtk_scripts
}

do_install_append_class-native() {
        create_wrapper ${D}/${bindir}/gtk4-update-icon-cache \
                GDK_PIXBUF_MODULE_FILE=${STAGING_LIBDIR_NATIVE}/gdk-pixbuf-2.0/2.10.0/loaders.cache
        create_wrapper ${D}/${bindir}/gtk-encode-symbolic-svg \
                GDK_PIXBUF_MODULE_FILE=${STAGING_LIBDIR_NATIVE}/gdk-pixbuf-2.0/2.10.0/loaders.cache
}

PROVIDES += "gtk4-icon-utils"
PACKAGES =+ "${PN}-demo"
LIBV = "4.0.0"

FILES_${PN}-demo = "${bindir}/gtk4-demo \
                    ${bindir}/gtk4-demo-application \
                    ${bindir}/gtk4-icon-browser \
                    ${bindir}/gtk4-widget-factory \
                    ${datadir}/gtk-4.0/demo \
                    ${datadir}/applications/gtk4-demo.desktop \
                    ${datadir}/applications/gtk4-icon-browser.desktop \
                    ${datadir}/applications/gtk4-widget-factory.desktop \
                    ${datadir}/icons/hicolor/*/apps/*.svg \
                    ${datadir}/metainfo \
                    ${datadir}/gtk-4.0 \
"

FILES_${PN}_append = " ${bindir}/gtk-update-icon-cache-4.0 \
               ${bindir}/gtk-query-immodules-4.0 \
               ${bindir}/gtk-launch \
               ${datadir}/themes ${sysconfdir} ${datadir}/glib-2.0/schemas/ \
               ${libdir}/gtk-4.0/${LIBV}/engines/libpixmap.so \
               ${libdir}/gtk-4.0/modules/*.so \
               ${libdir}/gtk-4.0/${LIBV}/*/*.so \
"

FILES_${PN}-dev += " \
                    ${datadir}/gtk-4.0/gtkbuilder.rng \
                    ${datadir}/gtk-4.0/include \
                    ${datadir}/gettext/its \
                    ${libdir}/gtk-4.0/include \
                    ${libdir}/gtk-4.0/${LIBV}/loaders/*.la \
                    ${libdir}/gtk-4.0/${LIBV}/immodules/*.la \
                    ${libdir}/gtk-4.0/4.0.0/printbackends/*.la \
                    ${libdir}/gtk-4.0/${LIBV}/engines/*.la \
                    ${libdir}/gtk-4.0/modules/*.la \
                    ${bindir}/gtk-builder-convert \
                    ${bindir}/gtk-encode-symbolic-svg \
                    ${bindir}/gtk-builder-tool \
                    ${bindir}/gtk-query-settings \
                    "

GTKBASE_RRECOMMENDS ?= "liberation-fonts \
                        gdk-pixbuf-loader-png \
                        gdk-pixbuf-loader-jpeg \
                        gdk-pixbuf-loader-gif \
                        gdk-pixbuf-loader-xpm \
                        shared-mime-info \
                        adwaita-icon-theme-symbolic \
                        "

GTKBASE_RRECOMMENDS_class-native ?= "\
                        "

GTKGLIBC_RRECOMMENDS ?= "${GTKBASE_RRECOMMENDS} glibc-gconv-iso8859-1"

RRECOMMENDS_${PN} = "${GTKBASE_RRECOMMENDS}"
RRECOMMENDS_${PN}_libc-glibc = "${GTKGLIBC_RRECOMMENDS}"
RDEPENDS_${PN}-dev += "${@bb.utils.contains("PACKAGECONFIG", "wayland", "wayland-protocols", "", d)}"

PACKAGES_DYNAMIC += "^gtk4-immodule-.* ^gtk4-printbackend-.*"

ALTERNATIVE_${PN} = "gtk-update-icon-cache"
ALTERNATIVE_TARGET[gtk-update-icon-cache] = "${bindir}/gtk-update-icon-cache-4.0"
ALTERNATIVE_PRIORITY = "30"

python populate_packages_prepend () {
    import os.path

    gtk_libdir = d.expand('${libdir}/gtk-4.0/${LIBV}')
    immodules_root = os.path.join(gtk_libdir, 'immodules')
    printmodules_root = os.path.join(gtk_libdir, 'printbackends');

    immodules = do_split_packages(d, immodules_root, r'^im-(.*)\.so$', 'gtk4-immodule-%s', 'GTK input module for %s')
    if immodules:
        d.setVar("GTKIMMODULES_PACKAGES", " ".join(immodules))

    do_split_packages(d, printmodules_root, r'^libprintbackend-(.*)\.so$', 'gtk4-printbackend-%s', 'GTK printbackend module for %s')

    if (d.getVar('DEBIAN_NAMES')):
        d.setVar(d.expand('PKG_${PN}'), '${MLPREFIX}libgtk-3.0')
}
