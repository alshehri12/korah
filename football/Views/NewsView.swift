import SwiftUI

struct NewsView: View {
    @State private var news: [News] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var selectedCategory = "All"
    @State private var selectedNews: News?
    
    let categories = ["All", "Saudi League", "Transfers", "Rumors", "Highlights"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                
                // News Content
                ScrollView {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                    } else if let error = error {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .padding(.top, 20)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(news) { article in
                                NewsCard(article: article)
                                    .onTapGesture {
                                        selectedNews = article
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Football News")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Implement search
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(item: $selectedNews) { news in
            NewsDetailView(news: news)
        }
        .task {
            await loadNews()
        }
    }
    
    private func loadNews() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            news = try await NetworkService.shared.fetchNews()
        } catch {
            self.error = error
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .primary : .secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    isSelected ?
                    Color.primary.opacity(0.1) :
                    Color.clear
                )
                .cornerRadius(20)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct NewsCard: View {
    let article: News
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            if let url = URL(string: article.imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                        }
                }
                .frame(height: 200)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Source and Date
                HStack {
                    Text(article.source)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(article.publishedAt, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                // Title
                Text(article.title)
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(2)
                
                // Description
                Text(article.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Read More Button
                HStack {
                    Text("Read More")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(), value: isPressed)
        .onTapGesture {
            withAnimation(.spring()) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
}

struct NewsDetailView: View {
    let news: News
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Image
                    if let url = URL(string: news.imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay {
                                    ProgressView()
                                }
                        }
                        .frame(height: 250)
                        .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Source and Date
                        HStack {
                            Text(news.source)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(news.publishedAt, style: .date)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        // Title
                        Text(news.title)
                            .font(.system(size: 24, weight: .bold))
                        
                        // Description
                        Text(news.description)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        // Read More Button
                        Link(destination: URL(string: news.url)!) {
                            HStack {
                                Text("Read Full Article")
                                    .font(.system(size: 16, weight: .medium))
                                Image(systemName: "arrow.up.right")
                            }
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("News")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 