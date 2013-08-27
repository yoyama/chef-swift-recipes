#
# Cookbook Name:: saio_pkg
# Recipe:: postprocess
#
include_recipe "python::pip"

execute "restart rsync" do
  command "service rsync restart"
  user "root"
  group "root"
end

execute "restart memcached" do
  command "service memcached restart"
  user "root"
  group "root"
end

execute "restart rsyslog" do
  command "service rsyslog restart"
  user "root"
  group "root"
end

execute "restart rabbitmq-server" do
  command "service rabbitmq-server restart"
  user "root"
  group "root"
end


execute "restart swift" do
  command "/usr/bin/swift-init all restart || /usr/bin/swift-init all restart"
  user "root"
end

execute "restart keystone" do
  command "service keystone restart"
  user "root"
end

%w{ceilometer-collector ceilometer-agent-central ceilometer-agent-compute ceilometer-api }.each do |service|
  execute "restart #{service}" do
    command "service #{service} restart"
    user "root"
  end
end

ks_auth_host_external = node[:keystone][:ks_auth_host_external]

template "/root/openstack_rc" do
  source "openstack_rc.erb"
  mode "0644"
  owner "root"
  group "root"
  variables( {
              :user => "admin",
              :tenant => "demo",
              :password => node[:keystone][:ks_admin_user_pass],
              :auth_url => "http://#{ks_auth_host_external}:5000/v2.0"
            } )
end

