#!/bin/bash

###############################
# Install RabbitMQ
###############################

sudo apt-get -y install rabbitmq-server

# create a very simple config file that allows guest users to connect remotely
cat > /etc/rabbitmq/rabbitmq.config <<EOF
[{rabbit, [{loopback_users, []}]}].
EOF

#Set RabbitMQ to listen on port 5672
cat > /etc/rabbitmq/rabbitmq-env.conf <<EOF
RABBITMQ_NODE_PORT=5672
EOF

service rabbitmq-server restart
service rabbitmq-server status



