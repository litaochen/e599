# pull omero server image version 5.3.5
FROM openmicroscopy/omero-server:5.3.5

# copy imaging workflow python scripts into the container
COPY python_scripts /omero_tools/python_scripts/

ENTRYPOINT ["python", "/omero_tools/python_scripts/get_file_list_from_dataset.py"]
