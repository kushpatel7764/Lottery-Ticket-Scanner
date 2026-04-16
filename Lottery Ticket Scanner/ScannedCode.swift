import Foundation

struct ScannedCode: Identifiable, Equatable {
    let id = UUID()
    let value: String
    let time: Date
}