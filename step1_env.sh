#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
echo "set grub-pc/install_devices /dev/sda" | debconf-communicate

export ETH1_IP=$(ifconfig eth1 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
export ETH2_IP=$(ifconfig eth2 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
export ETH3_IP=$(ifconfig eth3 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')

#export CONTROLLER_HOST=172.16.0.200
#Dynamically determine first three octets if user specifies alternative IP ranges.  Fourth octet still hardcoded
export CONTROLLER_HOST=$(ifconfig eth1 | awk '/inet addr/ {split ($2,A,":"); print A[2]}' | sed 's/\.[0-9]*$/.200/')
export GLANCE_HOST=${CONTROLLER_HOST}
export MYSQL_HOST=${CONTROLLER_HOST}
export KEYSTONE_ADMIN_ENDPOINT=$(ifconfig eth3 | awk '/inet addr/ {split ($2,A,":"); print A[2]}' | sed 's/\.[0-9]*$/.200/')
export KEYSTONE_ENDPOINT=${KEYSTONE_ADMIN_ENDPOINT}
export CONTROLLER_EXTERNAL_HOST=${KEYSTONE_ADMIN_ENDPOINT}
export MYSQL_ROOT_PASS=openstack
export MYSQL_DB_PASS=openstack
export MYSQL_NEUTRON_PASS=openstack
export SERVICE_TENANT_NAME=service
export SERVICE_PASS=openstack
export ENDPOINT=${KEYSTONE_ADMIN_ENDPOINT}
export SERVICE_TOKEN=ADMIN
export SERVICE_ENDPOINT=https://${KEYSTONE_ADMIN_ENDPOINT}:35357/v2.0
export MONGO_KEY=MongoFoo
export OS_CACERT=/etc/keystone/ssl/certs/ca.pem
export OS_KEY=/etc/keystone/ssl/certs/cakey.pem


# MySQL
export PUBLIC_IP=${ETH3_IP}
export INT_IP=${ETH1_IP}
export ADMIN_IP=${ETH3_IP}

export MYSQL_HOST=${ETH1_IP}
export MYSQL_ROOT_PASS=openstack
export MYSQL_DB_PASS=openstack



######################
# Chapter 1 KEYSTONE #
######################
export KEYSTONE_CONF=/etc/keystone/keystone.conf
export SSL_PATH=/etc/ssl/

export MYSQL_ROOT_PASS=openstack
export MYSQL_KEYSTONE_PASS=openstack

export ENDPOINT=${PUBLIC_IP}
export INT_ENDPOINT=${INT_IP}
export ADMIN_ENDPOINT=${ADMIN_IP}
export SERVICE_TOKEN=ADMIN
export SERVICE_ENDPOINT=https://${KEYSTONE_ADMIN_ENDPOINT}:35357/v2.0
export PASSWORD=openstack
export OS_CACERT=/etc/keystone/ssl/certs/ca.pem
export OS_KEY=/etc/keystone/ssl/certs/cakey.pem


######################
# Chapter 2 GLANCE   #
######################

export GLANCE_API_CONF=/etc/glance/glance-api.conf
export GLANCE_REGISTRY_CONF=/etc/glance/glance-registry.conf

export SERVICE_TENANT=service
export GLANCE_SERVICE_USER=glance
export GLANCE_SERVICE_PASS=glance

export MYSQL_ROOT_PASS=openstack
export MYSQL_GLANCE_PASS=openstack

export OS_USERNAME=admin
export OS_PASSWORD=openstack
export OS_TENANT_NAME=cookbook
export OS_AUTH_URL=https://${KEYSTONE_ENDPOINT}:5000/v2.0/


#if [[ "$(egrep CookbookHosts /etc/hosts | awk '{print $2}')" -eq "" ]]
#then
#	# Add host entries
#	echo "
## CookbookHosts
#192.168.100.200	controller.book controller
#192.168.100.201	network.book network
#192.168.100.202	compute-01.book compute-01
#192.168.100.203	compute-02.book compute-02
#192.168.100.210	swift.book swift
#192.168.100.212	swift2.book swift2
#192.168.100.211	cinder.book cinder" | sudo tee -a /etc/hosts
#fi

# Aliases for insecure SSL
# alias nova='nova --insecure'
# alias keystone='keystone --insecure'
# alias neutron='neutron --insecure'
# alias glance='glance --insecure'
# alias cinder='cinder --insecure'
