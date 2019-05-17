# import the json package
import json
import os

# create a default dictionary of omero config params
default_omero_config_dict = {'server': 'localhost',
                             'webhost': 'localhost',
                             'port': 4064,
                             'user': 'root',
                             'passwd': 'omero-root-password',
                             'python_path': '/home/wewilli1/omero/omero_server_py/lib/python'}

def create_json_config_file(json_config_file_name,
                            config_dict=default_omero_config_dict):
    # save the json config params
    with open(json_config_file_name, 'w') as json_config_file:
        json.dump(config_dict, json_config_file)

def test_create_jason_config_file():
    create_json_config_file()

def get_json_config_dict(json_config_file_name):
    with open(json_config_file_name) as config_file:
        return json.load(config_file)

def test_get_json_config_dict():
    print get_json_config_dict()

# test_create_jason_config_file()
# print test_get_json_config_dict()
