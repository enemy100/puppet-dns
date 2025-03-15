# @summary Manages DNS server configuration
#
# This class handles the configuration of BIND DNS server
#
# @example
#   include dns::config
class dns::config {
  $domain = lookup('dns.domain', String, 'first', 'example.com')
  $networks = lookup('dns.networks', Array, 'unique', ['192.168.1.0/24'])
  $forwarders = lookup('dns.forwarders', Array, 'unique', ['8.8.8.8', '8.8.4.4'])
  $zones = lookup('dns.zones', Hash, 'deep', {})
  
  file { '/etc/named.conf':
    ensure  => file,
    owner   => 'named',
    group   => 'named',
    mode    => '0640',
    content => epp('dns/named.conf.epp', {
      'domain'     => $domain,
      'networks'   => $networks,
      'forwarders' => $forwarders,
      'zones'      => $zones,
    }),
    require => Package['bind'],
  }
  
  file { '/etc/named':
    ensure  => directory,
    owner   => 'named',
    group   => 'named',
    mode    => '0750',
    require => Package['bind'],
  }
  
  # Create all the zone files
  $zones.each |$zone_name, $zone_data| {
    dns::zone { $zone_name:
      zone_data => $zone_data,
      require   => File['/etc/named'],
    }
  }
} 
