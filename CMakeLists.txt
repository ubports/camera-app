project(camera-app)
cmake_minimum_required(VERSION 2.8)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# Standard install paths
include(GNUInstallDirs)

set(CAMERA_APP_DIR ${CMAKE_INSTALL_DATADIR}/camera-app)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)

find_package(Qt4 REQUIRED)
find_package(PkgConfig REQUIRED)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${QT_INCLUDE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    )

set(CAMERA_APP camera-app)

set(camera_app_HDRS
    cameraapplication.h)

set(camera_app_SRCS
    cameraapplication.cpp
    main.cpp)

qt4_wrap_cpp(cameraapplication_MOC_SRCS ${camera_app_HDRS})
add_executable(${CAMERA_APP}
    ${cameraapplication_MOC_SRCS}
    ${camera_app_SRCS}
    )

target_link_libraries(${CAMERA_APP}
    ${QT_QTCORE_LIBRARIES}
    ${QT_QTGUI_LIBRARIES}
    ${QT_QTNETWORK_LIBRARIES}
    ${QT_QTDECLARATIVE_LIBRARIES}
    )

install(TARGETS ${CAMERA_APP}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

file(GLOB QML_JS_FILES *.qml *.js)

install(FILES ${QML_JS_FILES}
    DESTINATION ${CAMERA_APP_DIR}
    )

set(ASSETS_DIR assets)

install(DIRECTORY ${ASSETS_DIR}
    DESTINATION ${CAMERA_APP_DIR}
    )

set(DUMMYDATA_DIR dummydata)

install(DIRECTORY ${DUMMYDATA_DIR}
    DESTINATION ${CAMERA_APP_DIR}
    )

install(FILES ${CAMERA_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )

add_subdirectory(CameraApp)
