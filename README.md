# 🌐 IP Networking Tool (Flutter + Dart Backend)

This project is a **Flutter-based frontend with a powerful Dart logic backend** to help users with **IP subnetting and bitwise networking operations**. Whether you're a network engineer, student, or curious about IP math, this tool visualizes and automates everything related to IP networks.

---

## ✨ Features

### ✅ IP Address & Binary Conversion
- Convert between **IPv4** and **binary** formats.

### ✅ CIDR & Subnet Mask Conversion
- Toggle between **CIDR** (e.g., `/24`) and **dotted-decimal** (e.g., `255.255.255.0`).

### ✅ LAN Subdivision
- **Manual Mode**: Split a network into a specified number of LANs.
- **Auto Mode**: Automatically generate as many `/30` (or smallest possible) subnets.

### ✅ Subnet Information
Each LAN includes:
- **Network Address**
- **Broadcast Address**
- **Usable IP Range**
- **CIDR Notation**
- **Subnet Mask**

### ✅ Bitwise Operations
- Choose `AND` or `OR` to apply between an IP and subnet mask, view:
  - **Binary Result**
  - **Resulting IP**

### ✅ Flexible IP Input Parsing
Supports:
- `IP/CIDR` → e.g. `192.168.1.0/24`  
- `IP,Netmask` → e.g. `192.168.1.0,255.255.255.0`  
- `IP Only` → e.g. `10.0.0.1` (defaults to `/24`)

### ✅ Flutter UI Features
- Clean material design
- History of previous operations
- Export results as CSV
- Automatic validation and correction
- LAN Table View with pagination (for many LANs)

---

## 🚀 How to Use

### 📱 Requirements
- Flutter SDK
- Dart 3.x
- Any Android/iOS emulator or physical device

### 🔧 Running the App

1. **Clone the repo:**

 
   git clone https://github.com/semedo-nob/ip-networking-tool.git
   cd ip-networking-tool
   
Get dependencies:


`flutter pub get`

Run the app:


`flutter run`

🧠 Example Use Case

=== IP Networking Tool ===

Enter IP: 192.168.1.0/26  
Parsed Network: 192.168.1.0/26 (Mask: 255.255.255.192)

Perform bitwise operation? (AND/OR/N): AND  
  Binary Result: 11000000101010000000000100000000  
  Resulting IP: 192.168.1.0

LAN Mode? (M for Manual, A for Auto): M  
Enter number of LANs to create: 2

LAN 1  
  Network Address : 192.168.1.0  
  Broadcast Addr  : 192.168.1.31  
  Usable IPs      : 192.168.1.1 - 192.168.1.30  
  CIDR Notation   : /27  
  Subnet Mask     : 255.255.255.224  

LAN 2  
  Network Address : 192.168.1.32  
  Broadcast Addr  : 192.168.1.63  
  Usable IPs      : 192.168.1.33 - 192.168.1.62  
  CIDR Notation   : /27  
  Subnet Mask     : 255.255.255.224  
📤 Export Options
Save results as .csv or .pdf for documentation or further analysis.

Share outputs from the app directly via email or file share.

💡 Roadmap
 IPv4 Support

 Manual/Auto LAN mode

 Export to CSV

 PDF export

 IPv6 support

 NAT translation simulator

 Binary mask editing

 Play Store deployment

🤝 Contributing
Pull requests are welcome. Please open an issue first to discuss your proposed change.

📜 License
MIT License © 2025 Nelson Apidi

🧩 Credits
Built using:

Flutter

Dart

Networking logic based on RFC 3021, RFC 4632
