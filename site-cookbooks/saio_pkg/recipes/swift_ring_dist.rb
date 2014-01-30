#
# Cookbook Name:: swift_ring_dist
# Recipe:: saio_pkg
#

%w{account container object}.each do |type|
  cookbook_file "/etc/swift/#{type}.ring.gz" do
    source "ring/#{type}.ring.gz"
    mode "0644"
    owner node[:swift][:user]
    group node[:swift][:group]
  end
  cookbook_file "/etc/swift/#{type}.builder" do
    source "ring/#{type}.builder"
    mode "0644"
    owner node[:swift][:user]
    group node[:swift][:group]
  end
end


