# React application with Express server

This project was bootstrapped with [Create React App](https://github.com/facebookincubator/create-react-app). Then an Express server was added in the `server` directory. The server is proxied via the `proxy` key in `package.json`.

## Using this project

1. Clone the project, change into the directory and install the dependencies. the application run on port 3000

   ```bash
   cd react-express-starter/server
   npm install
   npm start 
   ```

2. to run the server enter the server folder and run these commands 
    ```bash
   cd react-express-starter/frontend
   npm install
   npm start 

   ```

3. to run the test using pytest enter the test folder and run these commands 
    ```bash
   pip3 install -r reqirements.txt
   pytest test/test.py

   ```

4. Build 2 docker files one for the servert the other for the fronend

5. build a ci pipeline in jenkins to serve the application run it and and run the tests using pytest 

6. using jenkins build a terraform cd to build 2 ec2 instances in aws  and run the the first docker image into it and the other docker image to the second application

## make sure that all the vpc are confiured and works 
