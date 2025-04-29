import Foundation

struct News: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String
    let publishedAt: Date
    let source: String
    let url: String
} 