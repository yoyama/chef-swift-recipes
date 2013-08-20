#!/bin/sh

/usr/bin/swift-init all stop
apt-get -y purge swift swift-proxy swift-account swift-container swift-object python-swift python-swiftclient
apt-get -y purge keystone python-keystoneclient
apt-get -y purge ceilometer python-ceilometerclient
apt-get -y purge mysql-server mysql-server-core-5.5 mysql-client mysql-common
apt-get -y purge rabbitmq-server rabbitmq-erlang-client
umount /srv/swift-disk
rm -rf /srv/
rm -rf /etc/swift/ /etc/ceilometer /etc/keystone
rm -rf /var/lib/ceilometer /var/lib/keystone /var/lib/swift
rm -rf /etc/mysql/ /etc/rabbitmq
rm -rf /var/lib/mysql /var/lib/rabbitmq
rm -rf /root/keystone_init


