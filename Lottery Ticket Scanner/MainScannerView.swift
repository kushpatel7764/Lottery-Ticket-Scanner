import SwiftUI

struct MainScannerView: View {
    @State private var scannedCodes: [ScannedCode] = []
    @State private var showScanner = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- 📊 Header / Stats View ---
                    headerView
                    
                    if scannedCodes.isEmpty {
                        emptyStateView
                    } else {
                        // --- 📜 Professional Scanned List ---
                        List {
                            ForEach(scannedCodes) { code in
                                ScannedCodeRow(code: code)
                            }
                            .onDelete(perform: deleteItems)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
                
                // --- ➕ Floating Action Button ---
                scanButton
            }
            .navigationTitle("Inventory Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showScanner) {
                ScannerCameraView(isPresented: $showScanner) { scannedCode in
                    withAnimation(.spring()) {
                        scannedCodes.insert(scannedCode, at: 0) // Newest at top
                    }
                }
            }
        }
    }

    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Total Scanned")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text("\(scannedCodes.count)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
            }
            Spacer()
            Image(systemName: "square.grid.3x3.fill")
                .foregroundColor(.blue.opacity(0.8))
                .font(.title)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.3))
            Text("No codes scanned yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap the button below to start your session.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var scanButton: some View {
        Button(action: { showScanner = true }) {
            HStack {
                Image(systemName: "camera.viewfinder")
                    .font(.title2.bold())
                Text("Scan Code")
                    .fontWeight(.semibold)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 30)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        scannedCodes.remove(atOffsets: offsets)
    }
}

// MARK: - Row Component
struct ScannedCodeRow: View {
    let code: ScannedCode
    @State private var showDetails = false
    
    var body: some View {
        HStack(spacing: 15) {
            // 1. Icon with Validation Status
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: code.isValid ? "barcode.viewfinder" : "exclamationmark.triangle.fill")
                    .foregroundColor(code.isValid ? .blue : .orange)
                    .padding(8)
                    .background(code.isValid ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(8)
                
                if code.isValid {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .background(Color.white.clipShape(Circle()))
                        .offset(x: 4, y: 4)
                }
            }
            
            // 2. Data Text
            VStack(alignment: .leading, spacing: 4) {
                Text(code.value)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(code.isValid ? "Valid Format" : "Invalid: Must be 29 digits")
                    .font(.caption)
                    .foregroundColor(code.isValid ? .secondary : .orange)
            }
            
            Spacer()
            
            // 3. Conditional Info Button (Only shows if valid)
            if code.isValid {
                Button {
                    showDetails = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .alert("Data Details", isPresented: $showDetails) {
            Button("Done", role: .cancel) { }
        } message: {
            Text("""
                Game #: \(code.getGameNum())
                Book ID: \(code.getBookID())
                Ticket #: \(code.getTicketNum())
                Price: $\(code.getTicketPrice())
                Book Amt: \(code.getBookAmount())
                
                Full Raw Data:
                \(code.value)
                """)
        }
    }
}
