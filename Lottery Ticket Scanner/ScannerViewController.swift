import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var boundingBox = CAShapeLayer()
    
    // Controls the "cooldown" between scans
    var isScanning = true

    var onScan: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupBoundingBox()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.dataMatrix]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.layer.addSublayer(boundingBox)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    private func setupBoundingBox() {
        boundingBox.strokeColor = UIColor.green.cgColor
        boundingBox.lineWidth = 4
        boundingBox.fillColor = UIColor.green.withAlphaComponent(0.15).cgColor
        boundingBox.lineJoin = .round
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        // If we are in the 1.5s cooldown, do nothing
        guard isScanning else { return }

        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let transformedObject = previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject {

            let path = UIBezierPath()
            let corners = transformedObject.corners
            
            if corners.count > 0 {
                path.move(to: corners[0])
                for i in 1..<corners.count { path.addLine(to: corners[i]) }
                path.close()
            }
            
            boundingBox.path = path.cgPath

            if let value = metadataObject.stringValue {
                isScanning = false // Pause scanning
                onScan?(value)
                
                // ⏱️ Wait 1.5 seconds, then allow scanning again
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isScanning = true
                    self.boundingBox.path = nil // Clear the green box for the next scan
                }
            }
        } else {
            boundingBox.path = nil
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.layer.bounds
    }
}
