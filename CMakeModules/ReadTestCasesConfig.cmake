include(HelperFunctions)

file(STRINGS ${CMAKE_HOME_DIRECTORY}/test_cases.config test_config_contents)

set(test_case_names "")
set(test_case_types "")
set(test_case_files "")
foreach(line ${test_config_contents})
	if((NOT line MATCHES "^#") AND (NOT line STREQUAL ""))
		list(GET line 0 test_case_name) 
		string(REPLACE " " "" test_case_name ${test_case_name})
		list(GET line 1 test_case_url)
		if(test_case_url STREQUAL "")
			message(WARNING "${Orange}Test case does not have a URL specified.${ColourReset}")
		endif()
		list(GET line 2 test_case_md5sum)
		if(NOT test_case_md5sum STREQUAL "")
			string(REPLACE " " "" test_case_md5sum ${test_case_md5sum})
		endif()
		list(GET line 3 test_case_type)
		if(NOT test_case_type STREQUAL "")
			string(REPLACE " " "" test_case_type ${test_case_type})
		else()
			set(test_case_type "1")
		endif()
		
		get_filename_component(test_file_name ${test_case_url} NAME)
		message(STATUS "${Blue}Found test case ${test_case_name} (${test_case_url})${ColourReset}")

		# download if it does not exist
		if(NOT EXISTS "${CMAKE_HOME_DIRECTORY}/data/${test_case_name}")
			message(STATUS "Downloading... ${test_case_url}")
			if(NOT test_case_md5sum STREQUAL "")
				file(DOWNLOAD
						${test_case_url} 
						${CMAKE_HOME_DIRECTORY}/data/${test_file_name}
						SHOW_PROGRESS
						EXPECTED_MD5 ${test_case_md5sum}
						STATUS status
						LOG log
					)
			else()
				file(DOWNLOAD
						${test_case_url} 
						${CMAKE_HOME_DIRECTORY}/data/${test_file_name}
						SHOW_PROGRESS
						STATUS status
						LOG log
					)
			endif()
			list(GET status 0 status_code)
			list(GET status 1 status_string)
			if(NOT status_code EQUAL 0)
				message(FATAL_ERROR "error: downloading ${test_file_name} failed status_code: ${status_code} status_string: ${status_string}")
			endif()
			message(STATUS "Downloading... ${test_file_name} done")
		else()
			if( (NOT test_case_md5sum STREQUAL "") AND (NOT test_file_name STREQUAL "") )
				file(MD5 "${CMAKE_HOME_DIRECTORY}/data/${test_file_name}" actual_md5_sum)
				if(NOT test_case_md5sum STREQUAL actual_md5_sum)
					message(FATAL_ERROR "${Red}MD5SUM for existing file ${test_file_name} does not match!.${ColourReset}")
				endif()
			endif()
		endif()

		# extract if necessary
		if(NOT EXISTS "${CMAKE_HOME_DIRECTORY}/data/${test_case_name}")
			if(test_file_name MATCHES "\\.gz$")
				message(STATUS "Extracting... ${test_file_name}.")
				execute_process(
					COMMAND gzip -d -c ${test_file_name}
					WORKING_DIRECTORY "${CMAKE_HOME_DIRECTORY}/data/"
					OUTPUT_FILE "${CMAKE_HOME_DIRECTORY}/data/${test_case_name}"
					)
				message(STATUS "Extracting... ${test_file_name}. DONE")
			elseif(test_file_name MATCHES "\\.bz2$")
				message(STATUS "Extracting... ${test_file_name}.")
				execute_process(
					COMMAND bzip2 -d -c ${test_file_name}
					WORKING_DIRECTORY "${CMAKE_HOME_DIRECTORY}/data/"
					OUTPUT_FILE "${CMAKE_HOME_DIRECTORY}/data/${test_case_name}"
					)
				message(STATUS "Extracting... ${test_file_name}. DONE")
			elseif(test_file_name MATCHES "\\.xz$")
				message(STATUS "Extracting... ${test_file_name}.")
				execute_process(
					COMMAND xz -d -c ${test_file_name}
					WORKING_DIRECTORY "${CMAKE_HOME_DIRECTORY}/data/"
					OUTPUT_FILE "${CMAKE_HOME_DIRECTORY}/data/${test_case_name}"
					)
				message(STATUS "Extracting... ${test_file_name}. DONE")
			else()
				file(COPY "${CMAKE_HOME_DIRECTORY}/data/${test_file_name}" "${CMAKE_HOME_DIRECTORY}/data/${test_case_name}")
			endif()
		endif()

		# check again if file exists after extraction
		if(EXISTS "${CMAKE_HOME_DIRECTORY}/data/${test_case_name}")
			message(STATUS "${Green}Add test case ${test_case_name} to test suite.${ColourReset}")
			list(APPEND test_case_names ${test_case_name})
			list(APPEND test_case_types ${test_case_type})
			list(APPEND test_case_files "${CMAKE_HOME_DIRECTORY}/data/${test_case_name}")
			add_custom_target(${test_case_name})
		else()
			message(ERROR "${Red}Could not add test case ${test_case_name} to test suite.${ColourReset}")
		endif()
	endif()
endforeach(line)

# so we parse the cfg again if it changes
configure_file("${CMAKE_HOME_DIRECTORY}/test_cases.config" ".test_cases.config.current")

