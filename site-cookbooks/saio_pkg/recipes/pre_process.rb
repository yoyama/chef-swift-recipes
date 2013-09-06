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

%w{python-software-properties python-setuptools  xfsprogs python-pip}.each do |pkg|
  package pkg do
    action :install
  end
end

cloudarchive_repo = node[:swift][:cloudarchive_repo]
swift_pkg_version = node[:swift][:pkg_version]
client_pkg_version = node[:swift][:client_pkg_version]

execute "cloudarchive-add" do
  command "add-apt-repository 'deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/#{cloudarchive_repo} main' && apt-get update && touch /var/lib/apt/added_cloud_archive"
  user "root"
  creates "/var/lib/apt/added_cloud_archive"
end

