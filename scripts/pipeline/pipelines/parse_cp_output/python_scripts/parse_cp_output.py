# a script to parse the output from CellProfiler into json docs to be saved to disk

# args:
# arg1: run_id the unique run id
# arg2: run_output_dir the directory that contains the output from CellProfiler
# arg3: dir_for_parsed_doc the directory the parsed joson docs will be saved

# example uage:
# python parse_cp_output.py run6 'path/to/cp/output' 'path/to/save/parsed/result'
# the result file will be saved with the name of "run_id.json"

import sys
import json
from processor import Cp_result_processor


run_id = sys.argv[1]
run_output_path = sys.argv[2]
dir_for_parsed_doc = sys.argv[3]

print(sys.argv[0])
print("run_id:", run_id)
print("run_output_path:", run_output_path)
print("dir_for_parsed_doc:", dir_for_parsed_doc)

save_to_file = dir_for_parsed_doc + "/" + run_id + ".json"


result_docs = Cp_result_processor(run_id, run_output_path).parse_run_result()


with open(save_to_file, "w") as fp:
    json.dump(result_docs, fp)


# the structure of the result_docs
# {
#     "documents": [each_doc]
# }

# the structure of each doc is:
# {
#     "well_level_summary_file": "....",
#     "cell_level_summary_file": [],
#     "CellProfiler_version": "3.1.8",
#     "Pipeline_Pipeline": "a_long_string",
#     "Run_Timestamp": "20190304",
#     "run_id": "the_id",
#     "well_level_summary": [],
#     "cell_level_summary": [],
#     "image_ids": [],
# }
