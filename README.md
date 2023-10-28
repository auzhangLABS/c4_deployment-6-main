# Deployment 6 Documentation

## Purpose:
The primary goal of deployment 6 is to familiarize ourselves with using the Jenkins agent to launch our AWS infrastructure using Terraform. Additionally, we would start utilizing an application load balancer to balance traffic between two instances. We would adopt the use of a shared relational database service (RDS), which allows consistent data to be shared with all the instances. This deployment challenges us to proactively address how to make our infrastructure highly available and scalable while ensuring data consistency across the infrastructure.

## Steps:
#### Establishing AWS Infrastructure using Terraform
I began by initiating a new workflow by branching out to `stage` in Git. From here, I used Terraform to create our first infrastructure, which created two instances in my default VPC. These instances consisted of:
- one with Jenkins, using [this user data](Jenkins user data)
- one with Terraform, using [this user data](terraform )

Here is how our first infrastructure was created with Terraform:
(insert first infrastructure here.)

In our Jenkins file, we utilized the Jenkins agent for specific stages in the deployment. View the [Jenkinfile](Jenkinsfile) to see how we create and connect to a Jenkin Agent, click [here!](https://github.com/auzhangLABS/c4_deployment5.1)

Then I began building the second infrastructure. Here, I used Terraform to create two VPCs - one in `us-east-1` and the other in `us-west-2`. Each VPC has:
-2 Availability Zones
-2 Public Subnets
-2 EC2 Instances
-1 Route Table
-1 Security Group with ports 22 and 8000 open for access

Each instance was configured with user data to install certain packages and configurations. Here is a detailed explanation:
- software-properties-common: manage software repositories from the command line.
- add-apt-repository -y ppa:deadsnakes/ppa: adding a Personal Package Archive with the newer version of Python that might not be available on Ubuntu.
- python3.7: Installing python 3.7 
- python3.7-venv: Set up a lightweight, isolated Python environment.
- build-essential: Installed the required tools for compiling and building software.
- libmysqlclient-dev: Provides the necessary files or library that are needed for Python to interact with MySQL. 
- python3.7-dev: Extend the capabilities of Python.<br>

Then enter the python virtual environment, and installed the following packages:
- pip install mysqlclient: Installs MySQL database driver for Python.
- pip install gunicorn: install Gunicorn web serverpackage.
 
To see the full data script, click [here!](deploy python .sh). After the instance is set up, you can check its status by checking each instance's IP to see if the banking application is working. See my example below:
[photo here]

#### Creating an RDS (Relational Database Service) database:
1. Access to AWS Amazon RDS:
   - Navigate to Amazon RDS
2. Start creating the database:
   - Click on Create Database -> MySQL -> Free Tier
3. Configure Database Setting:
   - Change DB instance identifier to `mydatabase`
   - Create your password
4. Additional Configuration:
   - Select `yes` for Public access
   - Enter `banking` into the Initial database name
   - Deselect encryption
5. Finalize
   - Create Database
6. Post-Database Configuration:
   - Update the DATABASE_URL in database.py, load_data.py, and app.py. 
   - The format is `mysql+mysqldb://admin:[my_password]@[endpoint_url]/[database_name]?charset=utf8mb4`, replace `my_password`, `endpoint_url`, and `database_name` with the information provided from the database.

#### Configuring AWS credentials in Jenkins
1. Access to Jenkins:
    - Navigate to Jenkins;
2. Access Credentials:
    - Manage Jenkins -> Click Credentials -> Click System -> Click Global credentials (unrestricted)
3. Adding Credentials:
    - Click Add Credentials -> Select Secret Text (from the dropdown):
      - Adding aws access key: Paste aws access key in secret ->  'AWS_ACCESS_KEY' into ID field -> 'aws access key' into description
      - Adding aws secret key: Paste aws access key in secret ->  'AWS_SECRET_KEY' into ID field -> 'aws secret key' into description

#### Run your Jenkins Pipeline
Please note: Make sure you destroy your second infrastructure previously set up for testing and deploying the application. <br>
We created a multibranch pipeline to execute the Jenkinsfile. Once it's successful, we have to double-check our infrastructure and our banking application on each instance.

#### Create a Security Group for the Application Load Balancer
Create a new Security Group that allows new inbound rules of HTTP of all Sources. Repeat for the other region.

#### Create a Load Balancer
1. Access AWS load balancing:
   - Navigate over the Target Groups under Load Balancing within EC2 instance menu.
2. Create Target Group:
   - Enter a `target group name` in the Target group name
   - Change the port to 8000
   - Choose the VPC you would like the ALB in.
   - In advanced health check settings:
     - Override Health check port to 8000
   - click next
   - In Register targets:
     - Choose the first instance and include it as pending below
   - Click Create target group
3. Repeat step 2 for the second instance as a target group.
4. Create an application load balancer:
   - Click on Create Load Balancer and choose Create an Application Load Balancer.
   - In Basic Configuration:
     - Enter a `load balancer name` in Load Balancer name.
     - Select the VPC you want the load balancer to be in.
     - Select subnets
     - Choose your security group
   - In Listeners and Routing:
     - Select an instance for the default instance.
     - Click Create a load balancer
   - View the Load balancer and wait until the status is Active then take the DNS name and go to the URL.
5. Adding another target group for the load balancer
   - Go to Listeners and Rules and click on the Listeners you would like to modify
   - click manage rule -> click edit rules
   - click on the listeners rules you would like to modify
   - click Actions  -> edit rules -> add target group
   - add another target group (instance 2). Here, the weight of traffic would be 50/50.
   - click save
6. Check the DNS name to verify the banking application works and repeat the process for the other region.

Please note: This was done in a new branch called stage. Once this was working, I merged it into the main

## System Design Diagram:
(System Design Diagram here)

To view the full system design diagram, click [here!](link to)

## Issues and Troubleshooting
During the setup of the 2nd infrastructure, I encountered a problem with the user data. Whenever I tried to attempt an operation like `git clone` it wouldn't execute. I fix this problem by providing the absolute path, like `/usr/bin/git`. This pattern held for other commands as well.


## Optimization
1. Application Load Balancer and Security Group: include the setup of ALB and new SG directly in the Terraform Script
2. Amazon Cloudfront: Incorporate a CDN for static files to reduce latency and reduce server stain
3. Network Load Balancer: Use a Network load balancer to distribute traffic to the application load balancer in different regions.
4. Ulitze NGINX: use NGINX as a front end to optimize request
5. Private Subnet: places application server and database in the private subnet to increase security
















