# @summary Creates a DNS zone file
#
# This defined type creates a zone file for BIND DNS server
#
# @param zone_name
#   The name of the zone
# @param zone_data
#   Zone configuration data
#
# @example
#   dns::zone { 'example.com':
#     zone_data => { ... }
#   }
define dns::zone (
  Hash $zone_data,
) {
  $zone_name = $title
  $zone_type = $zone_data['type']
  $zone_file = "/etc/named/${zone_name}.zone"
  
  # Create the zone file using templates
  file { $zone_file:
    ensure  => file,
    owner   => 'named',
    group   => 'named',
    mode    => '0640',
    content => epp('dns/zone.epp', {
      'zone_name' => $zone_name,
      'zone_data' => $zone_data,
    }),
    notify  => Service['named'],
  }
} 
