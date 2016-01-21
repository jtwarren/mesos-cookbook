#
# Cookbook Name:: et_mesos
# Recipe:: master
#

include_recipe 'et_mesos::default'

service 'mesos-master' do
  provider Chef::Provider::Service::Upstart
  supports restart: true, reload: true
  action :nothing
end

deploy_dir = node['et_mesos']['deploy_dir']

directory deploy_dir do
  recursive true
end

unless node['et_mesos']['master']['zk']
  fail "node['et_mesos']['master']['zk'] is required to configure mesos-master."
end

unless node['et_mesos']['master']['quorum']
  fail "node['et_mesos']['master']['quorum'] is required to configure " \
       'mesos-master.'
end

# configuration files for mesos-[start|stop]-cluster.sh provided
# by both source and mesosphere
template "#{deploy_dir}/masters"

template "#{deploy_dir}/agents"

template "#{deploy_dir}/mesos-deploy-env.sh"

# configuration files for mesos-daemon.sh provided by both source and mesosphere
template "#{deploy_dir}/mesos-master-env.sh" do
  notifies :reload,  'service[mesos-master]'
  notifies :restart, 'service[mesos-master]'
end

template '/etc/init/mesos-master.conf' do
  source "upstart.conf.for.#{node['et_mesos']['type']}.erb"
  variables init_state: 'start', role: 'master'
  notifies :reload, 'service[mesos-master]'
end

# configuration files for service scripts(mesos-init-wrapper) by mesosphere
# package.
if node['et_mesos']['type'] == 'mesosphere'
  # these template resources don't notify service resource because
  # changes of configuration can be detected in mesos-master-env.sh
  template '/etc/mesos/zk' do
    source 'etc-mesos-zk.erb'
    variables(zk: node['et_mesos']['master']['zk'])
  end

  template '/etc/default/mesos' do
    source 'etc-default-mesos.erb'
    variables(log_dir: node['et_mesos']['master']['log_dir'])
  end

  template '/etc/default/mesos-master' do
    source 'etc-default-mesos-master.erb'
    variables(port: node['et_mesos']['master']['port'])
  end

  directory '/etc/mesos-master' do
    recursive true
  end

  # TODO: Refactor this to be idempotent, or have a guard - jeffbyrnes
  execute 'rm -rf /etc/mesos-master/*'

  node['et_mesos']['master'].each do |key, val|
    next if %w(zk log_dir port).include? key
    next if val.nil?
    if val.respond_to? :to_path_hash
      val.to_path_hash.each do |path_h|
        attr_path = "/etc/mesos-master/#{key}"

        directory attr_path

        file "#{attr_path}/#{path_h['path']}" do
          content "#{path_h['content']}\n"
        end
      end
    else
      file "/etc/mesos-master/#{key}" do
        content "#{val}\n"
      end
    end
  end
end
