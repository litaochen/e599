# this class has functions to parse the output from CellProfiler and convert to json representation

# import libs
import datetime
import csv
import json
import re
import copy
import extractor
import logging


class Cp_result_processor:
    def __init__(self, run_id, run_path):
        # initiate the base result dictionary
        self.result_dict_base = extractor.extract_run_metadata(run_path)
        self.result_dict_base["run_id"] = run_id
        self.result_dict_base["well_level_summary"] = []
        self.result_dict_base["cell_level_summary"] = []
        self.result_dict_base["image_sets"] = []
        self.list_of_result_doc = {}

    # a function to parse number-like value to float
    def fix_floats(self, data):
        if isinstance(data, list):
            iterator = enumerate(data)
        elif isinstance(data, dict):
            iterator = data.items()
        else:
            raise TypeError("can only traverse list or dict")

        for i, value in iterator:
            if isinstance(value, (list, dict)):
                self.fix_floats(value)
            elif isinstance(value, str):
                try:
                    data[i] = float(value)
                except ValueError:
                    pass

    # a function to parse a well-level summary file and save to the result dictionary
    # it also store the image_set to image_ids mapping
    def parse_well_level_summary(self):
        logging.getLogger().setLevel(logging.INFO)
        logging.info("parsing well level summary")
        the_csv = self.result_dict_base["well_level_summary_file"]
        csvfile = open(the_csv, "r")
        reader = csv.DictReader(csvfile)

        # add each row to summary
        for row in reader:
            self.result_dict_base["well_level_summary"].append(row)

            # each row is an image_set. build the mapping between image_set and image_id
            image_set_number = row["ImageNumber"]
            image_ids = [row[x] for x in row if re.match(r"URL_.*", x)]
            self.result_dict_base["image_sets"].append({image_set_number: image_ids})
            logging.info(image_set_number + ": " + str(image_ids))

    # a function to parse a cell-level summary file and save to the result dictionary
    def parse_cell_level_summary(self):
        logging.getLogger().setLevel(logging.INFO)
        logging.info("parsing cell level summary")
        for the_csv in self.result_dict_base["cell_level_summary_files"]:
            # create a list of dictionaries for each image set
            for image_set in self.result_dict_base["image_sets"]:
                data_for_this_set = copy.deepcopy(self.result_dict_base)
                image_number = list(image_set.keys())[0]
                data_for_this_set["image_ids"] = list(image_set.values())[0]
                self.list_of_result_doc[image_number] = data_for_this_set

            # read the csv file and convert each row into json record
            csvfile = open(the_csv, "r")
            reader = csv.DictReader(csvfile)
            for row in reader:
                self.list_of_result_doc[row["ImageNumber"]][
                    "cell_level_summary"
                ].append(row)

            # remove image_set field from the final result
            for doc in self.list_of_result_doc.values():
                del doc["image_sets"]

    # main method to save result to db
    def parse_run_result(self):
        logging.getLogger().setLevel(logging.INFO)
        logging.info("parsing result")
        self.parse_well_level_summary()
        self.parse_cell_level_summary()

        # # for debugging
        # with open("result.json", "w") as fp:
        #     json.dump(self.list_of_result_doc, fp)

        # return a list of json docs, each doc represent data from one image set
        doc_list = {"documents": []}
        for doc in self.list_of_result_doc.values():
            doc_list["documents"].append(doc)

        logging.info("number of docs extracted: " + str(len(doc_list["documents"])))

        # convert string to number (float)
        self.fix_floats(doc_list)
        return doc_list
