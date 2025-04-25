import SwiftUI

struct ResultView: View {
    @State private var topScores: [PlayerScore] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Top 10 High Scores")
                        .font(.custom("Bebas Neue", size: 50))
                        .foregroundColor(.pink)
                        .padding(.top, 40)
                    
                    ScoreListView(scores: topScores)
                    .frame(height: 500)

                    Spacer()

                    HStack(spacing: 40) {
                        Button("Home") {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController = UIHostingController(rootView: HomeView())
                                window.makeKeyAndVisible()
                            }
                        }
                    }
                    .font(.custom("Bebas Neue", size: 40))
                    .foregroundColor(.pink)
                    
                    Spacer()
                }
                .padding()
                
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadTopScores()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)

    }
    
    private func loadTopScores() {
        let fileName = "ScoreData.json"
        let fileManager = FileManager.default
        
        guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentURL.appendingPathComponent(fileName)
        
        if let data = try? Data(contentsOf: fileURL),
           let loadedScores = try? JSONDecoder().decode([PlayerScore].self, from: data) {
            topScores = loadedScores.sorted { $0.score > $1.score }
        }
    }
}

#Preview {
    ResultView()
}
