# Managing DNS Server with Puppet: Automation and Standardization

This module provides a comprehensive solution for deploying and managing BIND DNS servers using Puppet. It handles installation, configuration, zone management, and service deployment for reliable and scalable DNS infrastructure.

## Module Structure

The module follows standard Puppet structure:

```
dns/
├── README.md
├── manifests/
│   ├── init.pp        # Main class for DNS server management
│   ├── config.pp      # Configuration class for BIND settings
│   └── zone.pp        # Defined type for managing DNS zones
├── templates/
│   ├── named.conf.epp # Template for generating named.conf
│   └── zone.epp       # Template for generating zone files
└── data/
    └── dns_config.yaml # DNS configuration data
```

## Features

- **Dynamic Zone Management**: Easily add, update, or remove DNS zones
- **Forward and Reverse Zones**: Support for both forward and reverse DNS lookups
- **Forwarders Configuration**: Configure DNS forwarders for external domain resolution
- **Template-Based Configuration**: Standardized configurations using EPP templates
- **Data-Driven Architecture**: Leverage Hiera for flexible data management
- **Security Controls**: Proper permissions and security settings for DNS files

## Usage

### Basic Usage

To include the DNS module in your infrastructure:

```puppet
# Basic inclusion of the DNS module
include dns
```

### Advanced Usage Examples

#### DNS Server with Multiple Zones

```puppet
# In site.pp or another manifest
node 'dns-server.example.com' {
  include dns

  # Optional: If you need to define zones directly in Puppet code
  # instead of using Hiera (not recommended for most cases)
  dns::zone { 'example.org':
    zone_data => {
      'type'       => 'master',
      'ttl'        => '86400',
      'nameserver' => 'ns1.example.org',
      'email'      => 'admin.example.org',
      'serial'     => '2023031501',
      'refresh'    => '3600',
      'retry'      => '1800',
      'expire'     => '604800',
      'minimum'    => '86400',
      'ns_records' => ['ns1.example.org', 'ns2.example.org'],
      'a_records'  => {
        '@'    => '192.168.50.10',
        'ns1'  => '192.168.50.10',
        'ns2'  => '192.168.50.11',
        'www'  => '192.168.50.20',
        'mail' => '192.168.50.30',
      },
    },
  }
}
```

#### DNS High Availability Setup

For a DNS HA setup with primary and secondary servers:

```puppet
# Primary DNS server
node 'dns-primary.example.com' {
  class { 'dns':
    # Configuration specific to primary can be added here
  }
}

# Secondary DNS server
node 'dns-secondary.example.com' {
  class { 'dns':
    # Configuration specific to secondary can be added here
    # Secondary servers would typically use different Hiera data
    # defining zones as 'slave' type
  }
}
```

### Hiera Configuration Examples

#### Basic Configuration (common.yaml)

```yaml
---
dns::domain: 'example.com'
dns::networks:
  - '192.168.1.0/24'
  - '192.168.2.0/24'
dns::forwarders:
  - '8.8.8.8'
  - '8.8.4.4'
```

#### Zone Configuration (zones.yaml)

```yaml
---
dns::zones:
  'example.com':
    type: 'master'
    ttl: '86400'
    nameserver: 'ns1.example.com'
    email: 'admin.example.com'
    serial: '2023031501'
    refresh: '3600'
    retry: '1800'
    expire: '604800'
    minimum: '86400'
    ns_records:
      - 'ns1.example.com'
      - 'ns2.example.com'
    a_records:
      '@': '192.168.1.10'
      'ns1': '192.168.1.10'
      'ns2': '192.168.1.11'
      'www': '192.168.1.20'
      'mail': '192.168.1.30'
    cname_records:
      'ftp': 'www'
      'webmail': 'mail'
    mx_records:
      '10': 'mail'
      '20': 'mail2'
```

#### Reverse Zone Example (reverse_zones.yaml)

```yaml
---
dns::zones:
  '1.168.192.in-addr.arpa':
    type: 'master'
    ttl: '86400'
    nameserver: 'ns1.example.com'
    email: 'admin.example.com'
    serial: '2023031501'
    refresh: '3600'
    retry: '1800'
    expire: '604800'
    minimum: '86400'
    ns_records:
      - 'ns1.example.com'
      - 'ns2.example.com'
    ptr_records:
      '10': 'ns1.example.com.'
      '11': 'ns2.example.com.'
      '20': 'www.example.com.'
      '30': 'mail.example.com.'
```

#### Secondary DNS Server Configuration (secondary.yaml)

```yaml
---
dns::zones:
  'example.com':
    type: 'slave'
    master: '192.168.1.10'
  '1.168.192.in-addr.arpa':
    type: 'slave'
    master: '192.168.1.10'
```

### Common Use Cases

#### Configuring a Split-Horizon DNS

For environments that need different DNS responses for internal and external clients:

```yaml
# Internal view configuration
dns::views:
  internal:
    match_clients: ['192.168.0.0/16']
    zones:
      'example.com':
        type: 'master'
        a_records:
          'www': '192.168.1.20'
          'app': '192.168.1.25'

# External view configuration
  external:
    match_clients: ['any']
    zones:
      'example.com':
        type: 'master'
        a_records:
          'www': '203.0.113.20'
          'app': '203.0.113.25'
```

#### Managing DNSSEC

To enable and configure DNSSEC:

```yaml
dns::dnssec_enable: true
dns::dnssec_validation: 'auto'
dns::managed_keys_directory: '/etc/named/keys'

dns::zones:
  'example.com':
    dnssec_signed: true
    key_directory: '/etc/named/keys/example.com'
```

## Implementation Details

The module implements:

1. **Package Installation**: Installs the BIND DNS server package
2. **Configuration Management**: Generates named.conf from templates
3. **Zone Management**: Creates and manages zone files
4. **Service Management**: Ensures the DNS service is running and configured properly

### Customizing Zone Files

The default zone template provides standard SOA, NS, A, CNAME, MX, and PTR records. If you need to customize the zone template for special requirements:

1. Create your own template in your control repository's template directory
2. Override the template path in Hiera:

```yaml
dns::zone_template: 'site/dns/custom_zone.epp'
```

### Extending the Module

You can extend this module's functionality with:

1. **Custom Types**: Add support for SRV, TXT, or other record types
2. **Integration**: Connect with DHCP modules for dynamic DNS updates
3. **TSIG Keys**: Add secure update mechanisms for zones

## Requirements

- Puppet 6.x or higher
- Supported operating systems:
  - RHEL/CentOS 7, 8, 9
  - Debian 10, 11
  - Ubuntu 18.04, 20.04, 22.04

## Troubleshooting

Common issues and their solutions:

1. **Named Service Won't Start**: Check the zone file syntax with `named-checkzone`
2. **Zone Transfers Failing**: Verify TSIG keys and allow-transfer settings
3. **Resolution Issues**: Check forwarders and recursion settings

## License

Apache License 2.0 