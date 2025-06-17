cmake_minimum_required(VERSION 3.22)
project(FastDDSIdlWrapper)
find_package(fastdds CONFIG REQUIRED) # Is this line needed?
find_program(FASTDDSGEN fastddsgen)
message(STATUS "Configuring Fast DDS IDL code generation")

if (NOT FASTDDSGEN)
	message(FATAL_ERROR "fastddsgen not found. Please install Fast DDS and add it to your PATH.")
endif()

set(GENERATED_TYPE_SUPPORT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/generated/)
set(IDL_FILES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/inputFolder/)
file(GLOB_RECURSE IDL_FILES ${IDL_FILES_DIR}/*.idl)

set(ALL_GENERATED_FILES "")
foreach(IDL_FILE ${IDL_FILES})

	file(RELATIVE_PATH REL_PATH ${IDL_FILES_DIR} ${IDL_FILE})
    get_filename_component(IDL_NAME ${IDL_FILE} NAME_WE)
	get_filename_component(REL_DIR ${REL_PATH} DIRECTORY)
	
	# Compute output subdirectory path
    set(OUTPUT_SUBDIR "${GENERATED_TYPE_SUPPORT_DIR}/${REL_DIR}")
	
    set(GENERATED_PUBTYPE_FILE "${OUTPUT_SUBDIR}/${IDL_NAME}PubSubTypes.cxx")
    set(GENERATED_TYPEOBJ_FILE "${OUTPUT_SUBDIR}/${IDL_NAME}TypeObjectSupport.cxx")

    list(APPEND ALL_GENERATED_FILES ${GENERATED_PUBTYPE_FILE} ${GENERATED_TYPEOBJ_FILE})
endforeach()

add_custom_command(
        OUTPUT ${ALL_GENERATED_FILES}
        COMMAND ${CMAKE_COMMAND} -E touch ${ALL_GENERATED_FILES} # Ensure the output files are created
        COMMAND ${FASTDDSGEN} -csharp -replace -d ${GENERATED_TYPE_SUPPORT_DIR} ${IDL_FILES}
		WORKING_DIRECTORY ${IDL_FILES_DIR}
        DEPENDS ${IDL_FILES}
        COMMENT "Generating ePromisa FastDDS C++ sources ..."
        VERBATIM
    )
	
add_custom_target(generate_fastdds_code DEPENDS ${ALL_GENERATED_FILES})
# Create the actual library that depends on the generation
add_library(eiva_custom_idl ${ALL_GENERATED_FILES})
add_dependencies(eiva_custom_idl generate_fastdds_code)

target_include_directories(eiva_custom_idl 
        PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/generated>
        PRIVATE
        $<BUILD_INTERFACE:${GENERATED_TYPE_SUPPORT_DIR}>
)

target_link_libraries(eiva_custom_idl PUBLIC fastdds::fastdds)