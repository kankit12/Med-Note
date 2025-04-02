import Foundation
import SwiftUI

struct RecipientInfo: Codable, Identifiable {
    let id: UUID
    let name: String
    let lastUsed: Date
    
    init(name: String, lastUsed: Date) {
        self.id = UUID()
        self.name = name
        self.lastUsed = lastUsed
    }
    
    var relativeTimeString: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: lastUsed, to: now)
        
        if let days = components.day {
            switch days {
            case 0:
                return "Last used today"
            case 1:
                return "Used 1 day ago"
            default:
                return "Used \(days) days ago"
            }
        }
        return "Last used today"
    }
}

struct IllnessEstimate: Identifiable, Codable {
    let id: UUID
    let illness: String
    let confidence: Double
    let symptoms: [String]
    let recommendations: [String]
    let avoidActions: [String]
    
    init(illness: String, confidence: Double, symptoms: [String], recommendations: [String], avoidActions: [String]) {
        self.id = UUID()
        self.illness = illness
        self.confidence = confidence
        self.symptoms = symptoms
        self.recommendations = recommendations
        self.avoidActions = avoidActions
    }
}

class AppState: ObservableObject {
    @Published var symptomHistory: [SymptomEntry] = []
    @Published var previousRecipients: [RecipientInfo] = []
    @Published var localHealthTrends: [HealthTrend] = []
    @Published var userProfile: UserProfile?
    @Published var customSymptoms: [String] = []
    @Published var currentIllnessEstimate: IllnessEstimate?
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("useSystemDarkMode") var useSystemDarkMode: Bool = true
    @AppStorage("lastRecipient") var lastRecipient: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let previousRecipientsKey = "previousRecipients"
    private let customSymptomsKey = "customSymptoms"
    
    init() {
        loadData()
        updateIllnessEstimate()
    }
    
    func addSymptomEntry(_ entry: SymptomEntry) {
        symptomHistory.append(entry)
        saveData()
        updateIllnessEstimate()
    }
    
    func addRecipient(_ recipient: String) {
        if !recipient.isEmpty {
            let now = Date()
            let recipientInfo = RecipientInfo(name: recipient, lastUsed: now)
            
            // Remove if already exists
            previousRecipients.removeAll { $0.name == recipient }
            
            // Add to beginning
            previousRecipients.insert(recipientInfo, at: 0)
            
            // Keep only last 3
            if previousRecipients.count > 3 {
                previousRecipients = Array(previousRecipients.prefix(3))
            }
            
            lastRecipient = recipient
            saveData()
        }
    }
    
    func removeRecipient(_ recipient: String) {
        previousRecipients.removeAll { $0.name == recipient }
        if lastRecipient == recipient {
            lastRecipient = ""
        }
        saveData()
    }
    
    func addCustomSymptom(_ symptom: String) {
        if !customSymptoms.contains(symptom) {
            customSymptoms.append(symptom)
            saveData()
        }
    }
    
    func removeCustomSymptom(_ symptom: String) {
        customSymptoms.removeAll { $0 == symptom }
        saveData()
    }
    
    func clearHistory() {
        symptomHistory.removeAll()
        currentIllnessEstimate = nil
        saveData()
    }
    
    func updateProfile(_ profile: UserProfile) {
        userProfile = profile
        saveData()
    }
    
    private func loadData() {
        do {
            // Load sensitive data from Keychain
            symptomHistory = try SecureDataManager.shared.loadSymptomHistory()
            userProfile = try SecureDataManager.shared.loadUserProfile()
            
            // Load non-sensitive data from UserDefaults
            if let data = userDefaults.data(forKey: previousRecipientsKey),
               let decodedRecipients = try? JSONDecoder().decode([RecipientInfo].self, from: data) {
                previousRecipients = decodedRecipients
            }
            customSymptoms = userDefaults.stringArray(forKey: customSymptomsKey) ?? []
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    private func saveData() {
        do {
            // Save sensitive data to Keychain
            try SecureDataManager.shared.saveSymptomHistory(symptomHistory)
            if let profile = userProfile {
                try SecureDataManager.shared.saveUserProfile(profile)
            }
            
            // Save non-sensitive data to UserDefaults
            if let encoded = try? JSONEncoder().encode(previousRecipients) {
                userDefaults.set(encoded, forKey: previousRecipientsKey)
            }
            userDefaults.set(customSymptoms, forKey: customSymptomsKey)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func generateNote(symptoms: Set<String>, severity: Double, recipient: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let currentDate = dateFormatter.string(from: Date())
        let symptomsList = symptoms.joined(separator: ", ")
        let signature = userProfile?.name ?? "[Your Name]"
        
        return """
        Dear \(recipient),
        
        I am writing to inform you that I am currently experiencing health issues that require me to be absent. I have been experiencing \(symptomsList) with a severity level of \(Int(severity))/10.
        
        I will keep you updated on my condition and return as soon as I am well enough to do so.
        
        Thank you for your understanding.
        
        Best regards,
        \(signature)
        
        Date: \(currentDate)
        """
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    func toggleSystemDarkMode() {
        useSystemDarkMode.toggle()
    }
    
    private func updateIllnessEstimate() {
        // If there's no history, clear the estimate
        if symptomHistory.isEmpty {
            currentIllnessEstimate = nil
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        
        // Get symptoms from the last 3 days
        let recentSymptoms = symptomHistory
            .filter { $0.date >= threeDaysAgo }
            .flatMap { $0.symptoms }
        
        // If no recent symptoms, clear the estimate
        if recentSymptoms.isEmpty {
            currentIllnessEstimate = nil
            return
        }
        
        // Count symptom occurrences
        var symptomCounts: [String: Int] = [:]
        for symptom in recentSymptoms {
            symptomCounts[symptom, default: 0] += 1
        }
        
        // Define illness patterns
        let illnessPatterns: [(illness: String, symptoms: Set<String>, confidence: Double)] = [
            ("Common Cold", ["Cough", "Sore Throat", "Runny Nose", "Congestion", "Sneezing"], 0.8),
            ("Flu", ["Fever", "Body Aches", "Fatigue", "Cough", "Chills"], 0.9),
            ("Stomach Bug", ["Nausea", "Vomiting", "Diarrhea", "Stomach Pain", "Loss of Appetite"], 0.85),
            ("Sinus Infection", ["Congestion", "Sinus Pressure", "Headache", "Cough", "Fatigue"], 0.75),
            ("Bronchitis", ["Cough", "Chest Congestion", "Fatigue", "Shortness of Breath", "Wheezing"], 0.8)
        ]
        
        // Find best matching illness
        var bestMatch: (illness: String, confidence: Double, symptoms: Set<String>)?
        var bestConfidence = 0.0
        
        for pattern in illnessPatterns {
            let matchingSymptoms = Set(symptomCounts.keys).intersection(pattern.symptoms)
            let confidence = Double(matchingSymptoms.count) / Double(pattern.symptoms.count) * pattern.confidence
            
            if confidence > bestConfidence {
                bestConfidence = confidence
                bestMatch = (pattern.illness, confidence, pattern.symptoms)
            }
        }
        
        if let match = bestMatch, match.confidence > 0.3 {
            currentIllnessEstimate = IllnessEstimate(
                illness: match.illness,
                confidence: match.confidence,
                symptoms: Array(match.symptoms),
                recommendations: getRecommendations(for: match.illness),
                avoidActions: getAvoidActions(for: match.illness)
            )
        } else {
            currentIllnessEstimate = nil
        }
    }
    
    private func getRecommendations(for illness: String) -> [String] {
        switch illness {
        case "Common Cold":
            return [
                "Rest and get plenty of sleep",
                "Stay hydrated with water and warm fluids",
                "Use over-the-counter cold medications as needed",
                "Use a humidifier to ease congestion"
            ]
        case "Flu":
            return [
                "Rest and stay in bed",
                "Take prescribed antiviral medications if available",
                "Stay hydrated with water and electrolyte drinks",
                "Use fever-reducing medications as needed"
            ]
        case "Stomach Bug":
            return [
                "Stay hydrated with small sips of water",
                "Eat bland foods when able",
                "Rest and avoid strenuous activity",
                "Use anti-nausea medications if prescribed"
            ]
        case "Sinus Infection":
            return [
                "Use saline nasal spray",
                "Apply warm compresses to face",
                "Stay hydrated",
                "Use over-the-counter decongestants"
            ]
        case "Bronchitis":
            return [
                "Use a humidifier",
                "Stay hydrated",
                "Take prescribed medications",
                "Avoid smoke and irritants"
            ]
        default:
            return []
        }
    }
    
    private func getAvoidActions(for illness: String) -> [String] {
        switch illness {
        case "Common Cold":
            return [
                "Avoid close contact with others",
                "Don't share personal items",
                "Avoid smoking and secondhand smoke"
            ]
        case "Flu":
            return [
                "Avoid public places",
                "Don't share utensils or cups",
                "Avoid strenuous exercise"
            ]
        case "Stomach Bug":
            return [
                "Avoid dairy products",
                "Don't share food or drinks",
                "Avoid spicy or fatty foods"
            ]
        case "Sinus Infection":
            return [
                "Avoid swimming",
                "Don't smoke",
                "Avoid air travel if possible"
            ]
        case "Bronchitis":
            return [
                "Avoid smoke and air pollution",
                "Don't exercise outdoors",
                "Avoid cold air exposure"
            ]
        default:
            return []
        }
    }
} 