cmake_minimum_required (VERSION 2.8.11)
cmake_policy(SET CMP0048 OLD)
project (benchmark-suffix-array CXX)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules")
include(HelperFunctions)

# make sure we have the required packages
find_package(LATEX COMPONENTS PDFLATEX REQUIRED)
find_package(Git REQUIRED)
find_package(R REQUIRED)

# command line options
option(BENCHMARK_COUNT  "Enable count() benchmarking." ON)
option(BENCHMARK_LOCATE "Enable locate() benchmarking." OFF)
option(BENCHMARK_EXTRACT  "Enable extract() benchmarking." OFF)
option(VISUALIZE_OUTPUT "Visualize the output." OFF)

# read the main config and set some default options
include(ReadGlobalBenchConfig)
set(PATTERN_DIR "./patterns")
set(TMP_DIR "${CMAKE_HOME_DIRECTORY}/tmp")
set(RESULTS_DIR "./results-${GIT_COMMIT_HASH}")
set(INDEX_DIR "./indexes-${GIT_COMMIT_HASH}")
set(VIS_DIR "./visualization-${GIT_COMMIT_HASH}")

# the specified sdsl branch is stored here
add_subdirectory(external/sdsl-lite)

# fix up include directories and sdsl lib path
include_directories("${CMAKE_BINARY_DIR}/external/sdsl-lite/include"
                    "${CMAKE_BINARY_DIR}/external/sdsl-lite/external/libdivsufsort/include/"
					"./include/"
					)
link_directories("${CMAKE_BINARY_DIR}/external/sdsl-lite"
				 "${CMAKE_BINARY_DIR}/external/sdsl-lite/external/libdivsufsort/lib/"
				)

# write the config file
CONFIGURE_FILE( ${CMAKE_SOURCE_DIR}/include/config.hpp.cmake ${CMAKE_SOURCE_DIR}/include/config.hpp )

# read the test cases config
include(ReadTestCasesConfig)

# read the index config
include(ReadIndexConfig)

# compile results
if(VISUALIZE_OUTPUT)
    include(ProcessResults)
endif()












