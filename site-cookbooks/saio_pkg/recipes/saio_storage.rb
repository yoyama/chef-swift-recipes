#
# Cookbook Name:: saio_storage
# Recipe:: saio_pkg
#
include_recipe "saio_pkg::pre_process"

%w{swift-account swift-container swift-object}.each do |pkg|
  package pkg do
    action :install
  end
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


directory "/srv" do
  owner "root"
  group "root"
  action :create
end

use_loopdevice = node[:saio][:loopdevice]
if use_loopdevice
  include_recipe "saio_pkg::saio_loopdevice"
end
  
disk = node[:saio][:loopdevice_disk]
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
      command "swift-ring-builder #{type}.builder create 12 3 1"
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

