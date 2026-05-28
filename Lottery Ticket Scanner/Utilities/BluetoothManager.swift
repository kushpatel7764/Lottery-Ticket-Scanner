import CoreBluetooth
import SwiftUI
internal import Combine

class BluetoothManager: NSObject, ObservableObject {

    // These UUIDs identify our scanner service — must match bluetooth_bridge.py on the Mac
    static let serviceUUID     = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let barcodeCharUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

    enum ConnectionState {
        case bluetoothOff, advertising, connected

        var label: String {
            switch self {
            case .bluetoothOff: return "Bluetooth Off"
            case .advertising:  return "Waiting for Mac…"
            case .connected:    return "Mac Connected"
            }
        }
        var symbol: String {
            switch self {
            case .bluetoothOff: return "bluetooth.slash"
            case .advertising:  return "antenna.radiowaves.left.and.right"
            case .connected:    return "checkmark.circle.fill"
            }
        }
        var color: Color {
            switch self {
            case .bluetoothOff: return .red
            case .advertising:  return .orange
            case .connected:    return .green
            }
        }
    }

    @Published var connectionState: ConnectionState = .bluetoothOff
    @Published var pendingCount: Int = 0

    private var peripheralManager: CBPeripheralManager!
    private var barcodeChar: CBMutableCharacteristic?
    private var sendQueue: [String] = []
    private var isConnected = false

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
    }

    // Enqueue a barcode and attempt to deliver it immediately.
    // If the Mac is not yet connected the barcode waits in the queue and
    // is flushed automatically the moment the Mac subscribes.
    func sendBarcode(_ code: String) {
        sendQueue.append(code)
        pendingCount = sendQueue.count
        drainQueue()
    }

    private func drainQueue() {
        guard !sendQueue.isEmpty, let char = barcodeChar, isConnected else { return }

        guard let data = sendQueue[0].data(using: .utf8) else {
            sendQueue.removeFirst()
            pendingCount = sendQueue.count
            drainQueue()
            return
        }

        if peripheralManager.updateValue(data, for: char, onSubscribedCentrals: nil) {
            sendQueue.removeFirst()
            pendingCount = sendQueue.count
            drainQueue()
        }
        // updateValue returned false → BLE TX buffer is full.
        // peripheralManagerIsReady(toUpdateSubscribers:) will fire when space is available.
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            connectionState = .advertising
            setupService()
        } else {
            connectionState = .bluetoothOff
            isConnected = false
        }
    }

    private func setupService() {
        let char = CBMutableCharacteristic(
            type: BluetoothManager.barcodeCharUUID,
            properties: [.notify],
            value: nil,
            permissions: []
        )
        barcodeChar = char

        let service = CBMutableService(type: BluetoothManager.serviceUUID, primary: true)
        service.characteristics = [char]
        peripheralManager.add(service)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didAdd service: CBService,
                           error: Error?) {
        guard error == nil else { return }
        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [BluetoothManager.serviceUUID],
            CBAdvertisementDataLocalNameKey: "LotteryScanner"
        ])
    }

    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didSubscribeTo characteristic: CBCharacteristic) {
        isConnected = true
        connectionState = .connected
        drainQueue() // Deliver any barcodes that were scanned while offline
    }

    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didUnsubscribeFrom characteristic: CBCharacteristic) {
        isConnected = false
        connectionState = .advertising
    }

    // Called by CoreBluetooth when the TX buffer has room again after a full-buffer stall.
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        drainQueue()
    }
}
