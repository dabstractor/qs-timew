cmake_minimum_required(VERSION 3.16)

project(qs-timew VERSION 1.0.0 LANGUAGES NONE)

# Find required Qt components
find_package(Qt6 REQUIRED COMPONENTS Qml Quick QuickControls2)

# Enable Qt MOC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Define install directories
set(QML_INSTALL_DIR "lib/qml" CACHE PATH "QML install directory")
set(DOC_INSTALL_DIR "share/doc/qs-timew" CACHE PATH "Documentation install directory")

# Source files
set(QML_SOURCES
    src/services/TimewarriorService.qml
    src/widgets/TimewarriorWidget.qml
    src/integration/IntegrationComponent.qml
)

# Example files
set(EXAMPLE_SOURCES
    examples/MinimalExample.qml
    examples/BasicWidget.qml
    examples/CompleteExample.qml
    examples/QuickshellIntegration.qml
)

# Test files
set(TEST_SOURCES
    tests/TestRunner.qml
    tests/TestUtils.qml
    tests/test-config.json
)

# Install QML module
install(FILES ${QML_SOURCES}
    DESTINATION ${QML_INSTALL_DIR}/qs_timew
)

install(FILES qmldir
    DESTINATION ${QML_INSTALL_DIR}/qs_timew
)

# Install examples
install(FILES ${EXAMPLE_SOURCES}
    DESTINATION ${DOC_INSTALL_DIR}/examples
)

# Install documentation
install(DIRECTORY docs/
    DESTINATION ${DOC_INSTALL_DIR}
)

# Install tests
install(FILES ${TEST_SOURCES}
    DESTINATION ${DOC_INSTALL_DIR}/tests
)

install(DIRECTORY tests/
    DESTINATION ${DOC_INSTALL_DIR}/tests
    FILES_MATCHING PATTERN "*.qml"
)

# Install configuration files
install(FILES package.json README.md LICENSE
    DESTINATION ${DOC_INSTALL_DIR}
)

# Custom target for running tests
add_custom_target(run-tests
    COMMAND qmltestrunner -input tests/TestRunner.qml
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running qs-timew test suite"
)

# Custom target for testing examples
add_custom_target(test-examples
    COMMAND qmlscene examples/MinimalExample.qml
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Testing minimal example"
)

# Custom target for complete example
add_custom_target(run-example
    COMMAND qmlscene examples/CompleteExample.qml
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running complete example"
)

# Package configuration
include(CMakePackageConfigHelpers)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/qs-timew-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/qs-timew-config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/qs-timew
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/qs-timew-config-version.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/qs-timew-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/qs-timew-config-version.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/qs-timew
)