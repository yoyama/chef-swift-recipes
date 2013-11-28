#
# Cookbook Name:: saio_pkg
# Recipe:: keystone
#

%w{python-software-properties python-mysqldb}.each do |pkg|
  package pkg do
    action :install
  end
end

ks_pkg_version = node[:keystone][:pkg_version]
ks_client_pkg_version = node[:keystone][:client_pkg_version]

package "keystone" do
  action :install
end

package "python-keystoneclient" do
  action :install
end

%w{memcached python-memcache}.each do |pkg|
  package pkg do
    action :install
  end
end

template "/etc/keystone/keystone.conf" do
  source "keystone.conf.erb"
  mode "0600"
  owner "keystone"
  group "keystone"
  variables( {
               :ks_admin_token => node[:keystone][:ks_admin_token],
               :ks_mysql_pass => node[:keystone][:ks_mysql_pass],
               :ks_mysql_host => node[:keystone][:ks_mysql_host]
             })
end

template "/etc/keystone/logging.conf" do
  source "keystone_logging.conf.erb"
  mode "0600"
  owner "keystone"
  group "keystone"
  variables( {
             })
end

service "memcached" do
   supports :status => true, :start => true, :stop => true, :restart => true
   action [:enable]
end

keystone_init_dir="/root/keystone_init"
directory "#{keystone_init_dir}" do
  group "root"
  owner "root"
  recursive true
  action :create
end

#%w{get_token.sh init_data.sh init_keystonedb.sh prepare_keystone.sql set_rootpasswd.sql .keystone_rc}.each do |pkg|
%w{get_token.sh init_data.sh .keystone_rc}.each do |pkg|
  template "#{keystone_init_dir}/#{pkg}" do
    source "keystone_init/#{pkg}.erb"
    mode "0700"
    owner "root"
    group "root"
    variables( {
               :swift_proxy_host => node[:swift][:proxy_host],
               :cm_api_host => node[:ceilometer][:cm_api_host],
               :ks_auth_host_external => node[:keystone][:ks_auth_host_external],
               :ks_admin_user_pass => node[:keystone][:ks_admin_user_pass],
               :ks_service_user_pass => node[:keystone][:ks_service_user_pass],
               :ks_admin_token => node[:keystone][:ks_admin_token],
               :ks_mysql_pass => node[:keystone][:ks_mysql_pass]
             })
  end

end

include_recipe 'database::mysql'

mysql_connection_info = {
  :host => node[:keystone][:ks_mysql_host],
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

mysql_database "keystone" do
  connection mysql_connection_info
  action :create
end

mysql_database_user "keystone" do
  connection mysql_connection_info
  password node[:keystone][:ks_mysql_pass]
  database_name "keystone"
  privileges [:all]
  host '%'
  action [:create, :grant]
end

bash "init_keystone" do
  user "root"
  cwd "/root/keystone_init"
  code <<-EOF
service keystone restart
keystone-manage db_sync
  EOF
end

bash "install_keystone_data" do
  user "root"
  cwd "/root/keystone_init"
  code <<-EOF
./init_data.sh
  EOF
  not_if '. /root/keystone_init/.keystone_rc && keystone tenant-list | grep service'
end

