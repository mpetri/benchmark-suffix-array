#pragma once

#include <sdsl/int_vector.hpp>

#include "config.hpp"

bool file_exists(std::string file)
{
    std::ifstream in(file);
    if (in) {
        in.close();
        return true;
    }
    return false;
}

template<class t_csa>
void build_or_load_csa(t_csa& csa,std::string csa_file,std::string text_file,int type,std::string test_case)
{
	if(file_exists(csa_file)) {
		sdsl::load_from_file(csa,csa_file);
	} else {
		std::cout << "BUILD INDEX ("<<IDX_NAME<<") " << test_case << " input type = " << type << std::endl;
		std::string tmp_dir = std::string(TMP_DIR);
		std::string id = test_case;
		sdsl::cache_config cfg;
		cfg.delete_files = false;
		cfg.dir = tmp_dir;
		cfg.id = id;
		construct(csa, text_file, cfg, type);
		store_to_file(csa, csa_file);
	}
}

sdsl::int_vector<>
generate_or_load_patterns(std::string pattern_file,std::string text_file,int type,std::string test_case)
{
	sdsl::int_vector<> patterns;
	if(file_exists(pattern_file)) {
		sdsl::load_from_file(patterns,pattern_file);
	} else {
		std::cout << "GENERATE PATTERNS " << test_case << std::endl;
		uint64_t pattern_len = COUNT_PAT_LEN;
		if(type != 1) {
			pattern_len = COUNT_PAT_LEN_INT;
		}
		const uint64_t pattern_cnt = COUNT_NUM_PATTERNS;
		patterns.resize(pattern_cnt*pattern_len);
		sdsl::int_vector<> text;
		sdsl::load_vector_from_file(text,text_file,type);

		/* make sure the last symbol is not 0 */
		if(type == 0 && text[text.size()-1] == 0) {
			std::cout << "detected 0 in last symbol. removing it!" << std::endl;
			text.resize(text.size()-1);
			sdsl::store_to_file(text,text_file);
		}

	    std::mt19937 gen(RAND_NUM_SEED);
	    std::uniform_int_distribution<uint64_t> dis(0, text.size() - pattern_len - 1 );
		auto pat_out_itr = patterns.begin();
	    for(auto i=0;i<pattern_cnt;i++) {
	    	auto pos = dis(gen);
	    	auto beg = text.begin()+pos;
	    	auto end = beg + pattern_len;
	    	std::copy(beg,end,pat_out_itr);
	    	pat_out_itr += pattern_len;
	    }
	    sdsl::store_to_file(patterns,pattern_file);	
	}
	return patterns;
}