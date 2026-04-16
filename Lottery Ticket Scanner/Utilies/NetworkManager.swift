import Foundation

enum NetworkManager {
    static func sendBarcode(_ code: String) {
        guard let url = URL(string: "http://192.168.12.210:5000/receive") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "barcode=\(code)".data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending barcode: \(error.localizedDescription)")
            } else {
                print("Successfully sent barcode: \(code)")
            }
        }.resume()
    }
}