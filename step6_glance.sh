#!/bin/bash

######################
# Chapter 2 GLANCE   #
######################

# Install Service
sudo apt-get update
sudo apt-get -y install glance
sudo apt-get -y install python-glanceclient

# Config Files
GLANCE_API_CONF=/etc/glance/glance-api.conf
GLANCE_REGISTRY_CONF=/etc/glance/glance-registry.conf

SERVICE_TENANT=service
GLANCE_SERVICE_USER=glance
GLANCE_SERVICE_PASS=glance

# Create database
MYSQL_ROOT_PASS=openstack
MYSQL_GLANCE_PASS=openstack
mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE glance;'
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$MYSQL_GLANCE_PASS';"
mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$MYSQL_GLANCE_PASS';"

## /etc/glance/glance-api.conf
echo "[DEFAULT]
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
bind_host = 0.0.0.0
bind_port = 9292
log_file = /var/log/glance/api.log
backlog = 4096
registry_host = 0.0.0.0
registry_port = 9191
registry_client_protocol = http
rabbit_host = localhost
rabbit_port = 5672
rabbit_use_ssl = false
rabbit_userid = guest
rabbit_password = guest
rabbit_virtual_host = /
rabbit_notification_exchange = glance
rabbit_notification_topic = notifications
rabbit_durable_queues = False

delayed_delete = False
scrub_time = 43200
scrubber_datadir = /var/lib/glance/scrubber
image_cache_dir = /var/lib/glance/image-cache/

[database]
backend = sqlalchemy
connection = mysql://glance:openstack@172.16.0.200/glance

[keystone_authtoken]
auth_uri = https://${KEYSTONE_ADMIN_ENDPOINT}:35357/v2.0/
identity_uri = https://${KEYSTONE_ADMIN_ENDPOINT}:5000
admin_tenant_name = ${SERVICE_TENANT}
admin_user = ${GLANCE_SERVICE_USER}
admin_password = ${GLANCE_SERVICE_PASS}
#signing_dir = \$state_path/keystone-signing
insecure = True

[glance_store]
filesystem_store_datadir = /var/lib/glance/images/
#stores = glance.store.swift.Store
#swift_store_auth_version = 2
#swift_store_auth_address = https://${ETH3_IP}:5000/v2.0/
#swift_store_user = service:glance
#swift_store_key = glance
#swift_store_container = glance
#swift_store_create_container_on_put = True
#swift_store_large_object_size = 5120
#swift_store_large_object_chunk_size = 200
#swift_enable_snet = False
#swift_store_auth_insecure = True

use_syslog = True
syslog_log_facility = LOG_LOCAL0

[paste_deploy]
config_file = /etc/glance/glance-api-paste.ini
flavor = keystone
" | sudo tee ${GLANCE_API_CONF}


## /etc/glance/glance-registry.conf

echo "[DEFAULT]
bind_host = 0.0.0.0
bind_port = 9191
log_file = /var/log/glance/registry.log
backlog = 4096
api_limit_max = 1000
limit_param_default = 25

rabbit_host = localhost
rabbit_port = 5672
rabbit_use_ssl = false
rabbit_userid = guest
rabbit_password = guest
rabbit_virtual_host = /
rabbit_notification_exchange = glance
rabbit_notification_topic = notifications
rabbit_durable_queues = False

[database]
sqlite_db = /var/lib/glance/glance.sqlite
backend = sqlalchemy
connection = mysql://glance:openstack@172.16.0.200/glance

[keystone_authtoken]
auth_uri = https://${KEYSTONE_ADMIN_ENDPOINT}:35357/v2.0/
identity_uri = https://${KEYSTONE_ADMIN_ENDPOINT}:5000
admin_tenant_name = ${SERVICE_TENANT}
admin_user = ${GLANCE_SERVICE_USER}
admin_password = ${GLANCE_SERVICE_PASS}
#signing_dir = \$state_path/keystone-signing
insecure = True

use_syslog = True
syslog_log_facility = LOG_LOCAL0

[paste_deploy]
config_file = /etc/glance/glance-registry-paste.ini
flavor = keystone
" | sudo tee ${GLANCE_REGISTRY_CONF}

sudo stop glance-registry
sudo start glance-registry
sudo stop glance-api
sudo start glance-api

sudo glance-manage db_sync

echo ">>>>>>>>>>>>>>>>> Uploading images to Glance. Please wait."

CIRROS="cirros-0.3.0-x86_64-disk.img"
UBUNTU="trusty-server-cloudimg-amd64-disk1.img"

if [[ ! -f /vagrant/${UBUNTU} ]]
then
# Download then store on local host for next time
  wget --quiet http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img -O /vagrant/${UBUNTU}
fi

# Warning: using  due to self-signed cert
glance  image-create --name='trusty-image' --disk-format=qcow2 --container-format=bare --public < /vagrant/kaixi/ISO/${UBUNTU}

echo ">>>>>>>>>>>>>>>>> Image upload done."

glance image-list




