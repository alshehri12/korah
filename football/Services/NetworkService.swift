import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://v3.football.api-sports.io"
    private let apiKey = "89ed43627b2815615c9a8cd164c1b606"
    private let newsAPIKey = "99ad4416a07c423fb26948dfb9e18bc0"
    
    private init() {}
    
    func printAPIDetails() {
        print("\n=== API Details ===")
        print("Base URL: \(baseURL)")
        print("Endpoint: /fixtures")
        print("Method: GET")
        print("\nHeaders:")
        print("x-rapidapi-key: \(apiKey)")
        print("x-rapidapi-host: v3.football.api-sports.io")
        print("\nQuery Parameters:")
        print("league: 307 (Saudi Pro League)")
        print("season: 2024")
        print("\nComplete URL:")
        print("\(baseURL)/fixtures?league=307&season=2024")
        print("=== End API Details ===\n")
    }
    
    // Test function to directly call the API
    func testAPICall() async {
        print("\n=== Testing API Call ===")
        let currentYear = Calendar.current.component(.year, from: Date())
        let urlString = "\(baseURL)/fixtures?league=307&season=\(currentYear)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("v3.football.api-sports.io", forHTTPHeaderField: "x-rapidapi-host")
        
        do {
            print("Making API request to: \(urlString)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("\nResponse Status Code: \(httpResponse.statusCode)")
                print("Response Headers:")
                for (key, value) in httpResponse.allHeaderFields {
                    print("\(key): \(value)")
                }
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("\nRaw API Response:")
                print(jsonString)
            }
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
        print("=== API Test Complete ===\n")
    }
    
    func fetchMatches() async throws -> [Match] {
        print("\n=== Starting Match Fetch ===")
        // Get current year for season (2024-2025 season)
        let currentYear = 2024
        let urlString = "\(baseURL)/fixtures?league=307&season=\(currentYear)"
        print("Fetching matches for season \(currentYear)")
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("v3.football.api-sports.io", forHTTPHeaderField: "x-rapidapi-host")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError("Invalid response")
            }
            
            print("API Response Status Code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("API Error Response: \(errorString)")
                }
                throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let result = try decoder.decode(APIFootballResponse.self, from: data)
            print("Successfully decoded response with \(result.response.count) fixtures")
            
            // Convert API response to Match objects
            let matches = result.response.map { fixture in
                let status: Match.MatchStatus
                switch fixture.fixture.status.short {
                case "LIVE":
                    status = .live
                case "FT", "AET", "PEN":
                    status = .finished
                case "NS", "TBD", "PST":
                    status = .scheduled
                default:
                    status = .scheduled
                }
                
                let match = Match(
                    id: String(fixture.fixture.id),
                    homeTeam: Team(
                        id: String(fixture.teams.home.id),
                        name: fixture.teams.home.name,
                        logo: fixture.teams.home.logo
                    ),
                    awayTeam: Team(
                        id: String(fixture.teams.away.id),
                        name: fixture.teams.away.name,
                        logo: fixture.teams.away.logo
                    ),
                    homeScore: fixture.goals.home,
                    awayScore: fixture.goals.away,
                    status: status,
                    date: fixture.fixture.date,
                    league: "Saudi Pro League"
                )
                
                print("Converted match: \(match.homeTeam.name) vs \(match.awayTeam.name) - Status: \(match.status) - Date: \(match.date)")
                return match
            }
            
            // Filter and sort matches
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let round30StartDate = dateFormatter.date(from: "2025-05-01")!
            
            // Filter matches for Round 30 and onwards
            let upcomingMatches = matches.filter { match in
                match.status == .scheduled && match.date >= round30StartDate
            }.sorted { $0.date < $1.date } // Sort by date ascending for upcoming matches
            
            // Filter live and finished matches
            let liveMatches = matches.filter { $0.status == .live }
            let finishedMatches = matches.filter { $0.status == .finished }.sorted { $0.date > $1.date }
            
            print("\nMatch Summary:")
            print("Live matches: \(liveMatches.count)")
            print("Upcoming matches (Round 30 onwards): \(upcomingMatches.count)")
            print("Finished matches: \(finishedMatches.count)")
            
            if let nextMatch = upcomingMatches.first {
                print("\nNext upcoming match:")
                print("\(nextMatch.homeTeam.name) vs \(nextMatch.awayTeam.name)")
                print("Date: \(nextMatch.date)")
            }
            
            // Combine all matches
            return liveMatches + upcomingMatches + finishedMatches
            
        } catch {
            print("Error in fetchMatches: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key.stringValue) - \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: expected \(type) - \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found: expected \(type) - \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
            }
            throw error
        }
    }
    
    func fetchNews() async throws -> [News] {
        let urlString = "https://newsapi.org/v2/everything?q=saudi+pro+league+football&language=en&sortBy=publishedAt&apiKey=\(newsAPIKey)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid response")
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(NewsAPIResponse.self, from: data)
            return result.articles.map { article in
                News(
                    id: article.url,
                    title: article.title,
                    description: article.description ?? "",
                    imageUrl: article.urlToImage ?? "",
                    publishedAt: article.publishedAt,
                    source: article.source.name,
                    url: article.url
                )
            }
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchStandings() async throws -> [Standing] {
        let urlString = "\(baseURL)/standings?league=307&season=2023"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("v3.football.api-sports.io", forHTTPHeaderField: "x-rapidapi-host")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid response")
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(StandingsResponse.self, from: data)
            return result.response[0].league.standings[0].map { standing in
                Standing(
                    id: String(standing.team.id),
                    name: standing.team.name,
                    logo: standing.team.logo,
                    position: standing.rank,
                    played: standing.all.played,
                    won: standing.all.win,
                    drawn: standing.all.draw,
                    lost: standing.all.lose,
                    points: standing.points,
                    goalsFor: standing.all.goals.for,
                    goalsAgainst: standing.all.goals.against
                )
            }
        } catch {
            throw NetworkError.decodingError
        }
    }
}

// API-Football Response Models
struct APIFootballResponse: Codable {
    let response: [Fixture]
}

struct Fixture: Codable {
    let fixture: FixtureDetail
    let league: League
    let teams: Teams
    let goals: Goals
}

struct FixtureDetail: Codable {
    let id: Int
    let date: Date
    let status: Status
}

struct Status: Codable {
    let short: String
}

struct League: Codable {
    let id: Int
    let name: String
}

struct Teams: Codable {
    let home: TeamDetail
    let away: TeamDetail
}

struct TeamDetail: Codable {
    let id: Int
    let name: String
    let logo: String
}

struct Goals: Codable {
    let home: Int?
    let away: Int?
}

// Standings Response Models
struct StandingsResponse: Codable {
    let response: [StandingsLeague]
}

struct StandingsLeague: Codable {
    let league: LeagueStandings
}

struct LeagueStandings: Codable {
    let standings: [[TeamStanding]]
}

struct TeamStanding: Codable {
    let rank: Int
    let team: TeamDetail
    let points: Int
    let all: TeamStats
}

struct TeamStats: Codable {
    let played: Int
    let win: Int
    let draw: Int
    let lose: Int
    let goals: TeamGoals
}

struct TeamGoals: Codable {
    let `for`: Int
    let against: Int
}

// NewsAPI Response Models
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsAPIArticle]
}

struct NewsAPIArticle: Codable {
    let source: NewsAPISource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date
    let content: String?
}

struct NewsAPISource: Codable {
    let id: String?
    let name: String
}

// App Models
struct Standing: Identifiable {
    let id: String
    let name: String
    let logo: String
    let position: Int
    let played: Int
    let won: Int
    let drawn: Int
    let lost: Int
    let points: Int
    let goalsFor: Int
    let goalsAgainst: Int
    
    var goalDifference: Int {
        goalsFor - goalsAgainst
    }
} 
