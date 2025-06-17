import 'dart:math';

class IPv4Network {
  final String networkAddress;
  final String netmask;
  final int prefixlen;
  final String broadcastAddress;
  final List<String> hosts;

  IPv4Network(this.networkAddress, this.netmask, this.prefixlen, this.broadcastAddress, this.hosts);

  List<IPv4Network> subnets({required int newPrefix}) {
    if (newPrefix < prefixlen || newPrefix > 30) {
      throw Exception('Invalid new prefix for subnetting.');
    }
    final subnetCount = pow(2, newPrefix - prefixlen).toInt();
    final hostCount = pow(2, 32 - newPrefix).toInt();
    final networkOctets = networkAddress.split('.').map(int.parse).toList();
    final subnets = <IPv4Network>[];

    for (int i = 0; i < subnetCount; i++) {
      final subnetBase = _addToIp(networkOctets, i * hostCount);
      final subnetNetwork = _octetsToIp(subnetBase);
      final subnetBroadcast = _addToIp(subnetBase, hostCount - 1);
      final subnetHosts = _calculateHosts(subnetNetwork, subnetBroadcast as String, newPrefix);
      final subnetMask = _cidrToNetmask(newPrefix);
      subnets.add(IPv4Network(subnetNetwork, subnetMask, newPrefix, subnetBroadcast as String, subnetHosts));
    }
    return subnets;
  }
}

Map<String, dynamic> parseInput(String ipInput) {
  try {
    String ip;
    int cidr;
    String netmask;

    if (ipInput.contains('/')) {
      final parts = ipInput.split('/');
      ip = parts[0].trim();
      cidr = int.parse(parts[1].trim());
      netmask = _cidrToNetmask(cidr);
    } else if (ipInput.contains(',')) {
      final parts = ipInput.split(',').map((s) => s.trim()).toList();
      ip = parts[0];
      netmask = parts[1];
      cidr = _netmaskToCidr(netmask);
    } else {
      ip = ipInput.trim();
      cidr = 24; // Default CIDR
      netmask = _cidrToNetmask(cidr);
    }

    if (!_isValidIp(ip)) {
      throw Exception('Invalid IP address.');
    }
    if (!_isValidNetmask(netmask) && cidr < 0 || cidr > 32) {
      throw Exception('Invalid netmask or CIDR.');
    }

    final networkAddress = _calculateNetworkAddress(ip, netmask);
    final broadcastAddress = _calculateBroadcastAddress(networkAddress, cidr);
    final hosts = _calculateHosts(networkAddress, broadcastAddress, cidr);

    return {
      'network': IPv4Network(networkAddress, netmask, cidr, broadcastAddress, hosts),
      'network_address': networkAddress,
      'netmask': netmask,
      'prefixlen': cidr,
    };
  } catch (e) {
    throw Exception('Invalid input: $e');
  }
}

bool _isValidIp(String ip) {
  final octets = ip.split('.');
  if (octets.length != 4) return false;
  return octets.every((octet) {
    try {
      final value = int.parse(octet);
      return value >= 0 && value <= 255;
    } catch (_) {
      return false;
    }
  });
}

bool _isValidNetmask(String netmask) {
  final octets = netmask.split('.').map(int.parse).toList();
  if (octets.length != 4) return false;
  String binary = octets.map((o) => o.toRadixString(2).padLeft(8, '0')).join();
  return !binary.contains('01', binary.indexOf('0')); // Ensure contiguous 1s
}

String _cidrToNetmask(int cidr) {
  if (cidr < 0 || cidr > 32) throw Exception('Invalid CIDR.');
  final mask = (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;
  return _octetsToIp([
    (mask >> 24) & 0xFF,
    (mask >> 16) & 0xFF,
    (mask >> 8) & 0xFF,
    mask & 0xFF,
  ]);
}

int _netmaskToCidr(String netmask) {
  if (!_isValidNetmask(netmask)) throw Exception('Invalid netmask.');
  final binary = ipToBinary(netmask);
  return binary.split('').takeWhile((bit) => bit == '1').length;
}

String _calculateNetworkAddress(String ip, String netmask) {
  final ipOctets = ip.split('.').map(int.parse).toList();
  final maskOctets = netmask.split('.').map(int.parse).toList();
  final networkOctets = List.generate(4, (i) => ipOctets[i] & maskOctets[i]);
  return _octetsToIp(networkOctets);
}

String _calculateBroadcastAddress(String networkAddress, int cidr) {
  final networkOctets = networkAddress.split('.').map(int.parse).toList();
  final hostBits = 32 - cidr;
  final hostCount = pow(2, hostBits).toInt();
  final broadcastOctets = _addToIp(networkOctets, hostCount - 1);
  return _octetsToIp(broadcastOctets);
}

List<String> _calculateHosts(String networkAddress, String broadcastAddress, int cidr) {
  final networkOctets = networkAddress.split('.').map(int.parse).toList();
  final broadcastOctets = broadcastAddress.split('.').map(int.parse).toList();
  if (cidr >= 31) return []; // No usable IPs for /31 or /32
  final firstHost = _addToIp(networkOctets, 1);
  final lastHost = _addToIp(broadcastOctets, -1);
  return [_octetsToIp(firstHost), _octetsToIp(lastHost)];
}

List<int> _addToIp(List<int> octets, int increment) {
  final ipInt = (octets[0] << 24) + (octets[1] << 16) + (octets[2] << 8) + octets[3] + increment;
  return [
    (ipInt >> 24) & 0xFF,
    (ipInt >> 16) & 0xFF,
    (ipInt >> 8) & 0xFF,
    ipInt & 0xFF,
  ];
}

String _octetsToIp(List<int> octets) {
  return octets.join('.');
}

String ipToBinary(String ip) {
  if (!_isValidIp(ip)) throw Exception('Invalid IP address.');
  return ip.split('.').map((octet) {
    return int.parse(octet).toRadixString(2).padLeft(8, '0');
  }).join('');
}

String binaryToIp(String binary) {
  if (binary.length != 32) throw Exception('Invalid binary length.');
  final octets = <String>[];
  for (int i = 0; i < 32; i += 8) {
    octets.add(int.parse(binary.substring(i, i + 8), radix: 2).toString());
  }
  return octets.join('.');
}

Map<String, String> bitwiseOperation(String ip, String mask, String operation) {
  if (!_isValidIp(ip) || !_isValidNetmask(mask)) {
    throw Exception('Invalid IP or mask.');
  }
  final ipBin = ipToBinary(ip);
  final maskBin = ipToBinary(mask);
  String resultBin = '';

  if (operation == 'AND') {
    resultBin = List.generate(32, (i) => ipBin[i] == '1' && maskBin[i] == '1' ? '1' : '0').join();
  } else if (operation == 'OR') {
    resultBin = List.generate(32, (i) => ipBin[i] == '1' || maskBin[i] == '1' ? '1' : '0').join();
  } else {
    throw Exception('Invalid operation. Choose AND or OR.');
  }

  return {
    'binary': resultBin,
    'ip': binaryToIp(resultBin),
  };
}

List<Map<String, dynamic>> calculateLans(IPv4Network network, int? numLans) {
  try {
    if (numLans != null) {
      final newPrefix = network.prefixlen + (log(numLans) / log(2)).ceil();
      if (newPrefix > 30) {
        throw Exception('Too many LANs for given network size.');
      }
      final subnets = network.subnets(newPrefix: newPrefix);
      return subnets.map((subnet) {
        return {
          'network_address': subnet.networkAddress,
          'broadcast_address': subnet.broadcastAddress,
          'usable_ips': subnet.hosts.isNotEmpty ? '${subnet.hosts.first} - ${subnet.hosts.last}' : 'None',
          'prefixlen': subnet.prefixlen,
          'netmask': subnet.netmask,
        };
      }).toList();
    } else {
      final maxSubnets = pow(2, 30 - network.prefixlen).toInt();
      final subnets = network.subnets(newPrefix: 30).take(maxSubnets).toList();
      return subnets.map((subnet) {
        return {
          'network_address': subnet.networkAddress,
          'broadcast_address': subnet.broadcastAddress,
          'usable_ips': subnet.hosts.isNotEmpty ? '${subnet.hosts.first} - ${subnet.hosts.last}' : 'None',
          'prefixlen': subnet.prefixlen,
          'netmask': subnet.netmask,
        };
      }).toList();
    }
  } catch (e) {
    throw Exception('Error calculating subnets: $e');
  }
}