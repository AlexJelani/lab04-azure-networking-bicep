// ═══════════════════════════════════════════════════════════════════════════════
// main.bicep – Azure Lab 04: Virtual Networking
// Deploys: 2 VNets, 4 subnets, ASG, NSG, Public & Private DNS
// Author: [Your Name] – Future Azure DevOps Engineer
// ═══════════════════════════════════════════════════════════════════════════════

targetScope = 'resourceGroup'

param location string = 'eastus'

var coreVnetName = 'CoreServicesVnet'
var manufVnetName = 'ManufacturingVnet'

// ── CoreServicesVnet + Subnets ──────────────────────────────────────────────────
resource coreVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: coreVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.20.0.0/16' ] }
    subnets: [
      {
        name: 'SharedServicesSubnet'
        properties: { addressPrefix: '10.20.10.0/24' }
      }
      {
        name: 'DatabaseSubnet'
        properties: { addressPrefix: '10.20.20.0/24' }
      }
    ]
  }
}

// ── ManufacturingVnet + Subnets ─────────────────────────────────────────────────
resource manufVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: manufVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.30.0.0/16' ] }
    subnets: [
      {
        name: 'SensorSubnet1'
        properties: { addressPrefix: '10.30.20.0/24' }
      }
      {
        name: 'SensorSubnet2'
        properties: { addressPrefix: '10.30.21.0/24' }
      }
    ]
  }
}

// ── Application Security Group (ASG) ────────────────────────────────────────────
resource asg 'Microsoft.Network/applicationSecurityGroups@2023-05-01' = {
  name: 'asg-web'
  location: location
}

// ── Network Security Group (NSG) with Rules ─────────────────────────────────────
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'myNSGSecure'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowASG'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [ '80', '443' ]
          sourceApplicationSecurityGroups: [ { id: asg.id } ]
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyInternetOutbound'
        properties: {
          priority: 4096
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
  }
}

// Associate NSG to SharedServicesSubnet
resource nsgAssoc 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: coreVnet
  name: 'SharedServicesSubnet'
  properties: {
    addressPrefix: '10.20.10.0/24'
    networkSecurityGroup: { id: nsg.id }
  }
}

// ── Public DNS Zone + A Record ──────────────────────────────────────────────────
resource publicZone 'Microsoft.Network/dnszones@2018-05-01' = {
  name: 'contoso.com'
  location: 'global'
}

resource wwwRecord 'Microsoft.Network/dnszones/A@2018-05-01' = {
  parent: publicZone
  name: 'www'
  properties: {
    TTL: 3600
    ARecords: [ { ipv4Address: '10.1.1.4' } ]
  }
}

// ── Private DNS Zone + Link + A Record ──────────────────────────────────────────
resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'private.contoso.com'
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZone
  name: 'manufacturing-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: { id: manufVnet.id }
  }
}

resource sensorRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateZone
  name: 'sensorvm'
  properties: {
    TTL: 3600
    ARecords: [ { ipv4Address: '10.1.1.4' } ]
  }
}