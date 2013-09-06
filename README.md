# Sample chef cookbooks for OpenStack Swift

## cookbooks/saio_pkg

OpenStack Swift All in One with pre-Havana packages from CloudArchive for Ubuntu 12.04. 
You can install Swift, Keystone, Ceilometer in one server.

### How to install

    sudo apt-get install rubygems
    sudo apt-get install git
    sudo gem install chef
    sudo gem install librarian-chef
    sudo gem install  knife-solo
    git clone -b release04_havana+keystone+ceilometer git://github.com/yoyama/chef-swift-recipes.git
    cd chef-swift-recipes
    sudo knife solo cook <user>@localhost -i <ssh_private_key> -P <ssh_password> 2>&1 |tee /tmp/chef.log

If you want to customize, please check site-cookbooks/saio_pkg/attributes/default.rb

   
### How to use

    sudo cp /root/openstack_rc ~/
    . ~/openstack_rc
    swift stat -v
    ceilometer meter-list



