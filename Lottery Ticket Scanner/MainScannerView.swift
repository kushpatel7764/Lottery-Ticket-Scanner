import SwiftUI

struct MainScannerView: View {
    @State private var scannedCodes: [ScannedCode] = []
    @State private var showScanner = false

    var body: some View {
        NavigationView {
            VStack {
                Button(action: { showScanner = true }) {
                    Label("Start Scanning", systemImage: "barcode.viewfinder")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                List(scannedCodes) { code in
                    VStack(alignment: .leading) {
                        Text(code.value)
                            .font(.headline)
                        Text("Scanned at: \(code.time.formatted(.dateTime.hour().minute().second()))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Scanner")
            .fullScreenCover(isPresented: $showScanner) {
                ScannerCameraView(isPresented: $showScanner) { scannedCode in
                    scannedCodes.append(scannedCode)
                    // NetworkManager.sendBarcode(scannedCode.value)
                }
            }
        }
    }
}

struct ScannedCode: Identifiable {
    let id = UUID()
    let value: String
    let time: Date
}