# MAGIos Swift CMake Configuration
# Alternative build system for Embedded Swift components
# This provides CMake-based building as an alternative to Swift Package Manager

cmake_minimum_required(VERSION 3.16)

# Project configuration
project(MAGIosSwift
    VERSION 0.0.1
    DESCRIPTION "MAGIos Embedded Swift Kernel Components"
    LANGUAGES Swift C
)

# Require Swift support
if(NOT CMAKE_Swift_COMPILER)
    message(FATAL_ERROR "Swift compiler not found. Please install Swift development toolchain.")
endif()

# Check Swift version
execute_process(
    COMMAND ${CMAKE_Swift_COMPILER} --version
    OUTPUT_VARIABLE SWIFT_VERSION_OUTPUT
    ERROR_QUIET
)

if(NOT SWIFT_VERSION_OUTPUT MATCHES "(6\\.0-dev|main)")
    message(FATAL_ERROR "Swift development snapshot (6.0-dev or main) required for Embedded Swift support")
endif()

message(STATUS "Found Swift: ${CMAKE_Swift_COMPILER}")
message(STATUS "Swift version: ${SWIFT_VERSION_OUTPUT}")

# === TARGET ARCHITECTURE CONFIGURATION ===
set(TARGET_TRIPLE "i686-unknown-none-elf" CACHE STRING "Target triple for cross-compilation")
set(CMAKE_Swift_COMPILER_TARGET "${TARGET_TRIPLE}")

# === EMBEDDED SWIFT CONFIGURATION ===
set(CMAKE_Swift_FLAGS_RELEASE "-O -whole-module-optimization")
set(CMAKE_Swift_FLAGS_DEBUG "-g")

# Embedded Swift specific flags
list(APPEND CMAKE_Swift_COMPILE_OPTIONS
    # Enable Embedded Swift mode
    "-enable-experimental-feature" "Embedded"

    # Target specification
    "-target" "${TARGET_TRIPLE}"

    # Disable features not available in embedded mode
    "-Xfrontend" "-disable-objc-interop"
    "-Xfrontend" "-disable-stack-protector"
    "-Xfrontend" "-function-sections"
    "-Xfrontend" "-gline-tables-only"

    # Freestanding environment
    "-Xcc" "-ffreestanding"
    "-Xcc" "-fno-stack-protector"
    "-Xcc" "-nostdlib"
    "-Xcc" "-m32"
    "-Xcc" "-mpreferred-stack-boundary=2"

    # Optimization flags for size and performance
    "-Xfrontend" "-sil-verify-all"
    "-Xfrontend" "-disable-sil-perf-optzns"
)

# === SOURCE FILES ===
set(SWIFT_SOURCES
    Sources/MAGIosSwift/SwiftKernel.swift
)

# Check if all source files exist
foreach(SOURCE_FILE ${SWIFT_SOURCES})
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE_FILE}")
        message(WARNING "Swift source file not found: ${SOURCE_FILE}")
    endif()
endforeach()

# === INCLUDE DIRECTORIES ===
set(INCLUDE_DIRS
    Sources/MAGIosSwift/include
)

# === STATIC LIBRARY TARGET ===
add_library(MAGIosSwift STATIC ${SWIFT_SOURCES})

# Set target properties
set_target_properties(MAGIosSwift PROPERTIES
    Swift_LANGUAGE_VERSION 5
    Swift_MODULE_NAME MAGIosSwift
    OUTPUT_NAME "magios_swift"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

# Include directories
target_include_directories(MAGIosSwift PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Sources/MAGIosSwift/include>
    $<INSTALL_INTERFACE:include>
)

# === COMPILER-SPECIFIC SETTINGS ===
if(CMAKE_Swift_COMPILER_ID STREQUAL "Apple")
    # Apple Swift compiler
    target_compile_options(MAGIosSwift PRIVATE
        "-Xfrontend" "-disable-reflection-metadata"
        "-Xfrontend" "-disable-reflection-names"
    )
elseif(CMAKE_Swift_COMPILER_ID STREQUAL "Swift")
    # Open source Swift compiler
    target_compile_options(MAGIosSwift PRIVATE
        "-Xfrontend" "-disable-reflection-metadata"
        "-Xfrontend" "-disable-reflection-names"
    )
endif()

# === BUILD TYPE SPECIFIC FLAGS ===
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(MAGIosSwift PRIVATE
        "-g"
        "-DDEBUG=1"
    )
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options(MAGIosSwift PRIVATE
        "-O"
        "-DNDEBUG=1"
    )
endif()

# === LINKER SETTINGS ===
if(CMAKE_Swift_COMPILER_ID STREQUAL "Swift")
    set_target_properties(MAGIosSwift PROPERTIES
        LINK_FLAGS "-nostdlib -static"
    )
endif()

# === CUSTOM TARGETS ===

# Generate Swift module interface
add_custom_target(swift-interface
    COMMAND ${CMAKE_Swift_COMPILER}
        -typecheck -emit-module-interface-path ${CMAKE_BINARY_DIR}/MAGIosSwift.swiftinterface
        ${SWIFT_SOURCES}
        ${CMAKE_Swift_COMPILE_OPTIONS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating Swift module interface"
    VERBATIM
)

# Swift syntax check
add_custom_target(swift-check
    COMMAND ${CMAKE_Swift_COMPILER}
        -typecheck
        ${SWIFT_SOURCES}
        ${CMAKE_Swift_COMPILE_OPTIONS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Checking Swift syntax"
    VERBATIM
)

# Generate assembly output for inspection
add_custom_target(swift-asm
    COMMAND ${CMAKE_Swift_COMPILER}
        -emit-assembly
        -o ${CMAKE_BINARY_DIR}/SwiftKernel.s
        ${CMAKE_CURRENT_SOURCE_DIR}/Sources/MAGIosSwift/SwiftKernel.swift
        ${CMAKE_Swift_COMPILE_OPTIONS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating Swift assembly output"
    VERBATIM
)

# Generate LLVM IR for analysis
add_custom_target(swift-ir
    COMMAND ${CMAKE_Swift_COMPILER}
        -emit-ir
        -o ${CMAKE_BINARY_DIR}/SwiftKernel.ll
        ${CMAKE_CURRENT_SOURCE_DIR}/Sources/MAGIosSwift/SwiftKernel.swift
        ${CMAKE_Swift_COMPILE_OPTIONS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating Swift LLVM IR"
    VERBATIM
)

# === INSTALLATION ===
install(TARGETS MAGIosSwift
    EXPORT MAGIosSwiftTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(DIRECTORY Sources/MAGIosSwift/include/
    DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

# Export targets
install(EXPORT MAGIosSwiftTargets
    FILE MAGIosSwiftTargets.cmake
    NAMESPACE MAGIos::
    DESTINATION lib/cmake/MAGIosSwift
)

# === PACKAGING ===
include(CMakePackageConfigHelpers)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/MAGIosSwiftConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/MAGIosSwiftConfig.cmake"
    INSTALL_DESTINATION lib/cmake/MAGIosSwift
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/MAGIosSwiftConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MAGIosSwiftConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/MAGIosSwiftConfigVersion.cmake"
    DESTINATION lib/cmake/MAGIosSwift
)

# === TESTING ===
if(BUILD_TESTING)
    enable_testing()

    add_test(
        NAME swift_syntax_check
        COMMAND ${CMAKE_Swift_COMPILER} -typecheck ${SWIFT_SOURCES} ${CMAKE_Swift_COMPILE_OPTIONS}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

    add_test(
        NAME swift_compile_test
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target MAGIosSwift
    )
endif()

# === DEVELOPMENT HELPERS ===

# Print configuration summary
message(STATUS "=== MAGIos Swift Configuration ===")
message(STATUS "Target Triple: ${TARGET_TRIPLE}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Swift Compiler: ${CMAKE_Swift_COMPILER}")
message(STATUS "Output Directory: ${CMAKE_BINARY_DIR}")
message(STATUS "Source Files: ${SWIFT_SOURCES}")

# Create a development script
file(WRITE "${CMAKE_BINARY_DIR}/build_info.txt"
"MAGIos Swift Build Information
=============================
Build Date: ${CMAKE_TIMESTAMP}
Target: ${TARGET_TRIPLE}
Build Type: ${CMAKE_BUILD_TYPE}
Swift Compiler: ${CMAKE_Swift_COMPILER}
CMake Version: ${CMAKE_VERSION}
")

# === ERROR CHECKING ===
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Sources/MAGIosSwift/SwiftKernel.swift")
    message(FATAL_ERROR "Main Swift kernel file not found!")
endif()

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Sources/MAGIosSwift/include/kernel_bridge.h")
    message(FATAL_ERROR "Kernel bridge header not found!")
endif()

message(STATUS "CMake configuration complete!")
