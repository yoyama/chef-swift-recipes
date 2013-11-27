#
# Cookbook Name:: saio_pkg
# Recipe:: saio_misc
#
include_recipe "saio_pkg::pre_process"

directory "/var/log/swift" do
  owner "syslog"
  group "adm"
  mode 0775
  action :create
end

directory "/var/log/swift/hourly" do
  owner "syslog"
  group "adm"
  mode 0775
  action :create
end

directory "/var/lib/swift/keystone-signing" do
  owner node[:swift][:user]
  group node[:swift][:group]
  mode 0775
  recursive true
  action :create
end

execute "update rsyslog.conf" do
  command "sed 's/$PrivDropToGroup syslog/$PrivDropToGroup adm/g' </etc/rsyslog.conf > /tmp/rsyslog.conf;cp /tmp/rsyslog.conf /etc/"
end

cookbook_file "/etc/rsyslog.d/10-swift.conf" do
  source "10-swift.conf"
end




