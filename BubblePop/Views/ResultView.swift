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
                    
                    List {
                        ForEach(Array(topScores.prefix(10).enumerated()), id: \.element.id) { index, score in
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.custom("Bebas Neue", size: 30))
                                    .frame(width: 50, alignment: .leading)
                                
                                Text(score.name)
                                    .font(.custom("Bebas Neue", size: 30))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(score.score)")
                                    .font(.custom("Bebas Neue", size: 30))
                                    .frame(alignment: .trailing)
                            }
                            .foregroundColor(.black)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: 500)

                    Spacer()

                    HStack(spacing: 40) {
                        Button("Home") {
                        }
                        Button("Again") {
                        }
                    }
                    .font(.custom("Bebas Neue", size: 40))
                    .foregroundColor(.pink)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            loadTopScores()
        }
        .navigationBarHidden(true)

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
