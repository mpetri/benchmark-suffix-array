#include <sdsl/suffix_arrays.hpp>
#include <chrono>

#include "util.hpp"

using namespace std::chrono;
using watch = std::chrono::high_resolution_clock;
using namespace sdsl;


int main(int argc, char const *argv[])
{
	if (argc < 4) {
		return EXIT_FAILURE;
	}
	/* (1) parse command line */
	std::string text_file = argv[1];
	std::string test_case_name = argv[2];
	int input_type = std::atoi(argv[3]);

	/* (2) generate or read patterns */
	std::string pattern_file = std::string(PATTERN_DIR) + "/" + test_case_name + ".sdsl";
	auto patterns = generate_or_load_patterns(pattern_file,text_file,input_type,test_case_name);

	/* (3) build or load index */
	std::string index_name = IDX_NAME;
	CSA_TYPE csa;
	std::string csa_file = std::string(INDEX_DIR) + "/" + test_case_name + "-" + index_name + "-" 
			+ sdsl::util::class_to_hash(csa) + ".sdsl";
	build_or_load_csa(csa,csa_file,text_file,input_type,test_case_name);

	/* (4) perform searches */
	std::cout << "RUN QUERIES " << index_name << " " << test_case_name << std::endl;
	auto start = watch::now();
	size_t checksum = 0;
	auto pat_beg = patterns.begin();
	uint64_t pattern_len = COUNT_PAT_LEN;
	if(input_type != 1) {
		pattern_len = COUNT_PAT_LEN_INT;
	}
	const uint64_t pattern_cnt = COUNT_NUM_PATTERNS;
	for(auto i=0;i<pattern_cnt;i++) {
		checksum += sdsl::count(csa,pat_beg,pat_beg+pattern_len);
		pat_beg += pattern_len;
	}
	auto end = watch::now();

	size_t input_size_bytes = sdsl::util::file_size(text_file);

	std::string structure_file = std::string(RESULTS_DIR) + "/" + test_case_name + "-" + index_name + ".html";
	sdsl::write_structure<HTML_FORMAT>(csa,structure_file);

	/* (5) output results */
	std::string results_file = std::string(RESULTS_DIR) + "/COUNT-" + test_case_name + "-" + index_name + ".csv";
	std::ofstream ofs(results_file);
	ofs << test_case_name << ";" 
		<< index_name << ";"
		<< input_type << ";"
		<< input_size_bytes << ";"
		<< sdsl::size_in_bytes(csa) << ";"
		<< checksum << ";"
		<< pattern_cnt << ";"
		<< pattern_len << ";"
		<< pattern_cnt * pattern_len << ";"
		<< (end-start).count() << std::endl;
	
	return EXIT_SUCCESS;
}