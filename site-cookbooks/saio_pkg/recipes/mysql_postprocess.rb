#
# Cookbook Name:: saio_pkg
# Recipe:: mysql_postprocess
#
execute "restart mysql" do
  command "service mysql restart"
  user "root"
end

