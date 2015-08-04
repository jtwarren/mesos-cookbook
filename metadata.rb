name             'et_mesos'
maintainer       'EverTrue'
maintainer_email 'devops@evertrue.com'
license          'MIT'
description      'Installs/Configures mesos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.1'

supports         'ubuntu', '>= 14.04'
supports         'centos', '>= 6.6'

recipe           "et_mesos::default", "install mesos."
recipe           "et_mesos::mesosphere", "install mesos from mesosphere package."
recipe           "et_mesos::source", "install mesos from source(default recipe)."
recipe           "et_mesos::master",  "configure the machine as master."
recipe           "et_mesos::slave",   "configure the machine as slave."
recipe           "et_mesos::docker-executor", "install mesos-docker executor"

depends          'java'
depends          'python'
depends          'build-essential'
depends          'maven'
depends          'ulimit'
depends          'apt'
depends          'yum'

suggests         'docker'
suggests         'zookeeper'

attribute           "mesos/type",
  :recipes       => ["et_mesos::source", "et_mesos::mesosphere", "et_mesos::master", "et_mesos::slave"],
  :display_name  => "installation type",
  :description   => "Value should be 'source' | 'mesosphere'.",
  :default       => "source"

attribute           "mesos/version",
  :recipes       => ["et_mesos::source", "et_mesos::mesosphere"],
  :display_name  => "Version to be installed.",
  :description   => "branch name or tag name at http://github.com/apache/mesos, or mesos's version name",
  :default       => "0.22.1"

attribute           "mesos/mesosphere/with_zookeeper",
  :recipes       => ["et_mesos::mesosphere"],
  :display_name  => "switch for installing zookeeper packages",
  :description   => "if true, zookeeper packages will be installed with mesosphere's mesos package",
  :default       => "false"

attribute           "mesos/prefix",
  :recipes       => ["et_mesos::source", "et_mesos::master", "et_mesos::slave"],
  :display_name  => "Prefix value to be passed to configure script",
  :description   => "prefix value to be passed to configure script",
  :default       => "/usr/local"

attribute           "mesos/home",
  :recipes       => ["et_mesos::source"],
  :display_name  => "mesos home directory",
  :description   => "directory which mesos sources are extracted to.",
  :default       => "/opt"

attribute           "mesos/build/skip_test",
  :recipes       => ["et_mesos::source"],
  :display_name  => "Flag whether test will be performed.",
  :description   => "if true, test will be skipped.",
  :default       => "true"

attribute           "mesos/ssh_opts",
  :recipes       => ["et_mesos::master"],
  :display_name  => "ssh options",
  :description   => "passed to be mesos-deploy-env.sh",
  :default       => "-o StrictHostKeyChecking=no -o ConnectTimeout=2"

attribute           "mesos/deploy_with_sudo",
  :recipes       => ["et_mesos::master"],
  :display_name  => "Flag whether sudo will be used in mesos deploy scripts",
  :description   => "Flag whether sudo will be used in mesos deploy scripts",
  :default       => "1"

attribute           "mesos/cluster_name",
  :recipes       => ["et_mesos::master"],
  :display_name  => "cluster name",
  :description   => "[OBSOLETE] Human readable name for the cluster, displayed at webui"

attribute           "mesos/master_ips",
  :recipes       => ["et_mesos::master"],
  :display_name  => "IP list of masters",
  :description   => "used in mesos-start/stop-cluster scripts."

attribute           "mesos/slave_ips",
  :recipes       => ["et_mesos::master"],
  :display_name  => "IP list of slaves",
  :description   => "used in mesos-start/stop-cluster scripts."

attribute           "mesos/slave/master_url",
  :required      => "required",
  :recipes       => ["et_mesos::slave"],
  :display_name  => "master url",
  :description   => "[OBSOLETE] Use mesos/slave/master.  mesos master url. this should  be host:port for non-ZooKeeper based masters, otherwise a zk:// or file://."
