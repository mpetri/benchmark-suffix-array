#include <sdsl/suffix_arrays.hpp>
#include <chrono>

#include "util.hpp"

using namespace std::chrono;
using watch = std::chrono::high_resolution_clock;
using namespace sdsl;


int main(int argc, char const *argv[])
{
	if (argc < 2) {
		return EXIT_FAILURE;
	}
	/* (1) parse command line */
	std::string pat_file = argv[1];

	/* (2) generate or read patterns */
    int_vector<> pattern;
    load_from_file(pattern, pat_file);
	uint64_t pattern_len = COUNT_PAT_LEN;
	const uint64_t pattern_cnt = COUNT_NUM_PATTERNS;
    if ( pattern.size() != pattern_len*pattern_cnt ) {
        std::cerr<<"pattern file has incorrect length!"<<std::endl;
        return EXIT_FAILURE;
    }
    std::cout<<"# number="<<pattern_cnt<<"  length="<<pattern_len<<" file="<<util::basename(pat_file)<<" forbidden="<<std::endl;
    for(size_t i=0; i<pattern_cnt; ++i){
        for(size_t j=0; j<pattern_len; ++j){
            std::cout<<(char)pattern[i*pattern_len+j];
        }
    }
	return EXIT_SUCCESS;
}
