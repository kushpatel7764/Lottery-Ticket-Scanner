import Foundation

struct ScannedCode: Identifiable, Equatable {
    let id = UUID()
    let value: String
    let time: Date
    
    // MARK: - Validation
    var isValid: Bool {
        return value.count == 29 && value.allSatisfy { $0.isNumber }
    }
    
    // MARK: - Parsing Logic
    
    /// Helper to safely extract substrings using integer offsets
    private func extract(from: Int, to: Int) -> String {
        guard value.count >= to else { return "" }
        let start = value.index(value.startIndex, offsetBy: from)
        let end = value.index(value.startIndex, offsetBy: to)
        return String(value[start..<end])
    }
    
    func getGameNum() -> String {
        return extract(from: 0, to: 3) // Python [0:3]
    }
    
    func getBookID() -> String {
        return extract(from: 4, to: 10) // Python [4:10]
    }
    
    func getTicketNum() -> String {
        let tickNum = extract(from: 10, to: 13) // Python [10:13]
        
        // Handle the "999" special case
        if tickNum == "999" {
            // Note: In a real app, 'descending' logic would come from a Settings manager
            let isDescending = false
            if isDescending {
                let amount = Int(getBookAmount()) ?? 1
                return String(amount - 1)
            } else {
                return "0"
            }
        }
        return tickNum
    }
    
    func getTicketPrice() -> String {
        return extract(from: 13, to: 15) // Python [13:15]
    }
    
    func getBookAmount() -> String {
        return extract(from: 15, to: 18) // Python [15:18]
    }
}
