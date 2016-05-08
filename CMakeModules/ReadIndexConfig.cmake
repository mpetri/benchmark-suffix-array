include(HelperFunctions)

file(STRINGS ${CMAKE_HOME_DIRECTORY}/index_types.config index_types_contents)

if( BENCHMARK_COUNT )
	add_custom_target(count-all-indexes ALL)
endif()

file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${INDEX_DIR}")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${TMP_DIR}")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${RESULTS_DIR}")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${PATTERN_DIR}")
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${VIS_DIR}")

foreach(line ${index_types_contents})
	if(NOT line MATCHES "^#")
		list(GET line 0 index_name) 
		string(REPLACE " " "" index_name ${index_name})
		list(GET line 1 index_type)
		string(REPLACE " " "" index_type ${index_type})
		list(GET line 2 index_int_type)
		string(REPLACE " " "" index_int_type ${index_int_type})
		list(GET line 3 index_compile_defines)
		message(STATUS "${Cyan}Found index ${index_name} (${index_type}) INT_CSA=${index_int_type}${ColourReset}")

		if( BENCHMARK_COUNT )
			set(IDX_FILE "${CMAKE_BINARY_DIR}/indexes/${current_test_case}-${index_name}.idx")
			add_executable(count-${index_name}.x src/count.cpp)
			target_link_libraries(count-${index_name}.x sdsl divsufsort divsufsort64)
			target_compile_definitions(count-${index_name}.x
				PRIVATE CSA_TYPE=${index_type} IDX_NAME="${index_name}")

			set(i 0)
			foreach(test_case ${test_case_names})
				LIST(GET test_case_names ${i} current_test_case)
				LIST(GET test_case_types ${i} current_test_type)
				LIST(GET test_case_files ${i} current_test_file)
				LIST(GET test_case_pattern_files ${i} current_pattern_file)
				if( index_int_type STREQUAL "0" AND current_test_type STREQUAL "1" )
					set(RES_OUT_FILE "${CMAKE_BINARY_DIR}/${RESULTS_DIR}/${current_test_case}-${index_name}.csv")
					add_custom_command(
						OUTPUT ${RES_OUT_FILE}
						COMMAND count-${index_name}.x "${current_test_file}" "${current_test_case}" "${current_test_type}" 
						DEPENDS count-${index_name}.x 
					)
					add_custom_target(
				    	count-idx-${current_test_case}-${index_name}
				    	DEPENDS ${RES_OUT_FILE}
				    )
					add_dependencies(count-all-indexes "count-idx-${current_test_case}-${index_name}")
				endif()
				if( index_int_type STREQUAL "1" AND (NOT current_test_type STREQUAL "1") )
					set(RES_OUT_FILE "${CMAKE_BINARY_DIR}/${RESULTS_DIR}/${current_test_case}-${index_name}.csv")
					add_custom_command(
						OUTPUT ${RES_OUT_FILE}
						COMMAND count-${index_name}.x "${current_test_file}" "${current_test_case}" "${current_test_type}" 
						DEPENDS count-${index_name}.x 
					)
					add_custom_target(
				    	count-idx-${current_test_case}-${index_name}
				    	DEPENDS ${RES_OUT_FILE}
				    )
					add_dependencies(count-all-indexes "count-idx-${current_test_case}-${index_name}")
				endif()
	    		math(EXPR i "${i} + 1")
			endforeach()
		endif()

		if( BENCHMARK_LOCATE )
			message(STATUS "Add locate-${index_name} binary.")
			add_executable(locate-${index_name}.x src/locate.cpp)
			target_link_libraries(locate-${index_name}.x sdsl divsufsort divsufsort64)
			target_compile_definitions(locate-${index_name}.x 
				PRIVATE CSA_TYPE=${index_type} IDX_NAME="${index_name}")
		endif()

		if( BENCHMARK_EXTRACT )
			message(STATUS "Add extract-${index_name}.x binary.")
			add_executable(extract-${index_name}.x src/extract.cpp)
			target_link_libraries(extract-${index_name}.x sdsl divsufsort divsufsort64)
			target_compile_definitions(extract-${index_name}.x 
				PRIVATE CSA_TYPE=${index_type} IDX_NAME="${index_name}")
		endif()
	endif()
endforeach(line)

# so we parse the cfg again if it changes
configure_file("${CMAKE_HOME_DIRECTORY}/index_types.config" ".index_types.config.current")
