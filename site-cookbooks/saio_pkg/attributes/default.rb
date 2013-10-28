default[:mysql][:server_root_password] = "rootpass"
default[:mysql][:server_debian_password] = "rootpass"
default[:mysql][:server_repl_password] = "rootpass"

default[:swift][:loopdevice] = true
default[:swift][:user] = "swift"
default[:swift][:group] = "swift"
default[:swift][:hash_path_suffix]= "TestTestTest"
default[:swift][:disk]= "sdb1"
default[:swift][:log_level]= "DEBUG"
default[:swift][:proxy_host]= "localhost"
default[:swift][:memcached_ips]= "localhost"
default[:swift][:cloudarchive_repo] = "havana"
#default[:swift][:pkg_version] = "1.9.0-0ubuntu1~cloud0"
#default[:swift][:client_pkg_version] = "1:1.5.0-0ubuntu1~cloud0"

#default[:keystone][:pkg_version] = "1:2013.2~b2-0ubuntu2~cloud1"
#default[:keystone][:client_pkg_version] = "1:0.3.1-0ubuntu1~cloud0"
default[:keystone][:ks_auth_host_internal] = 'localhost'
default[:keystone][:ks_auth_host_external] = 'localhost'
default[:keystone][:ks_admin_token] = 'OpenStack'
default[:keystone][:ks_admin_user_pass] = 'abcd01234'
default[:keystone][:ks_service_user_pass] = 'ABCD01234'
default[:keystone][:ks_mysql_pass] = 'mysqlpass'
default[:keystone][:ks_mysql_ip] = 'localhost'

#default[:ceilometer][:pkg_version] = "2013.2~b2-0ubuntu4~cloud0"
#default[:ceilometer][:client_pkg_version] = "1.0.1-0ubuntu2~cloud0"
default[:ceilometer][:cm_api_host] = 'localhost'
default[:ceilometer][:cm_rpc_host] = 'localhost'
default[:ceilometer][:cm_mysql_pass] = 'mysqlpass'


