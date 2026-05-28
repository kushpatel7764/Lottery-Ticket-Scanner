import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var bluetooth: BluetoothManager

    var body: some View {
        Form {
            Section(header: Text("Bluetooth Status")) {
                HStack {
                    Image(systemName: bluetooth.connectionState.symbol)
                        .foregroundColor(bluetooth.connectionState.color)
                    Text(bluetooth.connectionState.label)
                        .foregroundColor(bluetooth.connectionState.color)
                        .fontWeight(.semibold)
                }

                if bluetooth.pendingCount > 0 {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.orange)
                        Text("\(bluetooth.pendingCount) barcode(s) waiting to deliver")
                            .foregroundColor(.orange)
                    }
                }
            }

            Section(header: Text("How to Connect")) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("On the Mac, open Terminal and run:", systemImage: "1.circle.fill")
                        .font(.subheadline.bold())
                    Text("python bluetooth_bridge.py")
                        .font(.system(.caption, design: .monospaced))
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(6)

                    Label("The script will automatically discover and connect to this iPhone.", systemImage: "2.circle.fill")
                        .font(.subheadline)

                    Label("Once connected, every scan is typed directly into your lottery app — just like a real USB scanner.", systemImage: "3.circle.fill")
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("About")) {
                LabeledContent("Connection method", value: "Bluetooth LE (CoreBluetooth)")
                LabeledContent("Service UUID", value: "6E400001…")
                Text("No IP address or API key is required. The Mac bridge script handles discovery automatically.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}
