#
# Cookbook Name:: init_database
# Recipe:: saio_pkg
#

include_recipe 'database::mysql'

mysql_connection_info = {
  :host => "localhost",
  :username => 'root',
  :password => ''
}

mysql_database_user "root" do
  connection mysql_connection_info
  password node['mysql']['server_root_password']
  database_name "my_app"
  privileges [:all]
  action [:create, :grant]
end

