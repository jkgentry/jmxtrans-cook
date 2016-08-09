#
# Cookbook Name:: jmxtrans
# Recipe:: default
#
# Copyright 2015, Biju Nair & Contributors
#
# Apache 2.0 license

case node['platform_family']
when 'debian'
    # init_script_file = 'jmxtrans.init.deb.erb'
when 'rhel'
    remote_file "#{Chef::Config[:file_cache_path]}/jmxtrans.rpm" do
        source 'http://central.maven.org/maven2/org/jmxtrans/jmxtrans/254/jmxtrans-254.rpm'
        action :create
    end

    rpm_package 'jmxtrans' do
        source "#{Chef::Config[:file_cache_path]}/jmxtrans.rpm"
        action :install
        allow_downgrade true
    end
end

template "#{node['jmxtrans']['json_dir']}/set1.json" do
    source 'set1.json.erb'
    owner node['jmxtrans']['user']
    group node['jmxtrans']['user']
    mode  '0755'
    notifies :restart, 'service[jmxtrans]', :delayed
    variables(
        servers: node['jmxtrans']['servers']
    )
end

poise_service service do
    user node['jmxtrans']['user']
    command "export JSON_DIR=#{node['jmxtrans']['json_dir']} && export LOG_DIR=#{node['jmxtrans']['log_dir']} sh #{node['jmxtrans']['home']} start"
    service_name 'jmxtrans'
end
