import SwiftUI

struct MatchesView: View {
    @StateObject private var viewModel = MatchesViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selector
                Picker("Match Type", selection: $selectedTab) {
                    Text("Live").tag(0)
                    Text("Upcoming").tag(1)
                    Text("Results").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Match list
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                        Button("Retry") {
                            Task {
                                await viewModel.fetchMatches()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    List {
                        ForEach(groupedMatches.keys.sorted(), id: \.self) { date in
                            Section(header: DateHeaderView(date: date)) {
                                ForEach(groupedMatches[date] ?? []) { match in
                                    MatchRow(match: match)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await viewModel.fetchMatches()
                    }
                }
            }
            .navigationTitle("Matches")
            .task {
                await viewModel.fetchMatches()
            }
            .onChange(of: selectedTab) { _ in
                Task {
                    await viewModel.fetchMatches()
                }
            }
        }
    }
    
    private var filteredMatches: [Match] {
        switch selectedTab {
        case 0:
            return viewModel.matches.filter { $0.status == .live }
        case 1:
            return viewModel.matches.filter { $0.status == .scheduled }
        case 2:
            return viewModel.matches.filter { $0.status == .finished }
        default:
            return []
        }
    }
    
    private var groupedMatches: [Date: [Match]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return Dictionary(grouping: filteredMatches) { match in
            let calendar = Calendar.current
            return calendar.startOfDay(for: match.date)
        }
    }
}

struct DateHeaderView: View {
    let date: Date
    
    var body: some View {
        HStack {
            Text(date, style: .date)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(date, style: .time)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }
}

struct MatchRow: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(match.league)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(match.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                TeamView(team: match.homeTeam)
                Spacer()
                ScoreView(match: match)
                Spacer()
                TeamView(team: match.awayTeam)
            }
        }
        .padding(.vertical, 8)
    }
}

struct TeamView: View {
    let team: Team
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: team.logo)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 40, height: 40)
            
            Text(team.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
    }
}

struct ScoreView: View {
    let match: Match
    
    var body: some View {
        VStack(spacing: 4) {
            if match.status == .live {
                Text("LIVE")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
            
            if match.status == .finished {
                HStack(spacing: 4) {
                    Text("\(match.homeScore ?? 0)")
                        .font(.headline)
                    Text("-")
                        .font(.headline)
                    Text("\(match.awayScore ?? 0)")
                        .font(.headline)
                }
            } else {
                Text(match.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    MatchesView()
} 