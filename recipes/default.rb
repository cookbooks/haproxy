
package "haproxy" do
  action :install
end

directory "/etc/haproxy" do
  action :create
  owner "root"
  group "root"
  mode 0755
end

directory "/var/log/haproxy" do
  action :create
  owner node[:haproxy][:user]
  group node[:haproxy][:user]
  mode 0750
end

directory "/var/run/haproxy" do
  action :create
  owner node[:haproxy][:user]
  group node[:haproxy][:user]
  mode 0750
end

remote_file "/etc/sysctl.d/20-ip-nonlocal-bind.conf" do
  source "20-ip-nonlocal-bind.conf"
  owner "root"
  group "root"
  mode 0644
end

node[:haproxy][:instances].each do |name, config|
  
  config[:listeners].each do |listener_name, listener_config|
    [ :options, :errorfiles, :backends ].each do |key|
      config[:listeners][listener_name][key] = Mash.new unless listener_config.has_key?(key)
    end
  end

  template "/etc/init.d/haproxy_#{name}" do
    source "haproxy.init.erb"
    variables(:name => name)
    owner "root"
    group "root"
    mode 0755
  end
  
  service "haproxy_#{name}" do
    pattern "haproxy.*#{name}"
    supports [ :start, :stop, :restart, :reload ]
    action [ :enable ]
  end

  template "/etc/haproxy/#{name}.cfg" do
    source "haproxy.cfg.erb"
    variables(:name => name, :config => config)
    owner node[:haproxy][:user]
    group node[:haproxy][:group]
    mode 0640
    notifies :reload, resources(:service => "haproxy_#{name}")
  end
end
