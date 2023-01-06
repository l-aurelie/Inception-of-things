Vagrant.configure("2") do |config|
   config.vm.box = "ubuntu/trusty64"
   # config.vm.url = "file://sgoinfre/goinfre/Perso/ldes-cou/ldes-couS.box"
   config.vm.synced_folder '.', '/IOT'
   config.vm.provider "virtualbox" do |vb|
      # vb.customize ["modifyvm", :id, "--name","ldes-couS"]
      vb.name = "ldes-couS"
      vb.memory = 1024
      # vb.check_guest_additions = false
      vb.cpus = 1
      vb.gui = true
      # override.vm.box_download_checksum_type
      # override.vm.box_download_checksum 
      # override.vm.box_url
   end
   config.vm.provision :shell, path: "bootstrap.sh"
      # control.vm.provision "shell", path: "control.sh"
 end
 
