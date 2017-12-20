#
# Cookbook:: mylbr
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe "chef_nginx::default"
# include_recipe "hostsfile::default"

execute 'Update /etc/hosts with myapp1' do
  command "echo '5.5.5.2 apps1' >> /etc/hosts"
  not_if 'grep apps1 /etc/hosts'
end

execute 'Update /etc/hosts with myapp2' do
  command "echo '5.5.5.3 apps2' >> /etc/hosts"
  not_if 'grep apps2 /etc/hosts'
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  notifies :restart, 'service[nginx]'
end

service 'nginx' do
  action [:enable, :start]
end
