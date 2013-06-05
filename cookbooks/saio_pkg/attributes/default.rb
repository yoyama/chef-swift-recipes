default[:swift][:loopdevice] = true
default[:swift][:user] = "swift"
default[:swift][:group] = "swift"
default[:swift][:hash_path_suffix]= "TestTestTest"
default[:swift][:disk]= "sdb1"
default[:swift][:log_level]= "DEBUG"
default[:swift][:proxy_host]= "127.0.0.1"
default[:swift][:memcached_ips]= "127.0.0.1"
default[:swift][:cloudarchive_repo] = "grizzly"
default[:swift][:pkg_version] = "1.8.0-0ubuntu1~cloud0"
default[:swift][:client_pkg_version] = "1:1.3.0-0ubuntu1~cloud0"

default[:keystone][:pkg_version] = "1:2013.1-0ubuntu1.1~cloud0"
default[:keystone][:client_pkg_version] = "1:0.2.3-0ubuntu2~cloud0"
default[:keystone][:ks_auth_host_internal] = 'localhost'
default[:keystone][:ks_auth_host_external] = 'localhost'
default[:keystone][:ks_admin_token] = 'OpenStack'
default[:keystone][:ks_admin_user_pass] = 'abcd01234'
default[:keystone][:ks_service_user_pass] = 'ABCD01234'
default[:keystone][:ks_mysql_pass] = 'mysqlpass'
default[:keystone][:ks_mysql_ip] = 'localhost'
