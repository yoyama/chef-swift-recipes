#
# Cookbook Name:: saio_pkg
# Recipe:: mysql_postprocess
#
service "mysql" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

execute "restart mysql" do
  command "service mysql restart"
  user "root"
end

