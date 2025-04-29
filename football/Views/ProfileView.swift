import SwiftUI

struct ProfileView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("favoriteTeam") private var favoriteTeam: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        TextField("Enter your name", text: $username)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Preferences
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preferences")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                                .padding()
                                .background(Color(.systemBackground))
                            
                            Divider()
                            
                            Toggle("Dark Mode", isOn: $darkModeEnabled)
                                .padding()
                                .background(Color(.systemBackground))
                            
                            Divider()
                            
                            HStack {
                                Text("Favorite Team")
                                Spacer()
                                TextField("Enter team name", text: $favoriteTeam)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                        }
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Version")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            
                            Divider()
                            
                            Button(action: {
                                // TODO: Implement rate app
                            }) {
                                HStack {
                                    Text("Rate App")
                                    Spacer()
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                            }
                            
                            Divider()
                            
                            Button(action: {
                                // TODO: Implement share app
                            }) {
                                HStack {
                                    Text("Share App")
                                    Spacer()
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                            }
                        }
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
} 