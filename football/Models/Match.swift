import Foundation

struct Match: Identifiable, Codable {
    let id: String
    let homeTeam: Team
    let awayTeam: Team
    let homeScore: Int?
    let awayScore: Int?
    let status: MatchStatus
    let date: Date
    let league: String
    
    enum MatchStatus: String, Codable {
        case live
        case scheduled
        case finished
    }
}

struct Team: Codable {
    let id: String
    let name: String
    let logo: String
} 