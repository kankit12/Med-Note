import SwiftUI

struct HomeView: View {
    @State private var localTrends: [HealthTrend] = []
    @State private var isLoading = true
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : .white
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray5) : .white
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Welcome Section
                VStack(spacing: 8) {
                    Text("Welcome to MedNote")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    if let profile = appState.userProfile {
                        Text("Hello, \(profile.name)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                
                // Local Health Trends Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Local Health Trends")
                            .font(.headline)
                            .foregroundColor(textColor)
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    if localTrends.isEmpty {
                        Text("No health trends available")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(localTrends) { trend in
                            TrendCard(trend: trend)
                        }
                    }
                }
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        NavigationLink(destination: SymptomInputView()
                            .environmentObject(appState)) {
                            QuickActionButton(
                                title: "Add Symptoms",
                                icon: "heart.text.square.fill",
                                color: .blue
                            )
                        }
                        
                        NavigationLink(destination: IllnessEstimateView()
                            .environmentObject(appState)) {
                            QuickActionButton(
                                title: "Illness Estimate",
                                icon: "heart.text.square",
                                color: .green
                            )
                        }
                        
                        NavigationLink(destination: SymptomHistoryView()
                            .environmentObject(appState)) {
                            QuickActionButton(
                                title: "View History",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .orange
                            )
                        }
                        
                        NavigationLink(destination: SettingsView()
                            .environmentObject(appState)) {
                            QuickActionButton(
                                title: "Settings",
                                icon: "gear",
                                color: .purple
                            )
                        }
                    }
                }
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Creator Credit
                VStack(spacing: 8) {
                    Text("Created by")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Ankit Kantheti")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .background(backgroundColor)
        .navigationBarHidden(true)
        .onAppear {
            loadLocalTrends()
        }
    }
    
    private func loadLocalTrends() {
        // Simulated data that changes weekly
        let calendar = Calendar.current
        let weekNumber = calendar.component(.weekOfYear, from: Date())
        
        // List of possible illnesses and their variations
        let possibleIllnesses = [
            ("Common Cold", ["High", "Medium", "Low"], ["Increasing", "Stable", "Decreasing"]),
            ("Flu", ["High", "Medium", "Low"], ["Increasing", "Stable", "Decreasing"]),
            ("Stomach Bug", ["High", "Medium", "Low"], ["Increasing", "Stable", "Decreasing"]),
            ("Allergies", ["High", "Medium", "Low"], ["Increasing", "Stable", "Decreasing"]),
            ("COVID-19", ["High", "Medium", "Low"], ["Increasing", "Stable", "Decreasing"]),
            ("RSV", ["High", "Medium", "Low"], ["Increasing", "Stable", "Decreasing"]),
            ("Pink Eye", ["High", "Medium", "Low"], ["Increasing", "Stable", "Decreasing"]),
            ("Strep Throat", ["High", "Medium", "Low"], ["Increasing", "Stable", "Decreasing"])
        ]
        
        // Select 3 random illnesses based on week number
        var selectedIllnesses: [(String, [String], [String])] = []
        for (index, illness) in possibleIllnesses.enumerated() {
            if (index + weekNumber) % 3 == 0 {
                selectedIllnesses.append(illness)
                if selectedIllnesses.count >= 3 {
                    break
                }
            }
        }
        
        // Generate trends
        let trends = selectedIllnesses.enumerated().map { index, illness in
            let (name, severities, trends) = illness
            let severity = severities[Int.random(in: 0..<3)]
            let trend = trends[Int.random(in: 0..<3)]
            return HealthTrend(id: index + 1, illness: name, severity: severity, trend: trend)
        }
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            localTrends = trends
            isLoading = false
        }
    }
}

struct TrendCard: View {
    let trend: HealthTrend
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trend.illness)
                    .font(.headline)
                Spacer()
                Text(trend.severity)
                    .font(.subheadline)
                    .foregroundColor(severityColor)
            }
            
            HStack {
                Image(systemName: trendIcon)
                    .foregroundColor(trendColor)
                Text("Trend: \(trend.trend)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var severityColor: Color {
        switch trend.severity.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .green
        default: return .secondary
        }
    }
    
    private var trendIcon: String {
        switch trend.trend.lowercased() {
        case "increasing": return "arrow.up.circle.fill"
        case "decreasing": return "arrow.down.circle.fill"
        case "stable": return "equal.circle.fill"
        default: return "circle.fill"
        }
    }
    
    private var trendColor: Color {
        switch trend.trend.lowercased() {
        case "increasing": return .red
        case "decreasing": return .green
        case "stable": return .orange
        default: return .secondary
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        HomeView()
            .environmentObject(AppState())
    }
} 