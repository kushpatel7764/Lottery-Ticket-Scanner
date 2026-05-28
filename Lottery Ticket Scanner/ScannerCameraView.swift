import SwiftUI

struct ScannerCameraView: View {
    @EnvironmentObject var bluetooth: BluetoothManager
    @Binding var isPresented: Bool
    var onScan: (ScannedCode) -> Void

    @State private var feedbackMessage: String? = nil
    private let scannerFrameSize: CGFloat = 260

    var body: some View {
        ZStack {
            CameraPreview(onScan: handleScan)
                .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: scannerFrameSize, height: scannerFrameSize)

            VStack {
                HStack {
                    // Live connection indicator in the camera view
                    HStack(spacing: 6) {
                        Circle()
                            .fill(bluetooth.connectionState.color)
                            .frame(width: 8, height: 8)
                        Text(bluetooth.connectionState.label)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                    .padding()

                    Spacer()

                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding()
                }

                Spacer()

                Text("Ready to scan multiple codes…")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.bottom, 80)
            }

            // Scan result feedback bubble
            if let message = feedbackMessage {
                VStack(spacing: 12) {
                    Image(systemName: bluetooth.connectionState == .connected
                          ? "checkmark.circle.fill"
                          : "clock.arrow.circlepath")
                        .font(.system(size: 70))
                        .foregroundColor(bluetooth.connectionState == .connected ? .green : .orange)
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func handleScan(value: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        let scannedCode = ScannedCode(value: value, time: Date())
        onScan(scannedCode)
        bluetooth.sendBarcode(value)

        // Show feedback reflecting whether the Mac is connected right now
        let msg = bluetooth.connectionState == .connected ? "Sent to Mac" : "Queued — Mac offline"
        withAnimation(.spring()) { feedbackMessage = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { feedbackMessage = nil }
        }
    }
}
