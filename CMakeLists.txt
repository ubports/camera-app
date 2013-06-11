project(camera-app)
cmake_minimum_required(VERSION 2.8.9)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

find_package(Qt5Qml)
find_package(Qt5Quick)
find_package(Qt5Multimedia)

# Standard install paths
include(GNUInstallDirs)

set(CAMERA_APP_DIR ${CMAKE_INSTALL_DATADIR}/camera-app)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Multimedia_INCLUDE_DIRS}
    )

set(CAMERA_APP camera-app)

set(camera_app_HDRS
    cameraapplication.h)

set(camera_app_SRCS
    cameraapplication.cpp
    main.cpp)

add_executable(${CAMERA_APP}
    ${cameraapplication_MOC_SRCS}
    ${camera_app_SRCS}
    )

target_link_libraries(${CAMERA_APP}
    ${Qt5Core_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${Qt5Multimedia_LIBRARIES}
    )

install(TARGETS ${CAMERA_APP}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

file(GLOB QML_JS_FILES *.qml *.js)

install(FILES ${QML_JS_FILES}
    DESTINATION ${CAMERA_APP_DIR}
    )

set(ASSETS_DIR assets)

install(DIRECTORY ${ASSETS_DIR}
    DESTINATION ${CAMERA_APP_DIR}
    )

set(THEME_DIR theme)

install(DIRECTORY ${THEME_DIR}
    DESTINATION ${CAMERA_APP_DIR}
    )

install(FILES ${CAMERA_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )

add_subdirectory(CameraApp)
add_subdirectory(po)

enable_testing()
add_subdirectory(tests)
