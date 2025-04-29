import Foundation

@MainActor
class MatchesViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchMatches() async {
        print("\n=== MatchesViewModel: Starting Fetch ===")
        isLoading = true
        error = nil
        
        do {
            print("Calling NetworkService to fetch matches...")
            matches = try await NetworkService.shared.fetchMatches()
            print("Successfully fetched \(matches.count) matches")
            
            // Print match details for debugging
            for (index, match) in matches.enumerated() {
                print("\nMatch \(index + 1):")
                print("Home: \(match.homeTeam.name)")
                print("Away: \(match.awayTeam.name)")
                print("Status: \(match.status)")
                print("Date: \(match.date)")
                print("Score: \(match.homeScore ?? 0) - \(match.awayScore ?? 0)")
            }
            
            // Print summary by status
            let liveMatches = matches.filter { $0.status == .live }
            let upcomingMatches = matches.filter { $0.status == .scheduled }
            let finishedMatches = matches.filter { $0.status == .finished }
            
            print("\nMatch Summary:")
            print("Live matches: \(liveMatches.count)")
            print("Upcoming matches: \(upcomingMatches.count)")
            print("Finished matches: \(finishedMatches.count)")
            
        } catch {
            print("❌ Error in MatchesViewModel: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
        
        isLoading = false
        print("=== MatchesViewModel: Fetch Complete ===\n")
    }
} 