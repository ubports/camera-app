add_executable(tst_QmlTests tst_QmlTests.cpp)
qt5_use_modules(tst_QmlTests Core Qml Quick Test QuickTest)
target_link_libraries(tst_QmlTests ${TPL_QT5_LIBRARIES})
add_test(tst_QmlTests ${CMAKE_CURRENT_BINARY_DIR}/tst_QmlTests -import ${CMAKE_SOURCE_DIR})
set_tests_properties(tst_QmlTests PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=minimal")

# copy qml test files to build dir
file(GLOB qmlTestFiles RELATIVE ${CMAKE_SOURCE_DIR}/tests/unittests/ *qml)
foreach(qmlTestFile ${qmlTestFiles})
  file(COPY ${qmlTestFile} DESTINATION ${CMAKE_BINARY_DIR}/tests/unittests/)
endforeach(qmlTestFile)

if(NOT CTEST_TESTING_TIMEOUT)
    set(CTEST_TESTING_TIMEOUT 60)
endif()

include_directories(
    ${CMAKE_BINARY_DIR}
    ${camera_plugin_SOURCE_DIR}
    )

add_executable(tst_storagemonitor
    tst_storagemonitor.cpp
    ${camera_plugin_SOURCE_DIR}/storagemonitor.cpp
    qstorageinfo_stub.cpp
    storageinfocontrol.cpp
    )

qt5_use_modules(tst_storagemonitor Widgets Core Quick Qml Test)
add_test(tst_storagemonitor tst_storagemonitor -xunitxml -o test.xml)
set_tests_properties(tst_storagemonitor PROPERTIES
    TIMEOUT ${CTEST_TESTING_TIMEOUT}
    ENVIRONMENT "QT_QPA_PLATFORM=minimal"
    )

target_link_libraries(tst_storagemonitor
    camera-qml
)
