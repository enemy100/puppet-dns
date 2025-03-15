# @summary Main DNS class to manage the DNS service
#
# This class handles the installation, configuration and service management
# for BIND DNS server
#
# @example
#   include dns
class dns {
  include dns::config

  package { 'bind':
    ensure => present,
  }

  service { 'named':
    ensure    => running,
    enable    => true,
    subscribe => [
      File['/etc/named.conf'],
      File['/etc/named'],
    ],
    require   => [
      Package['bind'],
      File['/etc/named.conf'],
    ],
  }
} 
