#
# Cookbook Name:: saio_pkg
# Recipe:: saio_pkg
#
include_recipe "python::pip"

%w{apt-file ubuntu-cloud-keyring curl gcc git-core memcached }.each do |pkg|
  package pkg do
    action :install
#    options "--force-yes"
  end
end

%w{python-software-properties python-coverage python-dev python-nose python-setuptools python-simplejson python-xattr sqlite3 xfsprogs python-eventlet python-greenlet python-pastedeploy python-netifaces python-pip}.each do |pkg|
  package pkg do
    action :install
  end
end

python_pip "dnspython" do
  version "1.11.0"
  action :install
end

cloudarchive_repo = node[:swift][:cloudarchive_repo]
swift_pkg_version = node[:swift][:pkg_version]
client_pkg_version = node[:swift][:client_pkg_version]

execute "cloudarchive-add" do
  command "add-apt-repository 'deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/#{cloudarchive_repo} main' && apt-get update && touch /var/lib/apt/added_cloud_archive"
  user "root"
  creates "/var/lib/apt/added_cloud_archive"
end

package "swift" do
  action :install
  version "#{swift_pkg_version}"
end

package "python-swiftclient" do
  action :install
  version "#{client_pkg_version}"
end

package "swift-proxy" do
  action :install
  version "#{swift_pkg_version}"
end

package "swift-plugin-s3" do
  action :install
end


%w{swift-account swift-container swift-object}.each do |pkg|
  package pkg do
    action :install
    version  "#{swift_pkg_version}"
  end
end

directory "/srv" do
  owner "root"
  group "root"
  action :create
end

use_loopdevice = node[:swift][:loopdevice]
if use_loopdevice
  include_recipe "saio_pkg::saio_loopdevice"
end
  
disk = node[:swift][:disk]
mnt_dir = "/mnt/#{disk}"

for i in 1..4 do
  if i == 1
    v = ""
  else
    v = "#{i}"
  end

  directory "#{mnt_dir}/#{i}" do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end

  link "/srv/#{i}" do
    to "#{mnt_dir}/#{i}"
  end

  directory "/srv/#{i}/node/" do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end
  directory "/srv/#{i}/node/sdb#{i}" do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end
  directory "/srv/#{i}/node/sdb#{i}/objects" do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end

  directory "/var/cache/swift#{v}" do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end
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


template "/etc/rsyncd.conf" do
  source "rsyncd.conf.erb"
  mode "0644"
  owner "root"
  group "root"
  variables( {
               :user => node[:swift][:user],
               :group => node[:swift][:group]
             })
end

cookbook_file "/etc/default/rsync" do
  source "default-rsync"
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


%w{account-server container-server object-server}.each do |svrdir|
  directory "/etc/swift/#{svrdir}" do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end
end

for i in 1..4 do
  log_no = i+1
  if i == 1
    cache_no = ""
  else
    cache_no = "#{i}"
  end
  log_facility = "LOG_LOCAL#{log_no}"

  bind_port = 6002 + i*10
  template "/etc/swift/account-server/#{i}.conf" do
    source "account-server.conf.erb"
    mode "0644"
    owner node[:swift][:user]
    group node[:swift][:group]
    variables( {
                 :storage_no => i,
                 :bind_port => bind_port,
                 :user => node[:swift][:user],
                 :log_facility => log_facility,
                 :cache_no => cache_no
             })
  end

  bind_port = 6001 + i*10
  template "/etc/swift/container-server/#{i}.conf" do
    source "container-server.conf.erb"
    mode "0644"
    owner node[:swift][:user]
    group node[:swift][:group]
    variables( {
                 :storage_no => i,
                 :bind_port => bind_port,
                 :user => node[:swift][:user],
                 :log_facility => log_facility,
                 :cache_no => cache_no
             })
  end

  bind_port = 6000 + i*10
  template "/etc/swift/object-server/#{i}.conf" do
    source "object-server.conf.erb"
    mode "0644"
    owner node[:swift][:user]
    group node[:swift][:group]
    variables( {
                 :storage_no => i,
                 :bind_port => bind_port,
                 :user => node[:swift][:user],
                 :log_facility => log_facility,
                 :cache_no => cache_no
             })
  end

end

type2port_base = {
  "account" => 6002,
  "container" => 6001,
  "object" => 6000
}

%w{account container object}.each do |type|
  builder_file = "/etc/swift/#{type}.builder"
  if !FileTest.exists?(builder_file)
    execute "create ring file for #{type}" do
      command "swift-ring-builder #{type}.builder create 18 3 1"
      cwd "/etc/swift"
      user node[:swift][:user]
      group node[:swift][:group]
    end
    port_base = type2port_base[type]
    for i in 1..4 do
      port = port_base + i*10
      execute "add device z#{i} for #{type}" do
        command "swift-ring-builder #{type}.builder add z#{i}-127.0.0.1:#{port}/sdb#{i} 1"
        cwd "/etc/swift"
        user node[:swift][:user]
        group node[:swift][:group]
      end
    end
    execute "rebalance #{type}" do
      command "swift-ring-builder #{type}.builder rebalance"
      cwd "/etc/swift"
      user node[:swift][:user]
      group node[:swift][:group]
    end
  end
end

%w{account container object}.each do |type|
  file "/etc/swift/#{type}-server.conf" do
    action :delete
  end
end

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
