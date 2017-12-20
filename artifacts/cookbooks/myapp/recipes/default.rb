#
# Cookbook:: myapp
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe "nodejs::default"

directory '/myapp' do
  owner 'root'
  group 'root'
  mode '0700'
end

template '/myapp/hello.js' do
  source 'hello.js.erb'
  owner 'root'
  group 'root'
  mode '0700'
end

template '/myapp/myapp.js' do
  source 'myapp.js.erb'
  owner 'root'
  group 'root'
  mode '0700'
  notifies :restart, 'service[myapp]'
end

template '/etc/init.d/myapp' do
  source 'init.d_myapp.erb'
  owner 'root'
  group 'root'
  mode '0750'
end

#execute 'node-autostart install' do
#   command 'npm install -g node-autostart'
#   not_if { ::File.exist?('/usr/bin/nodemon') }
# end

service 'myapp' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:enable, :start]
end

  
