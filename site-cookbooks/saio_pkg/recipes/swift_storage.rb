#
# Cookbook Name:: swift_storage
# Recipe:: saio_pkg
#
include_recipe "saio_pkg::pre_process"

%w{swift swift-account swift-container swift-object}.each do |pkg|
  package pkg do
    action :install
  end
end


directory "/srv" do
  owner "root"
  group "root"
  action :create
end

%w{/etc/swift /var/run/swift /srv/node /var/cache/swift}.each do |dir|
  directory dir do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end
end


template "/etc/rsyncd.conf" do
  source "rsyncd.conf.erb"
  mode "0644"
  owner "root"
  group "root"
  variables( {
               :user => node[:swift][:user],
               :group => node[:swift][:group],
               :storage_local_net_ip => node[:swift][:storage_local_net_ip]
             })
end

cookbook_file "/etc/default/rsync" do
  source "default-rsync"
end

template "/etc/swift/swift.conf" do
  source "swift.conf.erb"
  mode "0644"
  owner node[:swift][:user]
  group node[:swift][:group]
  variables( {
               :hash_path_suffix => node[:swift][:hash_path_suffix]
             })
end

log_facility = "LOG_LOCAL2"
%w{account container object}.each do |type|
  template "/etc/swift/#{type}-server.conf" do
    source "storage/#{type}-server.conf.erb"
    mode "0644"
    owner node[:swift][:user]
    group node[:swift][:group]
    variables( {
                 :storage_local_net_ip => node[:swift][:storage_local_net_ip],
                 :user => node[:swift][:user],
                 :log_facility => log_facility
             })
  end
end

execute "restart rsync" do
  command "service rsync restart"
  user "root"
  group "root"
end

execute "restart rsyslog" do
  command "service rsyslog restart"
  user "root"
  group "root"
end
