import SwiftUI

struct SymptomInputView: View {
    @State private var selectedSymptoms: Set<String> = []
    @State private var severity: Double = 5
    @State private var recipient = ""
    @State private var showingRecipientSuggestions = false
    @State private var showingNotePreview = false
    @State private var newSymptom = ""
    @State private var showingCustomSymptomInput = false
    @State private var filteredRecipients: [RecipientInfo] = []
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    
    let commonSymptoms = [
        "Fever", "Cough", "Sore Throat", "Headache", "Body Aches",
        "Nausea", "Vomiting", "Diarrhea", "Fatigue", "Chills"
    ]
    
    var allSymptoms: [String] {
        commonSymptoms + appState.customSymptoms
    }
    
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
                // Recipient Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recipient")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    TextField("Enter recipient name", text: $recipient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onTapGesture {
                            showingRecipientSuggestions = true
                        }
                    
                    if showingRecipientSuggestions && !appState.previousRecipients.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recent Recipients")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(appState.previousRecipients) { recipientInfo in
                                HStack {
                                    Text(recipientInfo.name)
                                    Spacer()
                                    Text(recipientInfo.relativeTimeString)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.recipient = recipientInfo.name
                                    showingRecipientSuggestions = false
                                }
                            }
                        }
                        .padding()
                        .background(cardBackgroundColor)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Symptoms Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Symptoms")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(allSymptoms, id: \.self) { symptom in
                            SymptomButton(
                                symptom: symptom,
                                isSelected: selectedSymptoms.contains(symptom),
                                action: {
                                    if selectedSymptoms.contains(symptom) {
                                        selectedSymptoms.remove(symptom)
                                    } else {
                                        selectedSymptoms.insert(symptom)
                                    }
                                }
                            )
                        }
                    }
                    
                    Button(action: {
                        showingCustomSymptomInput = true
                    }) {
                        Label("Add Custom Symptom", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(cardBackgroundColor)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Severity Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Severity")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Mild")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Severe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $severity, in: 1...10, step: 1)
                            .tint(severityColor)
                    }
                }
                .padding()
                .background(cardBackgroundColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Generate Note Button
                Button(action: generateNote) {
                    Text("Generate Note")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedSymptoms.isEmpty || recipient.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(selectedSymptoms.isEmpty || recipient.isEmpty)
            }
            .padding()
        }
        .background(backgroundColor)
        .navigationTitle("New Note")
        .sheet(isPresented: $showingNotePreview) {
            NotePreviewView(
                noteText: appState.generateNote(symptoms: selectedSymptoms, severity: severity, recipient: recipient),
                symptoms: selectedSymptoms,
                severity: severity
            )
            .environmentObject(appState)
        }
        .alert("Add Custom Symptom", isPresented: $showingCustomSymptomInput) {
            TextField("Enter symptom", text: $newSymptom)
            Button("Cancel", role: .cancel) {
                newSymptom = ""
            }
            Button("Add") {
                if !newSymptom.isEmpty {
                    appState.addCustomSymptom(newSymptom)
                    selectedSymptoms.insert(newSymptom)
                    newSymptom = ""
                }
            }
        } message: {
            Text("Enter a custom symptom to add to your list.")
        }
    }
    
    private var severityColor: Color {
        switch severity {
        case 1...3: return .green
        case 4...7: return .orange
        default: return .red
        }
    }
    
    private func generateNote() {
        appState.addRecipient(recipient)
        showingNotePreview = true
    }
}

struct SymptomButton: View {
    let symptom: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(symptom)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationView {
        SymptomInputView()
            .environmentObject(AppState())
    }
} 