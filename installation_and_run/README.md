# Installation_and_run

##Installation steps:
Create an AWS Ubuntu 18.04 instance: https://docs.aws.amazon.com/efs/latest/ug/gs-step-one-create-ec2-resources.html
For the most part you can use the default values, but you need to use the following values for these sections:

  - Instance type: t2.large or higher
  - Storage: up the size from 8 to 50
  - Set up ports as follows (image not yet provided)

Connect to AWS instance (instructions for doing so can be found by going to the list of EC2 instances, selecting the one you just created, and hitting the connect button).

Enter the following series of commands:

  - sudo apt-get install git (if git isn't installed)
  - sudo apt-get update
  - mkdir bitbucket
  - cd bitbucket

Clone the following directories (note: there is a possibility that `sudo` might be needed to clone the repos):

  - git clone https://ael664@bitbucket.org/harvardcapstone/installation_and_run.git (installation scripts)
  - git clone https://ael664@bitbucket.org/harvardcapstone/scripts.git (pipeline and front end)
  - git clone https://ael664@bitbucket.org/harvardcapstone/server.git (swift server and kitura)

The following variables need to be set to your EC2 instance IP to enable user interaction (note: there is a possibility that `sudo` might be needed to edit the files):

  - cd /home/ubuntu/bitbucket/scripts/front-end/
  - type `nano .env` and edit the `REACT_APP_API_SERVER` variable so that it is set to `http://<your EC2 instance IP>:8081`
  - cd /home/ubuntu/bitbucket/pipeline/config/
  - type `nano aws_config.json` and replace the IP address for the `server` variable with the IPv4 provided by your EC2 instance
  - cd /home/ubuntu/bitbucket/installation_and_run/
  - type `nano run` and edit the `OMEROHOST` line so that it is set to the IPv4 provided by your EC2 instance

Stay in the installation_and_run directory and exeute the following commands (note: there is a possibility at `sudo` might be needed to install and run):

  - ./install_system
  - sudo service mongodb start
  - enter `mongo` and then enter the following lines:
	- use imagingdb
	- db.createUser({user: 'harvard', pwd: 'crimson', roles: [{role: 'readWrite', db:'imagingdb'}]})
  - sudo service mongodb stop
  - type `sudo nano /etc/mongodb.conf`, uncomment `port`, comment out `bind_Ip`, and uncomment `auth=true` (see https://ianlondon.github.io/blog/mongodb-auth/ for more info)
  - ./start (IMPORTANT: while the docker is set up that it won't require a sudo command, this won't take effect until you disconnect from the EC2 instance for the first time. The `sudo` command will be required.)

At this point OMERO, PostgreSQL, and MongoDB will be up and running (can be verified with the commands in the section bellow). The swift server and React will not start up since both currently run in the foreground. To run both of them in the background, execute the following commands:

To run the swift server:

  - cd bitbucket/server/
  - screen -S swift_server
  - ./.build/x86_64-unknown-linux/debug/Server
  - Ctrl+A+D

To start React:

  - cd bitbucket/scripts/front-end/
  - screen -S swift_server
  - npm start
  - Ctrl+A+D
  - open a firefox/chrome browser with a CORS plugin (recomendation: allow-control-allow-origin plugin) and enter the following: <EC2 IP address>:3000

To deploy React so that is "serverles", please refer to the `deployment.md` file located in /home/ubuntu/bitbucket/scripts/front-end/ for setting up the S3 bucket.

##To check the status of MongoDB, Docker, Omero, and postgresql:

  - MongoDB: sudo systemctl status mongodb
  - Docker: sudo systemctl status docker
  - Status of what dockers are running (primarily Omero and postgresql): docker ps -a

##Default login OMERO:

The following username and password are provided to log into the system:

  - Username: root
  - Password: omero

##OMERO
###OMERO.insight download and installation:
Confirm the you have JRE version 1.7 or higher with `java -version`. If you don't, you can install from: http://www.oracle.com/technetwork/java/javase/downloads/indes.html

Go to https://downloads.openmicroscopy.org/omero/5.3.5/artifacts/ and download the OMERO.insight zip file for either Windows, Linux, or Mac. Move the zip file to a directory to your local file system and extract the contents.

  - Linux: open a terminal and `cd` into the new directory and enter `./OMEROinsight_unix.sh`
  - Windows: to install, go into the new directory and run either OMERO.importer.exe or OMERO.importer_64.exe. Once done you should be able to run OMERO.insight.
  - Mac: to install, go into the new directory and run the INSTALL app. Once done you should be able to run OMERO.insight*.

After OMERO.insight is installed, start it up and click on the wrench icon. Add a new server with the IP address of your EC2 instance. Leave the port number unchanged. Select the new server and set the connection speed to medium, and hit apply. Then use the unsername and password provided in the above section.

*There have been reported issues getting OMERO.insight to work for Mac.

###OMERO web
Open a browser and type <EC2 instance IP address>:4080 and login using the information provided in the `Default login OMERO` section above.
