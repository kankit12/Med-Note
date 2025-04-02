import SwiftUI
import Charts

struct SymptomHistoryView: View {
    @State private var selectedTimeRange: TimeRange = .week
    @EnvironmentObject private var appState: AppState
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var filteredHistory: [SymptomEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        return appState.symptomHistory.filter { entry in
            switch selectedTimeRange {
            case .week:
                return calendar.isDate(entry.date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(entry.date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(entry.date, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Time Range Picker
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if filteredHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No History Available")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Your symptom history will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                // Symptom Graph
                Chart {
                    ForEach(filteredHistory) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Severity", entry.severity)
                        )
                        .foregroundStyle(.blue)
                        
                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("Severity", entry.severity)
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 200)
                .padding()
                
                // History List
                List {
                    ForEach(filteredHistory) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.headline)
                            
                            Text("Severity: \(Int(entry.severity))/10")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Symptoms: \(entry.symptoms.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Symptom History")
    }
}

#Preview {
    SymptomHistoryView()
        .environmentObject(AppState())
} 