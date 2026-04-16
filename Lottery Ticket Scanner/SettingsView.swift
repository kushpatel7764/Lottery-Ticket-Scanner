//
//  SettingsView.swift
//  Lottery Ticket Scanner
//
//  Created by Kush Patel on 4/16/26.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("server_ip") private var serverIP: String = ""
    @AppStorage("scanner_api_key") private var scannerAPI: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Flask Server IP")) {
                TextField("e.g. 192.168.12.210", text: $serverIP)
                    .keyboardType(.numbersAndPunctuation)
                    .autocapitalization(.none)
            }
            Section(header: Text("Scanner API Key")) {
                TextField("e.g. 466644dafb6aa0eb9...", text: $scannerAPI)
                    .keyboardType(.numbersAndPunctuation)
                    .autocapitalization(.none)
            }
        }
        .navigationTitle("Settings")
    }
}
