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

template "/etc/swift/swift.conf" do
  source "swift.conf.erb"
  mode "0644"
  owner node[:swift][:user]
  group node[:swift][:group]
  variables( {
               :hash_path_suffix => node[:swift][:hash_path_suffix]
             })
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


%w{/etc/swift /var/run/swift}.each do |dir|
  directory dir do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end
end

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

service "swift-proxy" do
  action [ :disable, :stop ]
end


