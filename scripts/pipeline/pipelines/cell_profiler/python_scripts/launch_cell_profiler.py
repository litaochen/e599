#imports
import json
import sys
import os
import glob

def get_config_dict(config_file_name):
    with open(config_file_name) as json_file:
        omero_dict = json.load(json_file)
        return omero_dict

def get_omero_credential_args(config_dict, user_name, passwd):
    # create the credential string
    omero_credential_args = "--omero-credentials "

    # get the omero login info from the config dict
    server = config_dict['server']
    port = config_dict['port']

    # build the credential arg string
    omero_credential_args = omero_credential_args + \
                            "host=" + server + "," + \
                            "port=" + str(port) + "," + \
                            "user=" + user_name + "," + \
                            "password=" + passwd

    return omero_credential_args

def main():
    # get the args
    config_file_name_index = 1
    user_name_index = 2
    passwd_index = 3
    output_dir_index = 4
    success_file_name_index = 5
    exec_string_index = 6
    num_expected_args = 7

    if len(sys.argv) != num_expected_args:
        print "Usage: %s: <json config full path name> <omero user name> <omero passwd> <output dir> <success file name> <cell profiler exec string>" % sys.argv[0]
        sys.exit(1)

    # get the config file name arg
    config_file_name = sys.argv[config_file_name_index]

    # get the user name and passwd args
    user_name = sys.argv[user_name_index]
    passwd = sys.argv[passwd_index]

    # get the exec string arg
    exec_string = sys.argv[exec_string_index]

    # read the config file containing omero login credentials
    config_dict = get_config_dict(config_file_name)
    print "Config params:"
    print config_dict

    # get the omero login credentials
    omero_credential_args = get_omero_credential_args(config_dict, user_name, passwd)

    # append the omero credential args to the exec string
    exec_string = exec_string + " " + omero_credential_args

    # print the exec string - will be redirected to a log file by the caller
    print("exec_string:", exec_string)

    # execute cell profiler
    exit_code = os.system(exec_string)

    # if the cell profiler exit code is 0 (no errors)
    if exit_code == 0:
        # get the output dir
        output_dir = sys.argv[output_dir_index]

        # create a csv wildcard dir list str
        csv_string = "%s/*.csv" % output_dir

        # get a directory listing of the output dir csv files
        csv_file_list = glob.glob(csv_string)

        # if the number of csv files in the output dir >= expected num
        expected_num_csv_files = 3
        if len(csv_file_list) >= expected_num_csv_files:
            # get the success file name
            success_file_name = sys.argv[success_file_name_index]

            # create the full path success file name
            success_full_path_name = "%s/%s" % (output_dir, success_file_name)

            # create the success file to indicat that the cell profiler run was successful
            with open(success_full_path_name, 'w') as success_file:
                success_file.write("Cell profiler success!")

    # return the exit code to the caller
    sys.exit(exit_code)

# if this is the main program
if __name__ == "__main__":
    # call main
    main()
