cmake_minimum_required(VERSION 3.7.0)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})

set(PROJECT_NAME "cpp-can-parser")

project(${PROJECT_NAME} VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 20)
# Get UNIX path prefixes
include(GNUInstallDirs)
# Get access to helper functions for creating config files
include(CMakePackageConfigHelpers)

# Prefer RPATH over RUNPATH
SET(CMAKE_EXE_LINKER_FLAGS "-Wl,--disable-new-dtags")

include(CTest)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

configure_package_config_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PROJECT_NAME}-config.cmake.in
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

write_basic_package_version_file(
        ${PROJECT_NAME}ConfigVersion.cmake
        VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}
        COMPATIBILITY SameMajorVersion
)


set(CPPPARSER_INCLUDE_DIRECTORY 
	${CMAKE_CURRENT_LIST_DIR}/include
)

set(CPPPARSER_INCLUDE_DIRECTORY_PRIVATE 
	${CMAKE_CURRENT_LIST_DIR}/src/parsing
)

set(CPPPARSER_SRC_FILES
	${CMAKE_CURRENT_SOURCE_DIR}/src/models/CANDatabase.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/models/CANFrame.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/models/CANSignal.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/parsing/DBCParser.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/parsing/ParsingUtils.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/parsing/Tokenizer.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/src/analysis/CANFrameAnalysis.cpp
)

set(BUILD_SHARED_LIBS ON)
add_library(${PROJECT_NAME} ${CPPPARSER_SRC_FILES})

set_target_properties(${PROJECT_NAME} PROPERTIES
	VERSION ${PROJECT_VERSION}
	SOVERSION ${PROJECT_VERSION_MAJOR}
)

target_include_directories(${PROJECT_NAME}
	PUBLIC
	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
	$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/exports>
	$<INSTALL_INTERFACE:include>
	PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/src/parsing
)

add_executable(can-parse 
	utils/can-parse/can-parse.cpp
	utils/can-parse/print-frame.cpp
	utils/can-parse/print-single-frame.cpp
	utils/can-parse/check-frame.cpp)
target_link_libraries(can-parse cpp-can-parser)

generate_export_header(${PROJECT_NAME}
	BASE_NAME cpp_can_parser
	EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/exports/cpp_can_parser_export.h
)

install(
	FILES ${CMAKE_CURRENT_BINARY_DIR}/exports/cpp_can_parser_export.h
	DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cpp-can-parser
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/cpp-can-parser
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(TARGETS ${PROJECT_NAME}
	EXPORT "${PROJECT_NAME}Targets"
	LIBRARY
	DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(FILES
	"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
	"${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
	DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake
)

if (BUILD_TESTING)
    file(COPY tests/dbc-files/
            DESTINATION dbc-files/)

    add_executable(cpc-test-parsing
            tests/test-parsing.cpp)
    target_link_libraries(cpc-test-parsing PUBLIC cpp-can-parser)

	add_test(NAME cpc-test-parsing
			COMMAND cpc-test-parsing)

	add_test(NAME cpc-checkframe-1
			 COMMAND can-parse checkframe dbc-files/single-frame-1.dbc)

	add_test(NAME cpc-checkframe-2
			 COMMAND can-parse checkframe dbc-files/single-frame-2.dbc)

	add_test(NAME cpc-checkframe-big-endian-1
			 COMMAND can-parse checkframe 294 dbc-files/big-endian-1.dbc)

	add_test(NAME cpc-checkframe-big-endian-2
			 COMMAND can-parse checkframe 1807 dbc-files/big-endian-1.dbc)
	
	add_test(NAME cpc-checkframe-big-endian-3
			 COMMAND can-parse checkframe 1800 dbc-files/big-endian-1.dbc)
endif()