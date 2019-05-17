# imports
import os

# Environment variables
# Note: Environment variable names are defined in the cell_profiler_glue.bash startup script
#       and in setup.bash.
dataset_id_env_var = "dataset_id"
cppipe_env_var = "cppipe_file"
output_dir_env_var = "output_dir"
config_file_env_var = "config_file"
user_name_env_var = "user_name"
passwd_env_var = "passwd"

get_file_list_file_name_env_var = "get_file_list_file_name"
get_file_list_component_runner_env_var = "get_file_list_component_runner"
get_file_list_component_name_env_var = "get_file_list_component_name"

cell_profiler_component_runner_env_var = "cell_profiler_component_runner"
cell_profiler_component_name_env_var = "cell_profiler_component_name"
cell_profiler_success_file_name_env_var = "cell_profiler_success_file_name"

parse_cp_output_component_name_env_var = "parse_cp_output_component_name"
cell_profiler_parser_component_runner_env_var = "parse_cp_output_component_runner"

# if the dataset_id_env_var exists
if dataset_id_env_var in os.environ:
    dataset_id = os.environ[dataset_id_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % dataset_id_env_var)

# if the cppipe_env_var exists
if cppipe_env_var in os.environ:
    cppipe = os.environ[cppipe_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % cppipe_env_var)

# if the output_dir_env_var exists
if output_dir_env_var in os.environ:
    output_dir = os.environ[output_dir_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % output_dir_env_var)

# if the config_file_env_var exists
if config_file_env_var in os.environ:
    config_file = os.environ[config_file_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % config_file_env_var)

# if the user_name_env_var exists
if user_name_env_var in os.environ:
    user_name = os.environ[user_name_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % user_name_env_var)

# if the passwd_env_var exists
if passwd_env_var in os.environ:
    passwd = os.environ[passwd_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % passwd_env_var)

# if the get_file_list_file_name_env_var exists
if get_file_list_file_name_env_var in os.environ:
    get_file_list_file_name = os.environ[get_file_list_file_name_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % get_file_list_file_name_env_var)

# if the get_file_list_component_runner_env_var exists
if get_file_list_component_runner_env_var in os.environ:
    get_file_list_component_runner = os.environ[get_file_list_component_runner_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % \
                    get_file_list_component_runner)

# if the get_file_list_component_name_env_var exists
if get_file_list_component_name_env_var in os.environ:
    get_file_list_component_name = os.environ[get_file_list_component_name_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % \
                    get_file_list_component_name_env_var)

# if the cell_profiler_component_runner_env_var exists
if cell_profiler_component_runner_env_var in os.environ:
    cell_profiler_component_runner = os.environ[cell_profiler_component_runner_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % \
                    cell_profiler_component_runner_env_var)

# if the cell_profiler_component_name_env_var exists
if cell_profiler_component_name_env_var in os.environ:
    cell_profiler_component_name = os.environ[cell_profiler_component_name_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % \
                    cell_profiler_component_name_env_var)

# if the cell_profiler_success_file_name_env_var exists
if cell_profiler_success_file_name_env_var in os.environ:
    cell_profiler_success_file_name = os.environ[cell_profiler_success_file_name_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % \
                    cell_profiler_success_file_name_env_var)

# if the parse_cp_output_component_name_env_var exists
if parse_cp_output_component_name_env_var in os.environ:
    parse_cp_output_component_name = os.environ[parse_cp_output_component_name_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % \
                    parse_cp_output_component_name_env_var)

# if the cell_profiler_parser_component_runner_env_var exists
if cell_profiler_parser_component_runner_env_var in os.environ:
    cell_profiler_parser_component_runner = \
                         os.environ[cell_profiler_parser_component_runner_env_var]
else:
    # else throw an excetpion
    raise Exception("Error - Undefined environement var: %s" % \
                    cell_profiler_parser_component_runner_env_var)
