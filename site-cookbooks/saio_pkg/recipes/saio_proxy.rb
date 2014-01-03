#
# Cookbook Name:: saio_pkg
# Recipe:: saio_proxy
#
include_recipe "saio_pkg::pre_process"

package "swift" do
  action :install
end

%w{/etc/swift /var/run/swift}.each do |dir|
  directory dir do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end
end

%w{memcached }.each do |pkg|
  package pkg do
    action :install
  end
end

package "python-swiftclient" do
  action :install
end

package "swift-proxy" do
  action :install
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

template "/etc/swift/proxy-server.conf" do
  source "proxy-server.conf.erb"
  mode "0644"
  owner node[:swift][:user]
  group node[:swift][:group]
  variables( {
               :user => node[:swift][:user],
               :proxy_host => node[:swift][:proxy_host],
               :log_level => node[:swift][:log_level],
               :memcached_ips => node[:swift][:memcached_ips],
               :ks_auth_host_internal => node[:keystone][:ks_auth_host_internal],
               :ks_admin_token => node[:keystone][:ks_admin_token]
             })
end

template "/etc/memcached.conf" do
  source "memcached.conf.erb"
  mode "0644"
  owner "root"
  group "root"
  variables( {
             })
end

directory "/var/lib/swift/keystone-signing" do
  owner node[:swift][:user]
  group node[:swift][:group]
  mode 0775
  recursive true
  action :create
end
