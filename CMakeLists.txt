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
find_package(Qt5Gui)

# Standard install paths
include(GNUInstallDirs)

option(INSTALL_TESTS "Install the tests on make install" on)
option(CLICK_MODE "Installs to a contained location" off)

set(CAMERA_APP camera-app)
set(AUTOPILOT_DIR camera_app)

if(CLICK_MODE)
    if(NOT DEFINED BZR_SOURCE)
        set(BZR_SOURCE "lp:camera-app")
    endif(NOT DEFINED BZR_SOURCE)
    set(CMAKE_INSTALL_PREFIX /)
    set(CAMERA_APP_DIR /)
    set(CMAKE_INSTALL_BINDIR /)
    set(PLUGIN_BASE lib/${CMAKE_LIBRARY_ARCHITECTURE})
    set(PLUGIN_DIR ${PLUGIN_BASE}/CameraApp)
    set(DESKTOP_EXEC "./${CAMERA_APP}")
	set(CAMERA_ICON "${CMAKE_INSTALL_DATADIR}/icons/camera-app.svg")
	install(FILES camera-app.svg DESTINATION ${CMAKE_INSTALL_DATADIR}/icons)
    add_definitions("-DCLICK_MODE=1")
else(CLICK_MODE)
	set(CAMERA_ICON "camera-app")
    set(CAMERA_APP_DIR ${CMAKE_INSTALL_DATADIR}/${CAMERA_APP})
    set(DESKTOP_EXEC ${CAMERA_APP})
endif(CLICK_MODE)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h @ONLY)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
    ${Qt5Multimedia_INCLUDE_DIRS}
    ${Qt5Gui_INCLUDE_DIRS}
    )

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
    ${Qt5Gui_LIBRARIES}
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

install(DIRECTORY ${THEME_DIR}
    DESTINATION ${CAMERA_APP_DIR}
    )

set(DESKTOP_FILE camera-app.desktop)
file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE})
file(STRINGS ${DESKTOP_FILE}.in DESKTOP_FILE_CONTENTS)
foreach(LINE ${DESKTOP_FILE_CONTENTS})
    string(REGEX REPLACE "tr\\\(\"(.*)\"\\\)" "\\1" LINE "${LINE}")
    string(CONFIGURE "${LINE}" LINE)
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE} "${LINE}\n")
endforeach(LINE)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )

add_subdirectory(CameraApp)
add_subdirectory(click)
add_subdirectory(desktop)

file(GLOB_RECURSE I18N_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     **.qml **.desktop.in)
list(SORT I18N_SRC_FILES)

# for dh_translations to extract the domain
# (regarding syntax consistency, see http://pad.lv/1181187)
set (GETTEXT_PACKAGE "camera-app")

add_subdirectory(po)

enable_testing()
add_subdirectory(tests)
