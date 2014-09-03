# QML plugin

set(plugin_SRCS
    components.cpp
    advancedcamerasettings.cpp
    fileoperations.cpp
    foldersmodel.cpp
    )

set(plugin_HDRS
    components.h
    advancedcamerasettings.h
    fileoperations.h
    foldersmodel.h
    )

add_library(camera-qml SHARED ${plugin_SRCS} ${plugin_HDRS})

target_link_libraries(camera-qml
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${Qt5Multimedia_LIBRARIES}
    )

install(TARGETS camera-qml DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})

