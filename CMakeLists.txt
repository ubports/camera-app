project(camera-app)
cmake_minimum_required(VERSION 2.8.9)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

# Standard install paths. Needs to be set before finding packages.
include(GNUInstallDirs)

find_package(Qt5Qml)
find_package(Qt5Quick)
find_package(Qt5Multimedia)
find_package(Qt5Gui)

find_program(INTLTOOL_MERGE intltool-merge)
find_program(INTLTOOL_EXTRACT intltool-extract)

option(INSTALL_TESTS "Install the tests on make install" off)
option(CLICK_MODE "Installs to a contained location" on)

set(CAMERA_APP camera-app)
set(AUTOPILOT_DIR camera_app)
set(DESKTOP_FILE camera-app.desktop)
set(UBUNTU_MANIFEST_PATH "manifest.json.in" CACHE INTERNAL "Tells QtCreator location and name of the manifest file")

if(CLICK_MODE)

    set(CMAKE_INSTALL_PREFIX /)
    set(CAMERA_APP_DIR /)
    set(CMAKE_INSTALL_BINDIR /)
    set(PLUGIN_BASE lib/${CMAKE_LIBRARY_ARCHITECTURE})
    set(PLUGIN_DIR ${PLUGIN_BASE}/CameraApp)
    set(DESKTOP_EXEC "./${CAMERA_APP}")
  	set(CAMERA_ICON "${CMAKE_INSTALL_DATADIR}/icons/camera-app.png")
  	install(FILES camera-app.png DESTINATION ${CMAKE_INSTALL_DATADIR}/icons)
    add_definitions("-DCLICK_MODE=1")

	# Case of git source control
    if(NOT REVNO)
      execute_process(
            COMMAND git rev-list --count --first-parent HEAD
            OUTPUT_VARIABLE REVNO
            RESULT_VARIABLE res
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        message("-- Setting REVNO to ${REVNO} with result of : ${res}")
    endif(NOT REVNO)
    if(NOT SOURCE)
        execute_process(
            COMMAND git remote -v
            COMMAND grep origin
            COMMAND grep push
            COMMAND awk "{print $2}"
            OUTPUT_VARIABLE SOURCE
            RESULT_VARIABLE res
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
      message("-- Setting SOURCE to ${SOURCE} with result of : ${res}")
    endif(NOT SOURCE)
   # Case of bzr source control
    if(NOT REVNO)
    execute_process(
      COMMAND bzr revno
              OUTPUT_VARIABLE REVNO
              WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
              OUTPUT_STRIP_TRAILING_WHITESPACE
      )
        message("-- Setting REVNO to ${REVNO}")
    endif(NOT REVNO)
    if(NOT SOURCE)
        set(SOURCE lp:${APP_HARDCODE})
        message("-- Setting SOURCE to ${SOURCE}")
    endif(NOT SOURCE)

else(CLICK_MODE)
    set(CAMERA_APP_DIR ${CMAKE_INSTALL_DATADIR}/${CAMERA_APP})
    set(CAMERA_ICON ${CMAKE_INSTALL_PREFIX}/${CAMERA_APP_DIR}/camera-app.png)
    set(PLUGIN_BASE ${CMAKE_INSTALL_LIBDIR}/${CAMERA_APP})
    set(PLUGIN_DIR ${PLUGIN_BASE}/CameraApp)
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
    stdc++
    )

install(TARGETS ${CAMERA_APP}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -std=c++11")

file(GLOB QML_JS_FILES *.qml *.js *.png)

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

configure_file(${DESKTOP_FILE}.in.in ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}.in)
add_custom_target(${DESKTOP_FILE} ALL
         COMMENT "Merging translations into ${DESKTOP_FILE}"
         COMMAND ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE}
        )

# make non compiled files visible in qtcreator
file(GLOB_RECURSE NON_COMPILED_FILES *.qml *.js *.py *.svg *.png *.in *.json *.desktop *.pot *.apparmor qmldir)
add_custom_target(NON_COMPILED_TARGET ALL SOURCES ${NON_COMPILED_FILES})

if(CLICK_MODE)

    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
        DESTINATION ${CMAKE_INSTALL_PREFIX})

    execute_process(
      COMMAND dpkg-architecture -qDEB_HOST_ARCH
      OUTPUT_VARIABLE CLICK_ARCH
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json
            DESTINATION ${CMAKE_INSTALL_PREFIX})
    install(FILES camera.apparmor
            DESTINATION ${CMAKE_INSTALL_PREFIX})
    install(FILES camera-contenthub.json
            DESTINATION ${CMAKE_INSTALL_PREFIX})

else(CLICK_MODE)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
        DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
endif(CLICK_MODE)

add_subdirectory(CameraApp)
add_subdirectory(desktop)

file(GLOB_RECURSE I18N_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/po
     **.qml)
list(APPEND I18N_SRC_FILES ${DESKTOP_FILE}.in.in.h)
list(SORT I18N_SRC_FILES)

# for dh_translations to extract the domain
# (regarding syntax consistency, see http://pad.lv/1181187)
set (GETTEXT_PACKAGE "camera-app")

add_subdirectory(po)

enable_testing()
add_subdirectory(tests)
