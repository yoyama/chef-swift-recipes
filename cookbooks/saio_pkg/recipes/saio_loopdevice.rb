#
# Cookbook Name:: saio_pkg
# Recipe:: saio_loopdevice
#


disk_device = node[:swift][:disk]
disk_file = "/srv/swift-disk"
mnt_dir = "/mnt/#{disk_device}"

directory "#{mnt_dir}" do
  owner node[:swift][:user]
  group node[:swift][:group]
  action :create
end

if !FileTest.exists?(disk_file)
  execute "create" do
    command "truncate -s 1GB #{disk_file}"
    cwd "/srv"
  end

  execute "mkfs" do
    command "mkfs.xfs -i size=1024 #{disk_file}"
    cwd "/srv"
  end
  
  mount "#{mnt_dir}" do
    device "#{disk_file}"
    fstype "xfs"
    options "loop,noatime,nodiratime,nobarrier,logbufs=8"
    action [:mount, :enable]
  end
end
