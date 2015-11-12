#!/bin/sh

install_python_environment () {
	sudo easy_install pip
	sudo pip install awscli
	sudo pip install coverage flake8 pyflakes virtualenv boto3
}