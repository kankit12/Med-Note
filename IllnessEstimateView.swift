import SwiftUI

struct IllnessEstimateView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab = 0
    
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
            if let estimate = appState.currentIllnessEstimate {
                VStack(spacing: 24) {
                    // Illness Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(estimate.illness)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(textColor)
                                
                                Text("\(Int(estimate.confidence * 100))% confidence")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .opacity(0.8)
                        }
                        
                        Divider()
                        
                        Text("Symptoms")
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(estimate.symptoms, id: \.self) { symptom in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(symptom)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Recommendations and Actions
                    Picker("", selection: $selectedTab) {
                        Text("Recommendations").tag(0)
                        Text("Actions to Avoid").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if selectedTab == 0 {
                        // Recommendations Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("Recommendations")
                                    .font(.headline)
                                    .foregroundColor(textColor)
                            }
                            
                            ForEach(estimate.recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.subheadline)
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .foregroundColor(textColor)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    } else {
                        // Actions to Avoid Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                Text("Actions to Avoid")
                                    .font(.headline)
                                    .foregroundColor(textColor)
                            }
                            
                            ForEach(estimate.avoidActions, id: \.self) { action in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                    Text(action)
                                        .font(.subheadline)
                                        .foregroundColor(textColor)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            } else {
                VStack(spacing: 24) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .opacity(0.8)
                    
                    Text("No Illness Estimate Available")
                        .font(.title2)
                        .bold()
                        .foregroundColor(textColor)
                    
                    Text("Add your symptoms to get an illness estimate")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink(destination: SymptomInputView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Symptoms")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.top)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(backgroundColor)
        .navigationTitle("Illness Estimate")
    }
}

#Preview {
    NavigationView {
        IllnessEstimateView()
            .environmentObject(AppState())
    }
} 