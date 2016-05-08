
if( BENCHMARK_COUNT )
	set(RES_OUT_FILE "${CMAKE_BINARY_DIR}/${VIS_DIR}/count-results.csv")
	add_custom_command(
		OUTPUT "${RES_OUT_FILE}"
		COMMAND sh gather-results.sh "${CMAKE_BINARY_DIR}/${RESULTS_DIR}" "${RES_OUT_FILE}" "COUNT"
		WORKING_DIRECTORY "${CMAKE_HOME_DIRECTORY}/visualize/"
		DEPENDS count-all-indexes
	)


	set(RES_PARSED_FILE "${CMAKE_BINARY_DIR}/${VIS_DIR}/count_results_parsed.csv")
	add_custom_command(
		OUTPUT ${RES_PARSED_FILE}
		COMMAND ${RSCRIPT_EXECUTABLE} "${CMAKE_HOME_DIRECTORY}/visualize/count.R" "${RES_OUT_FILE}" "${RES_PARSED_FILE}"
		DEPENDS ${RES_OUT_FILE}
	)


	set(PDF_FILE "${CMAKE_BINARY_DIR}/${VIS_DIR}/count.pdf")
	add_custom_command(
		OUTPUT ${PDF_FILE}
		COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_HOME_DIRECTORY}/visualize/count.tex" "${CMAKE_BINARY_DIR}/${VIS_DIR}/"
		COMMAND ${PDFLATEX_COMPILER} "${CMAKE_BINARY_DIR}/${VIS_DIR}/count.tex"
		WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/${VIS_DIR}/"
		DEPENDS ${RES_PARSED_FILE}
	)

	add_custom_target(
		produce-pdf-output ALL
		DEPENDS ${PDF_FILE}
	)

endif()