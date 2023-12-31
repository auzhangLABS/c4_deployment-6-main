#!/bin/bash

sudo apt update

sudo apt install -y software-properties-common 

sudo add-apt-repository -y ppa:deadsnakes/ppa 

sudo apt install -y python3.7 

sudo apt install -y python3.7-venv

sudo apt install -y build-essential

sudo apt install -y libmysqlclient-dev

sudo apt install -y python3.7-dev

sudo apt update

/usr/bin/git clone https://github.com/auzhangLABS/c4_deployment-6-main.git /home/ubuntu/c4_deployment-6-main

cd /home/ubuntu/c4_deployment-6-main && /usr/bin/python3.7 -m venv /home/ubuntu/c4_deployment-6-main/test

source /home/ubuntu/c4_deployment-6-main/test/bin/activate

pip install mysqlclient

pip install gunicorn

pip install pip --upgrade

pip install -r requirements.txt

pip install gunicorn

python database.py

sleep 1

python load_data.py

sleep 1 

python -m gunicorn app:app -b 0.0.0.0 -D && echo "Done"

deactivate



