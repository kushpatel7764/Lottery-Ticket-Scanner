import SwiftUI
import UIKit

struct ScannerCameraView: View {
    @Binding var isPresented: Bool
    var onScan: (ScannedCode) -> Void

    @State private var showScanFeedback = false

    var body: some View {
        ZStack {
            
            // 📷 Camera (UIKit scanner)
            ScannerView(onScan: { scannedValue in
                handleScan(value: scannedValue)
            })
            .ignoresSafeArea()

            // 📝 Instruction Text
            VStack {
                Spacer()
                Text("Align code within frame to scan")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.bottom, 100)
            }

            // ❌ Close Button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }

            // ✅ Scan Feedback
            if showScanFeedback {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)

                    Text("Scanned!")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(Color.black.opacity(0.7))
                .cornerRadius(16)
                .shadow(radius: 10)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showScanFeedback)
    }

    // MARK: - Scan Handler
    private func handleScan(value: String) {
        let scannedCode = ScannedCode(value: value, time: Date())

        // 🔔 Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        onScan(scannedCode)

        showScanFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showScanFeedback = false
        }
    }
}
