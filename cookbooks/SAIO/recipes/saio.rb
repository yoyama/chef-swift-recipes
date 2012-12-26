#
# Cookbook Name:: saio
# Recipe:: saio
#

%w{apt-file ubuntu-cloud-keyring python-software-properties}.each do |pkg|
  package pkg do
    action :install
    options "--force-yes"
  end
end

execute "cloudarchive-add" do
  command "add-apt-repository 'deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/folsom main' && apt-get update && touch /var/lib/apt/added_cloud_archive"
  user "root"
  creates "/var/lib/apt/added_cloud_archive"
end

