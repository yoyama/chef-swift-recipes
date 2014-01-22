#
# Cookbook Name:: swift_ring_dist
# Recipe:: saio_pkg
#

%w{account container object}.each do |type|
  cookbook_file "/etc/swift/#{type}.ring.gz" do
    source "ring/#{type}.ring.gz"
  end
  cookbook_file "/etc/swift/#{type}.builder" do
    source "ring/#{type}.builder"
  end
end


