#!/bin/bash


sudo apt update

sudo apt install -y software-properties-common 

sudo add-apt-repository -y ppa:deadsnakes/ppa 

sudo apt install -y python3.7 

sudo apt install -y python3.7-venv

sudo apt install -y build-essential

sudo apt install -y libmysqlclient-dev

sudo apt update

sudo apt install -y python3.7-dev

python3.7 -m venv temp

source temp/bin/activate

pip install mysqlclient

pip install gunicorn

deactivate

