# Run Server on Ubuntu (18.04)
* if you are running lower version of Ubuntu (i.e. 18.04) replace all mentions of 18.04 version with 18.04

## Install GIT:
$ sudo apt-get install git

## Update system:
$ sudo apt-get update

## Install clang:
$ sudo apt-get install clang libicu-dev libpython2.7

## Install libcurl:
$ sudo apt-get install libcurl4-openssl-dev

## Install openssl and libssl-dev
$ sudo apt-get install openssl
$ sudo apt-get install libssl-dev

## Install Swift binary:
$ wget https://swift.org/builds/swift-4.2.1-release/ubuntu1804/swift-4.2.1-RELEASE/swift-4.2.1-RELEASE-ubuntu18.04.tar.gz

## Import Swift's PGP Key:
$ gpg --keyserver hkp://pool.sks-keyservers.net \
--recv-keys \
'7463 A81A 4B2E EA1B 551F  FBCF D441 C977 412B 37AD' \
'1BE1 E29A 084C B305 F397  D62A 9F59 7F4D 21A5 6D5F' \
'A3BA FD35 56A5 9079 C068  94BD 63BC 1CFE 91D3 06C6' \
'5E4D F843 FB06 5D7F 7E24  FBA2 EF54 30F0 71E1 B235'

## Install Swift binary:
$ tar xzf swift-4.2.1-RELEASE-ubuntu18.04.tar.gz

## Add Swift path:
$ export PATH=swift-4.2.1-RELEASE-ubuntu18.04/usr/bin:"${PATH}"

## Add Swift path across system:
$ nano ~/.bashrc

Add the following line at the end of the file:
export PATH=swift-4.2.1-RELEASE-ubuntu18.04/usr/bin:"${PATH}"

## Test Swift installation:
$ swift

## Clone Server repo into local directory

## cd into project directory

## Run Swift Build:
$ swift build

Swift will pull down dependencines and compile Server app
App will be placed in debug directory listed by compiler

## cd into debug directory

## Run Server App:
$ ./Server

## Send request to Server:
- Open Firefox
- Go to localhost:8081/

## You should see Kitura welcome interface
