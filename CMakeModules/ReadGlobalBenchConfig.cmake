include(HelperFunctions)
include(AppendCompilerFlags)

file(STRINGS ${CMAKE_HOME_DIRECTORY}/benchmark.config config_contents)

foreach(keyvalue ${config_contents})
	string(REGEX REPLACE "^[ ]+" "" keyvalue ${keyvalue})
	string(REGEX MATCH "^[^=]+" key ${keyvalue})
	string(REPLACE "${key}=" "" value ${keyvalue})
	set(${key} "${value}")
endforeach(keyvalue)

if(NOT DEFINED SDSL_REPO_URL)
	message(FATAL_ERROR "${Red}Could not find sdsl-lite repositor URL in benchmark.config.${ColourReset}")
else()
	message(STATUS "${Green}Using sdsl-lite repository: ${SDSL_REPO_URL}${ColourReset}")
endif()

if(NOT DEFINED SDSL_REPO_BRANCH)
	message(STATUS "${Yellow}No sdsl-lite branch specified. Using master.${ColourReset}")
	set(SDSL_REPO_BRANCH "master")
else()
	message(STATUS "${Green}Using sdsl-lite branch: ${SDSL_REPO_BRANCH}${ColourReset}")
endif()

if( BENCHMARK_COUNT )
	if(NOT DEFINED COUNT_PATTERN_LEN)
		set(COUNT_PATTERN_LEN "20")
	endif()
	if(NOT DEFINED COUNT_PATTERN_CNT)
		set(COUNT_PATTERN_CNT "50000")
	endif()
endif()

if(DEFINED BENCH_COMPILE_FLAGS)
	append_cxx_compiler_flags("${BENCH_COMPILE_FLAGS}" "GCC" CMAKE_CXX_FLAGS)
endif()

# so we parse the cfg again if it changes
configure_file("${CMAKE_HOME_DIRECTORY}/benchmark.config" ".benchmark.config.current")

#  make sure we have the right sdsl branch downloaded
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite")
	execute_process(
		COMMAND ${GIT_EXECUTABLE} "clone" "${SDSL_REPO_URL}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/external/"
		)
	execute_process(
		COMMAND "${GIT_EXECUTABLE}" checkout "${SDSL_REPO_BRANCH}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite"
		OUTPUT_QUIET
		ERROR_QUIET
	)
endif()

# Get the current working branch
execute_process(
  COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
  WORKING_DIRECTORY  "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite"
  OUTPUT_VARIABLE GIT_BRANCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

execute_process(
  COMMAND ${GIT_EXECUTABLE} remote get-url origin
  WORKING_DIRECTORY  "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite"
  OUTPUT_VARIABLE GIT_CUR_REPO_URL
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get the latest abbreviated commit hash of the working branch
execute_process(
  COMMAND ${GIT_EXECUTABLE} log -1 --format=%h
  WORKING_DIRECTORY  "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite"
  OUTPUT_VARIABLE GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

#  make sure we have the right sdsl branch downloaded
if((NOT "${GIT_BRANCH}" STREQUAL "${SDSL_REPO_BRANCH}" ) OR (NOT "${SDSL_REPO_URL}" STREQUAL "${GIT_CUR_REPO_URL}" ) )
	message(STATUS "${Yellow}sdsl-lite branch or repo URL inconsistant.${ColourReset}")
	file(REMOVE_RECURSE "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite")
	execute_process(
		COMMAND ${GIT_EXECUTABLE} "clone" "${SDSL_REPO_URL}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/external/"
		)
	execute_process(
		COMMAND "${GIT_EXECUTABLE}" checkout "${SDSL_REPO_BRANCH}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite"
		OUTPUT_QUIET
		ERROR_QUIET
	)

	# Get the current working branch
	execute_process(
	  COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
	  WORKING_DIRECTORY  "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite"
	  OUTPUT_VARIABLE GIT_BRANCH
	  OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	execute_process(
	  COMMAND ${GIT_EXECUTABLE} remote get-url origin
	  WORKING_DIRECTORY  "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite"
	  OUTPUT_VARIABLE GIT_CUR_REPO_URL
	  OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	# Get the latest abbreviated commit hash of the working branch
	execute_process(
	  COMMAND ${GIT_EXECUTABLE} log -1 --format=%h
	  WORKING_DIRECTORY  "${CMAKE_CURRENT_SOURCE_DIR}/external/sdsl-lite"
	  OUTPUT_VARIABLE GIT_COMMIT_HASH
	  OUTPUT_STRIP_TRAILING_WHITESPACE
	)
endif()

add_definitions(-DGIT_REPO_URL="${GIT_CUR_REPO_URL}")
add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
add_definitions(-DGIT_BRANCH="${GIT_BRANCH}")

message(STATUS "${Green}sdsl-lite HEAD commit hash: ${GIT_COMMIT_HASH}${ColourReset}")

