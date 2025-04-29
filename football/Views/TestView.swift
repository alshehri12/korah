import SwiftUI

struct TestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("API Test")
                .font(.title)
                .padding()
            
            Button("Show API Details") {
                NetworkService.shared.printAPIDetails()
            }
            .buttonStyle(.bordered)
            
            Button("Test API Call") {
                Task {
                    await NetworkService.shared.testAPICall()
                }
            }
            .buttonStyle(.bordered)
            
            Text("Check console for results")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    TestView()
} 