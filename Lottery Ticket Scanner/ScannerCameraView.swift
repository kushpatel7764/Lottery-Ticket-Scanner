import SwiftUI

struct ScannerCameraView: View {
    @Binding var isPresented: Bool
    var onScan: (ScannedCode) -> Void

    @State private var showScanFeedback = false
    private let scannerFrameSize: CGFloat = 260

    var body: some View {
        ZStack {
            CameraPreview(onScan: { scannedValue in
                handleScan(value: scannedValue)
            })
            .ignoresSafeArea()

            // Static Guide
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: scannerFrameSize, height: scannerFrameSize)

            VStack {
                HStack {
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
                Text("Ready to scan multiple codes...")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.bottom, 80)
            }

            // ✅ Success Popup (Fades in and out)
            if showScanFeedback {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
                    Text("Added to List")
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
        
        // Add to list
        let scannedCode = ScannedCode(value: value, time: Date())
        onScan(scannedCode)
        NetworkManager.sendBarcode(value) 
        
        // Show "Added!" feedback
        withAnimation(.spring()) {
            showScanFeedback = true
        }
        
        // 🕒 Hide feedback after 1 second (don't close view!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showScanFeedback = false
            }
        }
    }
}
