//
//  CameraPreview.swift
//  Lottery Ticket Scanner
//
//  Created by Kush Patel on 4/16/26.
//


import SwiftUI

struct CameraPreview: UIViewControllerRepresentable {
    var onScan: ((String) -> Void)

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onScan = onScan
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // No updates needed
    }
}