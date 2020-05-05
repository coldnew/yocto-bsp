DESCRIPTION = "A thin layer of types for graphic libraries"
HOMEPAGE = "https://github.com/ebassi/graphene"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=a7d871d9e23c450c421a85bb2819f648"

inherit meson pkgconfig gobject-introspection

SRC_URI = "https://github.com/ebassi/graphene/releases/download/1.10.0/${BPN}-${PV}.tar.xz"
SRC_URI[sha256sum] = "406d97f51dd4ca61e91f84666a00c3e976d3e667cd248b76d92fdb35ce876499"


EXTRA_OEMESON += "-Dgtk_doc=false -Dgobject_types=true -Dintrospection=true -Dgcc_vector=true -Dinstalled_tests=false -Dtests=false"

# FIXME: add sse2 support here
EXTRA_OEMESON_append_class-target = " ${@bb.utils.contains("TUNE_FEATURES", "neon", "-Darm_neon=true", "-Darm_neon=false" ,d)}"

#$(meson_use cpu_flags_x86_sse2 sse2)
#$(meson_use cpu_flags_arm_neon arm_neon)

FILES_${PN}-dev += "${libdir}/graphene-1.0/include"