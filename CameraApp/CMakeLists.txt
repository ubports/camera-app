# QML plugin

set(plugin_SRCS
    components.cpp
    )

set(plugin_HDRS
    components.h
    )

qt4_wrap_cpp(plugin_MOC_SRCS ${plugin_HDRS})

include_directories(
    ${QT_QTCORE_INCLUDE_DIR}
    ${QT_QTGUI_INCLUDE_DIR}
    ${QT_QTDECLARATIVE_INCLUDE_DIR}
    )

add_library(camera-qml SHARED ${plugin_SRCS} ${plugin_HDRS} ${plugin_MOC_SRCS})

target_link_libraries(camera-qml
    ${QT_QTCORE_LIBRARIES}
    ${QT_QTDECLARATIVE_LIBRARIES}
    )

set(PLUGIN_DIR ${QT_IMPORTS_DIR}/CameraApp)
install(TARGETS camera-qml DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})

