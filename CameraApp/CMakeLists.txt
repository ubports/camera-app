# QML plugin

set(plugin_SRCS
    components.cpp
    )

set(plugin_HDRS
    components.h
    )

add_library(camera-qml SHARED ${plugin_SRCS} ${plugin_HDRS})

qt5_use_modules(camera-qml Qml Quick)

target_link_libraries(camera-qml
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    )

set(PLUGIN_DIR ${QT_IMPORTS_DIR}/CameraApp)
install(TARGETS camera-qml DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})

