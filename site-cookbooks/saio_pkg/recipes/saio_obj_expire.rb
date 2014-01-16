#
# Cookbook Name:: saio_obj_expire
# Recipe:: saio_proxy
#
include_recipe "saio_pkg::pre_process"

package "swift" do
  action :install
end

%w{/etc/swift /var/run/swift}.each do |dir|
  directory dir do
    owner node[:swift][:user]
    group node[:swift][:group]
    action :create
  end
end

template "/etc/swift/object-expirer.conf" do
  source "object-expirer.conf.erb"
  mode "0644"
  owner node[:swift][:user]
  group node[:swift][:group]
  variables( {
               :hash_path_suffix => node[:swift][:hash_path_suffix]
             })
end
