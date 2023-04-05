#!/bin/bash

  #############################################################################

                        # Configuring Ec2 user data script #
  #############################################################################

                        cd /home/ec2-user/webapp
                        touch .env
                        echo "DB_USER=${DB_USER}" >> .env 
                        echo "DB_NAME=${DB_NAME}" >> .env
                        echo "DB_PORT=${DB_PORT}" >> .env
                        echo "APP_PORT=${APP_PORT}" >> .env
                        echo "DB_HOSTNAME=${DB_HOSTNAME}" >> .env
                        echo "DB_PASSWORD=${DB_PASSWORD}" >> .env
                        echo "AWS_BUCKET_NAME=${AWS_BUCKET_NAME}" >> .env

                        sudo systemctl start webapp
                        sudo systemctl status webapp
                        sudo systemctl enable webapp
                        sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/cloudwatch-config.json -s
