import Foundation

enum NetworkManager {
    
    static func sendBarcode(_ code: String) {
        let ip_with_port = UserDefaults.standard.string(forKey: "server_ip") ?? "192.168.0.1"
        guard let url = URL(string: "http://\(ip_with_port)/receive") else { return }

        // Percent-encode the barcode so special characters don't corrupt the form body
        guard let encodedCode = code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode barcode: \(code)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "barcode=\(encodedCode)".data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Include the API key if one is configured (matches SCANNER_API_KEY env var on server)
        if let apiKey = UserDefaults.standard.string(forKey: "scanner_api_key"), !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "X-Scanner-Key")
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error sending barcode: \(error.localizedDescription)")
                return
            } 
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                print("Server rejected barcode (status \(http.statusCode)): \(code)")
                return
            }
            print("Successfully sent barcode: \(code)")
        }.resume()
    }
}
