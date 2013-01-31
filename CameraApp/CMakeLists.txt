# QML plugin

set(plugin_SRCS
    components.cpp
    advancedcamerasettings.cpp
    )

set(plugin_HDRS
    components.h
    advancedcamerasettings.h
    )

add_library(camera-qml SHARED ${plugin_SRCS} ${plugin_HDRS})

target_link_libraries(camera-qml
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${Qt5Multimedia_LIBRARIES}
    )


# Qt5's cmake does not export QT_IMPORTS_DIR, lets query qmake on our own for now
get_target_property(QMAKE_EXECUTABLE Qt5::qmake LOCATION) 
function(QUERY_QMAKE VAR RESULT) 
  exec_program(${QMAKE_EXECUTABLE} ARGS "-query ${VAR}" RETURN_VALUE return_code OUTPUT_VARIABLE output ) 
  if(NOT return_code) 
    file(TO_CMAKE_PATH "${output}" output) 
    set(${RESULT} ${output} PARENT_SCOPE) 
  endif(NOT return_code) 
endfunction(QUERY_QMAKE) 
query_qmake(QT_INSTALL_QML QT_IMPORTS_DIR)


set(PLUGIN_DIR ${QT_IMPORTS_DIR}/CameraApp)
install(TARGETS camera-qml DESTINATION ${PLUGIN_DIR})
install(FILES qmldir DESTINATION ${PLUGIN_DIR})

