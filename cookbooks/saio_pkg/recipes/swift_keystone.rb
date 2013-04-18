#
# Cookbook Name:: saio_pkg
# Recipe:: keystone
#

package "mysql-server" do
  action :install
end

%w{python-software-properties python-mysqldb}.each do |pkg|
  package pkg do
    action :install
#    options "--force-yes"
  end
end

package "keystone" do
  action :install
  version "2012.2.1-0ubuntu1.3~cloud0"
end

package "python-keystoneclient" do
  action :install
  version "1:0.1.3-0ubuntu1.1~cloud0"
end

%w{memcached python-memcache}.each do |pkg|
  package pkg do
    action :install
#    options "--force-yes"
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
               :ks_mysql_ip => node[:keystone][:ks_mysql_ip]
             })
end

template "/etc/keystone/logging.conf" do
  source "keystone_logging.conf.erb"
  mode "0600"
  owner "keystone"
  group "keystone"
  variables( {
               :ks_admin_token => node[:keystone][:ks_admin_token],
               :ks_mysql_pass => node[:keystone][:ks_mysql_pass],
               :ks_mysql_ip => node[:keystone][:ks_mysql_ip]
             })
end

service "memcached" do
   supports :status => true, :start => true, :stop => true, :restart => true
   action [:enable]
end

keystone_init_dir="/tmp/keystone_init"
directory "#{keystone_init_dir}" do
  group "root"
  owner "root"
  recursive true
  action :create
end

%w{get_token.sh init_data.sh init_keystonedb.sh prepare_keystone.sql set_rootpasswd.sql .keystone_rc}.each do |pkg|
  template "#{keystone_init_dir}/#{pkg}" do
    source "keystone_init/#{pkg}.erb"
    mode "0700"
    owner "root"
    group "root"
    variables( {
               :swift_proxy_host => node[:swift][:proxy_host],
               :ks_auth_host_external => node[:keystone][:ks_auth_host_external],
               :ks_admin_user_pass => node[:keystone][:ks_admin_user_pass],
               :ks_service_user_pass => node[:keystone][:ks_service_user_pass],
               :ks_admin_token => node[:keystone][:ks_admin_token],
               :ks_mysql_pass => node[:keystone][:ks_mysql_pass]
             })
  end

end
