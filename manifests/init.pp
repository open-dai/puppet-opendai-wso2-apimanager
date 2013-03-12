# Class: wso2api
#
# This module manages wso2api
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class wso2api (
  $db_host        = $wso2api::params::db_host,
  $db_name        = $wso2api::params::db_name,
  $db_user        = $wso2api::params::db_user,
  $db_password    = $wso2api::params::db_password,
  $product_name   = $wso2api::params::product_name,
  $download_site  = $wso2api::params::download_site,
  $admin_password = $wso2api::params::admin_password,
  $version        = '1.3.0',) inherits wso2api::params {
  $archive = "$product_name-$version.zip"
  $dir_bin = "/opt/wso2api-${version}/bin/"
  exec { "get-api-$version":
    cwd     => '/opt',
    command => "/usr/bin/wget ${download_site}${archive}",
    creates => "/opt/${archive}",
    require => Class['opendai_java'],
  #      subscribe => File['moodle_conf_dir'],
  }

  exec { "unpack-api-$version":
    cwd       => '/opt',
    command   => "/usr/bin/unzip ${archive}",
    creates   => "/opt/wso2api-$version",
    subscribe => Exec["get-api-$version"],
    require   => Package['unzip'],
  }

#  package { 'wso2greg':
#    ensure  => present,
#    require => Class['opendai_java'],
#  }

  # we'll need a DB and a user for the local and config stuff
  @@mysql::db { $db_name:
    user     => $db_user,
    password => $db_password,
    host     => $::fqdn,
    grant    => ['all'],
    tag      => 'new_soa_db',
  #    unless   => '/usr/bin/mysql -h ${db_host} -u ${db_user} -p${db_password} -NBe "show databases"',
  }

  file { "/opt/wso2api-$version/repository/components/lib/mysql-connector-java-5.1.22-bin.jar":
    source  => "puppet:///modules/wso2api/mysql-connector-java-5.1.22-bin.jar",
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }

  file { "/opt/wso2api-$version/repository/conf/datasources/master-datasources.xml":
    content => template('wso2api/master-datasources.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }

  file { "/opt/wso2api-$version/repository/conf/registry.xml":
    content => template('wso2api/registry.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }

  file { "/opt/wso2api-$version/repository/conf/user-mgt.xml":
    content => template('wso2api/user-mgt.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-api-$version"],
  }
  
  file { "/opt/wso2api-$version/bin/wso2server.sh":
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    require => Exec["unpack-api-$version"],
  }

  exec { 'setup-wso2api':
    cwd       => "/opt/wso2api-${version}/bin/",
    path => "/opt/wso2api-${version}/bin/:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
    environment => ["JAVA_HOME=/usr/java/default",],
    command   => "wso2server.sh -Dsetup",
    creates   => "/opt/wso2api-$version/repository/logs/wso2carbon.log",
    unless => "/usr/bin/test -s /opt/wso2api-$version/repository/logs/wso2carbon.log",
    logoutput => true,
    require   => [
      File["/opt/wso2api-$version/repository/conf/user-mgt.xml"],
      File["/opt/wso2api-$version/repository/conf/registry.xml"],
      File["/opt/wso2api-$version/bin/wso2server.sh"],
      File["/opt/wso2api-$version/repository/conf/datasources/master-datasources.xml"]],
  }
  
  file{'/etc/init.d/wso2api':
    ensure => link,
    owner   => 'root',
    group   => 'root',
    target => "/opt/wso2api-$version/bin/wso2server.sh",
    
  }


}
