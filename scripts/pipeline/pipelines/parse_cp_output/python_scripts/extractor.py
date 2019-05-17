# this script is used to extract run metada
# currently it extract CellProfiler run info

import csv
import json
import datetime
import os
import re
import logging


def extract_run_metadata(run_output_dir):
    """
    a funcion to collect run metadata from run directory
    and return a dictionary
    Parameters
    ----------
    run_output_dir: str
        the output directory of a CellProfiler run

    returns
    ---------
        a dictionary contains the metadata
        Note: it carries two fields record the well-level-summary file a
        nd cell-level-summary file
        You will need convert the csv files to json
        field name: well_summary_file; cell_level_summary
        For other fields you can decide what to keep and what to remove
    """
    logging.getLogger().setLevel(logging.INFO)

    # pre-defined patterns for finding target files
    # cell level summary files could be a list of the csv files
    run_report_file_pattern = ".*_Experiment.csv"
    well_summary_file_pattern = ".*Image\.csv"
    cell_summary_file_pattern = ".*\.csv"
    output_files = os.listdir(run_output_dir)

    run_report_csv = ""
    well_summary_csv = ""
    cell_level_summary = []

    # find the well / cell level summary and run info
    for f in output_files:
        file_path = os.path.join(run_output_dir, f)
        if re.match(run_report_file_pattern, f):
            run_report_csv = file_path
        elif re.match(well_summary_file_pattern, f):
            well_summary_csv = file_path
        elif re.match(cell_summary_file_pattern, f):
            cell_level_summary.append(file_path)

    # start extract metadata info and store in a dictionary
    run_metadata = {}
    run_metadata["well_level_summary_file"] = well_summary_csv
    run_metadata["cell_level_summary_files"] = cell_level_summary

    # find run info
    csvfile = open(run_report_csv, "r")
    reader = csv.DictReader(csvfile)
    for row in reader:
        run_metadata[row["Key"]] = row["Value"]

    # log the metadata captured
    logging.info("extracted run metadata:")
    for element in run_metadata:
        msg = ""
        if element == "Pipeline_Pipeline":
            msg = element + ": " + "too long, skipped."
        else:
            msg = element + ": " + str(run_metadata[element]) + "\n"

        logging.info(msg)

    return run_metadata

