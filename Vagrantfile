Vagrant.configure("2") do |config|
   servers=[
      {
         :hostname => "ldes-couS",
         :ip => "192.168.56.110",
         # :ssh_port => '2200'

      },
      {
         :hostname => "ldes-couSW",
         :ip => "192.168.56.111",
         # :ssh_port => '2400'
      }
   ]

   servers.each do |machine|
      config.vm.define machine[:hostname] do |node|
         node.vm.box = "bento/ubuntu-16.04"
         node.vm.hostname = machine[:hostname]
         node.vm.network :private_network, ip: machine[:ip]
         # node.vm.network "forwarded_port", guest: 22, host: machine[:ssh_port], id: "ssh"
         node.vm.provision :shell, path: "bootstrap.sh"
         node.vm.synced_folder '.', '/IOT'
         node.vm.provider "virtualbox" do |vb|
            vb.customize ["modifyvm", :id, "--memory", 1024]
            vb.customize ["modifyvm", :id, "--cpus", 1]
            vb.name = machine[:hostname]
            vb.gui = true
         end
      end
   end
end

#    # config.vm.box = "ubuntu/trusty64"
#    config.vm.synced_folder '.', '/IOT'
#    config.vm.hostname = $HOSTNAME

#    config.vm.network "private_network", ip: "192.168.57.3"
#    config.vm.provider "virtualbox" do |vb|
#       vb.customize ["modifyvm", :id, "--memory", 1024]
#       vb.customize ["modifyvm", :id, "--cpus", 1]
#       vb.name = "ldes-couS"
#       vb.gui = true
#    end
#    config.vm.provision :shell, path: "bootstrap.sh"
#       # control.vm.provision "shell", path: "control.sh"
#  end
 
