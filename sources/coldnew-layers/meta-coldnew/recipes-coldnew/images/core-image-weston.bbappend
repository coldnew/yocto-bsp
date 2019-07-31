FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

IMAGE_INSTALL_append += " glmark2 "

IMAGE_INSTALL_append += " networkmanager "

IMAGE_INSTALL_append += " kmscube "

# Qt5
# TODO: use features to select these packages
IMAGE_INSTALL_append += " \
    qtbase \
    qtbase-plugins \
    qtdeclarative  \
    qtdeclarative-tools  \
    qtdeclarative-qmlplugins  \
    qtimageformats  \
    qtgraphicaleffects-qmlplugins \
    qtsvg \
    qtxmlpatterns \
    qtmultimedia \
    qtmultimedia-plugins \
    qtmultimedia-qmlplugins \
    qtquickcontrols-qmlplugins \
    qtwayland \
    qtwayland-qmlplugins \
"
