//
//  ContentView.swift
//  football
//
//  Created by Abdulrahman Alshehri on 27/10/1446 AH.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MatchesView()
                .tabItem {
                    Label("Matches", systemImage: "sportscourt")
                }
            
            NewsView()
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
}
