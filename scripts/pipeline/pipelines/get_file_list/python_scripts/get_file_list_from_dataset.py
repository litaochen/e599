#%% imports
import sys
import re
import inspect

# import the omero config dict
from omero_config_utils import get_json_config_dict

#%%
# Process command line args and finish imports

# command line arg constants
config_file_index = 1
dataset_id_index = 2
out_file_name_index = 3
user_name_index = 4
passwd_index = 5
num_expected_args = 6

if len(sys.argv) != num_expected_args:
    print "Usage: %s: <json config full path name> <dataset ID> <output file full path name> <user name> <passwd>" % sys.argv[0]
    sys.exit(1)

# get the args
config_file = sys.argv[config_file_index]
dataset_id = int(sys.argv[dataset_id_index])
out_file_name = sys.argv[out_file_name_index]
user_name = sys.argv[user_name_index]
passwd = sys.argv[passwd_index]

# print some useful log data
print "Using the following config file: %s" % config_file
print "Processing dataset ID: %s" % dataset_id
print "Writing output to file: %s" % out_file_name

# load the config dictionary
config_dict = get_json_config_dict(config_file)

# set up the python path
sys.path.append(config_dict['python_path'])
print "Adding the following to pythonpath: %s" % config_dict['python_path']

# import omero libs
from omero.gateway import BlitzGateway
import logging
logging.basicConfig()

#%%
# Extract config data

# extract config data needed to make a server connection
server = config_dict['server']
port = config_dict['port']

#%% connect to the omero server and generate the file list
# create the connection
conn = BlitzGateway(user_name, passwd, host=server, port=port)
connected = conn.connect()

# check the connection
if not connected:
    sys.stderr.write(
        "Error: OMERO connection not available, please check your user name"
        " and password.\n")
    sys.exit(1)

def print_obj(obj, indent=0):
    """
    Helper method to display info about OMERO objects.
    Not all objects will have a "name" or owner field.
    """
    print """%s%s:%s  Name:"%s" (owner=%s)""" % (
        " " * indent,
        obj.OMERO_CLASS,
        obj.getId(),
        obj.getName(),
        obj.getOwnerOmeName())

def get_channel(image):
    # get the file name
    file_name = image.getName()
    # print("file_name: %s" % file_name)

    # create a regex match string to extract the channel name
    match_string = ".*\(.* - ([a-zA-Z0-9]+)\)"

    # extract the channel from the file name
    match = re.match(match_string, file_name)

    if match:
        channel_name = match.groups()[0]
        # print(channel_name)
    else:
        channel_name = "None"
        print("Error: Did not find a channel match for file %s" % file_name)

    return channel_name

# create the omero url string for cell profiler
default_omero_url = "omero:iid="

# open the output file
with open(out_file_name, 'w') as out_file:
    # declare a list to hold all channel names
    master_channel_list = []

    # declare a list to hold the omero file urls
    url_list = []

    # for each image in the dataset
    for image in conn.getObjects('Image', opts={'dataset': dataset_id}):
        print_obj(image)

        # get the channel
        channel = get_channel(image)

        # add the channel to the master channel list
        master_channel_list.append(channel)

        # save the image channel and url
        master_channel_list.append(channel)

        # get the image id
        image_id = image.getId()

        # create and save the image url to the url list
        url = default_omero_url + str(image_id)
        url_list.append((url, channel, image_id))

    # get the unique channel list
    unique_channel_list = set(master_channel_list)
    print("unique_channel_list:", unique_channel_list)

    # get the unique number of channels
    num_channels = len(unique_channel_list)

    # sort the url_list by image id - sometimes omero returns images in a
    # dataset out of image id order
    image_id_index = 2
    url_list.sort(key=lambda tup: tup[image_id_index])
    print("url_list:")
    print(url_list)

    # verify that the first num_channels elements in the url_list are unique
    unique_sorted_channels = set(url_list[:num_channels])

    # count the number of unique channels from the sorted list
    num_unique_sorted_channels = len(unique_sorted_channels)

    # if the number of unique_sorted_channels != num expected
    if num_unique_sorted_channels != num_channels:
        print("Error - Number of channels != num expected channels")

    # set up for the csv file header loop
    count = 0
    channel_index = 1

    # print the csv file header
    # while the count is less than the number of channels
    while count < num_channels:
        # Print the csv channel header
        # Append a URL_ to the header or the cell profiler script will fail.
        # Note that we need to print from the master list because the master
        # list maintains the channel order. The channel set is only used
        # to obtain the channel count because the set doesn't maintain order.
        out_file.write("URL_%s" % url_list[count][channel_index])
        count = count + 1

        # prevent writing a trailing comma after the last channel
        if count < num_channels:
            out_file.write(",")

    # set up for processing the next section of the file
    out_file.write("\n")
    count = 1

    # sort the url list by image id

    # define the url index
    url_index = 0

    # for each url in the url list
    for tup in url_list:
        # write the url to the file
        out_file.write(tup[url_index])

        # if all the channels have been printed on this line
        if count % num_channels == 0:
            # advance to the next line and reset the counter
            out_file.write("\n")
            count = 1
        else:
            # write a comma and advance the counter
            out_file.write(",")
            count = count + 1
