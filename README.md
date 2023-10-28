# Deployment 6 Documentation

## Purpose:
The primary goal of deployment 6 is to familiarize ourselves with using the Jenkins agent to launch our AWS infrastructure using Terraform. Additionally, we would start utilizing an application load balancer to balance traffic between two instances. We would adopt the use of a shared relational database service (RDS), which allows consistent data to be shared with all the instances. This deployment challenges us to proactively address how to make our infrastructure highly available and scalable while ensuring data consistency across the infrastructure.

## Steps:
#### Establishing AWS Infrastructure using Terraform
I began by initiating a new workflow by branching out to `stage` in Git. From here, I used Terraform to create our first infrastructure, which created two instances in my default VPC. These instances comprised of:
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
1. Access to AWS Amazon EDS:
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






















