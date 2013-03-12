# === Class: moodle::params
#
#  The moodle configuration settings idiosyncratic to different operating
#  systems.
#
# === Parameters
#
# None
#
# === Examples
#
# None
#
# === Authors
#
# Lucsa Gioppo <gioppoluca@libero.it>
#
# === Copyright
#
# Copyright 2012 Luca Gioppo
#
class wso2api::params {

  $db_host            = "mysql_soa.$::domain"
  $db_name            = 'odaiapi'
  $db_user            = 'odaiapi'
  $db_password        = 'odaiapi1'
  $port_offset        = 0
  $download_site      = 'http://dist.wso2.org/products/governance-registry/'
  $product_name       = 'wso2esb'
  $admin_password       = 'odaiadmin1'
  
}
