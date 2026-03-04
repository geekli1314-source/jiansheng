import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/bluetooth_service.dart' as app;

class DeviceScanPage extends StatelessWidget {
  const DeviceScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Get.put(app.BluetoothService());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bluetooth Devices',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (bluetoothService.isScanning.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B8EFF)),
                  ),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF6B8EFF)),
              onPressed: () => bluetoothService.startScan(),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          _buildStatusCard(bluetoothService),
          Expanded(
            child: Obx(() {
              if (bluetoothService.scannedDevices.isEmpty) {
                return _buildEmptyState(bluetoothService);
              }
              return _buildDeviceList(bluetoothService);
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (bluetoothService.isScanning.value) {
          return FloatingActionButton.extended(
            onPressed: () => bluetoothService.stopScan(),
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.stop, color: Colors.white),
            label: const Text('Stop Scan', style: TextStyle(color: Colors.white)),
          );
        }
        return FloatingActionButton.extended(
          onPressed: () => bluetoothService.startScan(),
          backgroundColor: const Color(0xFF6B8EFF),
          icon: const Icon(Icons.search, color: Colors.white),
          label: const Text('Scan Devices', style: TextStyle(color: Colors.white)),
        );
      }),
    );
  }

  Widget _buildStatusCard(app.BluetoothService service) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final isConnected = service.connectedDevice.value != null;
        final statusColor = isConnected
            ? Colors.green
            : service.isScanning.value
                ? const Color(0xFF6B8EFF)
                : Colors.grey;

        return Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Connected Device' : 'Bluetooth Status',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.connectionStatus.value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isConnected ? Colors.green : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isConnected)
              TextButton(
                onPressed: () => service.disconnect(),
                child: const Text(
                  'Disconnect',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(app.BluetoothService service) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              FontAwesomeIcons.bluetoothB,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            service.isScanning.value ? 'Scanning for devices...' : 'No Bluetooth devices found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.isScanning.value
                ? 'Make sure the device is on and discoverable'
                : 'Tap the scan button to search for nearby devices',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(app.BluetoothService service) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: service.scannedDevices.length,
      itemBuilder: (context, index) {
        final device = service.scannedDevices[index];
        final deviceName = service.getDeviceName(device);
        final isConnecting = service.isConnecting.value &&
            service.connectedDevice.value?.remoteId == device.remoteId;
        final isConnected = service.connectedDevice.value?.remoteId == device.remoteId;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isConnected
                ? Border.all(color: Colors.green.withOpacity(0.5), width: 1.5)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isConnected
                    ? Colors.green.withOpacity(0.1)
                    : const Color(0xFF6B8EFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: isConnected ? Colors.green : const Color(0xFF6B8EFF),
                size: 22,
              ),
            ),
            title: Text(
              deviceName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isConnected ? Colors.green : Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                device.remoteId.str,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
            trailing: isConnecting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B8EFF)),
                    ),
                  )
                : isConnected
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 20,
                      ),
            onTap: isConnecting || isConnected
                ? null
                : () => _showConnectDialog(context, service, device),
          ),
        );
      },
    );
  }

  void _showConnectDialog(
    BuildContext context,
    app.BluetoothService service,
    BluetoothDevice device,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Connect Device',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Connect to "${service.getDeviceName(device)}"?',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              service.connectToDevice(device);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8EFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
