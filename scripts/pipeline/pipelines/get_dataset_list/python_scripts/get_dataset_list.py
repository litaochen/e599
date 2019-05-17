"""
The purpose of this file is to save a json file containing dataset information for all
datasets associated with a given user.

Args:
arg1: Full path config file name.
arg2: OMERO user name
arg3: OMERO passwd
arg4: Full path output json file name
"""

#%% imports
import sys
import json
import inspect
from datetime import datetime

#%%
# Process command line args and finish imports

# command line arg indices
config_file_index = 1
user_name_index = 2
passwd_index = 3
out_file_name_index = 4
num_expected_args = 5

# if the number of received args is not equal to the num expected args
if len(sys.argv) != num_expected_args:
    # print an error and exit
    print "Usage: %s: <json config full path name> <user name> <passwd> <out file full path name>" % sys.argv[0]
    sys.exit(1)

# get the args
config_file = sys.argv[config_file_index]
user_name = sys.argv[user_name_index]
passwd = sys.argv[passwd_index]
out_file_name = sys.argv[out_file_name_index]

# print some useful log data
print "Using the following config file: %s" % config_file
print "User name: %s" % user_name
print "Output file name: %s" % out_file_name

# load the config dictionary
with open(config_file) as config_file:
    config_dict = json.load(config_file)

# set up the python path
sys.path.append(config_dict['python_path'])
print "Adding the following to pythonpath: %s" % config_dict['python_path']

# import omero libraries
from omero.gateway import BlitzGateway
import logging
logging.basicConfig()

#%%
# Extract config data

# extract config data needed to make a server connection
server = config_dict['server']
port = config_dict['port']

#%% connect to the omero server and get the user's dataset IDs
# create the connection
conn = BlitzGateway(user_name, passwd, host=server, port=port)
connected = conn.connect()

# if not connected to omero
if not connected:
    # print an error message and exit
    sys.stderr.write(
        "Error: OMERO connection not available, please check your user name"
        " and password.\n")
    sys.exit(1)

def print_obj(obj, indent=0):
    """
    Helper method to display info about OMERO objects.
    Not all objects will have a "name" or owner field.
    """
    # print the available obj methods to see what data is available
    # print inspect.getmembers(obj, predicate=inspect.ismethod)
    print """%s%s:%s  Name:"%s" owner=%s date=%s description=%s""" % (
        " " * indent,
        obj.OMERO_CLASS,
        obj.getId(),
        obj.getName(),
        obj.getOwnerOmeName(),
        obj.getDate(),
        obj.getDescription())

# open the json output file name
with open(out_file_name, 'w') as out_file:
    # declare a list to hold all dataset data
    dataset_list = []

    # get the user id and group id
    my_exp_id = conn.getUser().getId()
    default_group_id = conn.getEventContext().groupId

    # for each project filtered by this user
    for project in conn.getObjects("Project", opts={'owner': my_exp_id,
                                                    'group': default_group_id,
                                                    'order_by': 'lower(obj.name)'}):
        # assert that the project is owned by the user
        assert project.getDetails().getOwner().id == my_exp_id

        # declare a dict to store the dataset info
        dataset_dict = {}

        # for each dataset in the project
        for dataset in project.listChildren():
            # store select dataset data in a dict
            dataset_id = "%s" % dataset.getId()
            dataset_dict['dataset_id'] = dataset_id

            dataset_dict['dataset_name'] = dataset.getName()

            dataset_date = "%s" % dataset.getDate().strftime("%d-%b-%Y (%H:%M:%S.%f)")
            dataset_dict['date'] = dataset_date

            dataset_dict['description'] = dataset.getDescription()

            dataset_dict['owner'] = dataset.getOwnerOmeName()

            # add the dataset dict to the dataset list
            dataset_list.append(dataset_dict)

    # write the dataset list to a json file
    json.dump(dataset_list, out_file)
