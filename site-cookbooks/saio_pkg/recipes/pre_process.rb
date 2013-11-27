#
# Cookbook Name:: saio_pkg
# Recipe:: pre_process
#
include_recipe "python::pip"

%w{apt-file ubuntu-cloud-keyring curl gcc git-core }.each do |pkg|
  package pkg do
    action :install
#    options "--force-yes"
  end
end

%w{python-software-properties python-setuptools python-coverage python-dev python-nose python-simplejson python-xattr python-eventlet python-greenlet python-pastedeploy python-netifaces python-pip sqlite3 xfsprogs }.each do |pkg|
  package pkg do
    action :install
  end
end

cloudarchive_repo = node[:openstack][:cloudarchive_repo]

execute "cloudarchive-add" do
  command "add-apt-repository 'deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/#{cloudarchive_repo} main' && apt-get update && touch /var/lib/apt/added_cloud_archive"
  user "root"
  creates "/var/lib/apt/added_cloud_archive"
end

python_pip "dnspython" do
  version "1.11.0"
  action :install
end

