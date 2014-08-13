execute_process(COMMAND python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"
    OUTPUT_VARIABLE PYTHON_PACKAGE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)

if(INSTALL_TESTS)
if(NOT CLICK_MODE)
message(WARNING ${PYTHON_PACKAGE_DIR})
install(DIRECTORY ${AUTOPILOT_DIR}
    DESTINATION ${PYTHON_PACKAGE_DIR}
    )
endif(NOT CLICK_MODE)
endif(INSTALL_TESTS)
