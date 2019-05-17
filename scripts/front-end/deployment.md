## Deployment of the React app
We take the serverless approach to deploy the React App. The app will be built as a static web page and then deployed to Amazon S3. Cloudfont enables https connection (optional).

### Install dependencies
In the project direcotry:
Install dependencies by command:
```
npm install
```
### Config the API server address
At the root of project directory, there is a file "**.env**" contains the settings of API server. Update the server address accordingly before the following test and build steps.

### Test the app in development mode
Start the app in development mode by command:
```
npm start
```
visit the app at:
```
http://localhost:3000
```
or
```
http://the-server-ip:3000
```
You should see the page rendered.


### Build the App
- change into the project directory
- run command: 
```
npm run-script build
```
- a directory "build" will be generated

### Create a AWS S3 bucket for hosting the App
- login to your AWS console
- create a S3 bucket with all default settings. give it a name like "e599-front-end-deploy-test"
- Click the S3 bucket you just created, click "properties"
- Select the "Static Website hosting" --> use this bucket to host a website
- set index and error documents to "index.html", save the settings
- go to tab "Permisions" --> Public access settings
- set the following 4 config to **false**
    - Block new public bucket policies
    - Block public and cross-account access if bucket has public policies
    - Block new public ACLs and uploading public objects 
    - Remove public access granted through public ACLs 
- click on "Bucket Policy", paste the JSON config below:
  **Notice that you need to update the bucket name accordingly in the config**
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Give read access to public",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::e599-front-end-deploy-test/*"
        }
    ]
}
```
- Now your bucket is ready for public access

### Deploy you app to the S3 bucket
- Copy all the files under "build" to the S3 bucket
- Test the App by visiting the bitbucket address. Below is an example:
```
http://e599-front-end-deploy-test.s3-website.us-east-2.amazonaws.com
```

### Setup Cloudfont for https connection
This step is optional since user authentication is not implemented.
Detailed steps can be found here: 
```
https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-https-requests-s3/
```

### Use custom domain name for the App
We successfully implemented this step but it is optional. Detailed steps can be found here:
```
https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/CNAMEs.html
```

