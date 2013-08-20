#
# Cookbook Name:: saio_pkg
# Recipe:: ceilometer
#

package "mysql-server" do
  action :install
end

%w{python-software-properties python-mysqldb rabbitmq-server rabbitmq-erlang-client}.each do |pkg|
  package pkg do
    action :install
#    options "--force-yes"
  end
end

user "ceilometer" do
  action :create
end

group "ceilometer" do
  action :create
end

directory "/etc/ceilometer" do
  group "ceilometer"
  owner "ceilometer"
  recursive true
  action :create
end

directory "/var/lib/ceilometer" do
  group "ceilometer"
  owner "ceilometer"
  recursive true
  action :create
end

template "/etc/ceilometer/ceilometer.conf" do
  source "ceilometer.conf.erb"
  mode "0644"
  owner "ceilometer"
  group "ceilometer"
  variables( {
               :cm_service_user_pass => node[:keystone][:ks_service_user_pass],
               :cm_rpc_host => node[:ceilometer][:cm_rpc_host],
               :ks_auth_host_internal => node[:keystone][:ks_auth_host_internal],
               :cm_mysql_pass => node[:ceilometer][:cm_mysql_pass],
             })
end



include_recipe 'database::mysql'

mysql_connection_info = {
  :host => "localhost",
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database "ceilometer" do
  connection mysql_connection_info
  action :create
end

mysql_database_user "ceilometer" do
  connection mysql_connection_info
  password node[:ceilometer][:cm_mysql_pass]
  database_name "ceilometer"
  privileges [:all]
  action [:create, :grant]
end



cm_pkg_version = node[:ceilometer][:pkg_version]
cm_client_pkg_version = node[:ceilometer][:client_pkg_version]

%w{python-ceilometer ceilometer-common ceilometer-collector ceilometer-api ceilometer-agent-compute ceilometer-agent-central  }.each do |pkg|
  package pkg do
    action :install
    version "#{cm_pkg_version}"
    options "-o Dpkg::Options::=\"--force-confold\" --force-yes "
  end
end

package "python-ceilometerclient" do
  action :install
  version "#{cm_client_pkg_version}"
end

execute "restart rabbitmq-server" do
  command "service rabbitmq-server restart"
  user "root"
  group "root"
end
