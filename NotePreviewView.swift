import SwiftUI

struct NotePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var showingShareSheet = false
    @State private var showingSaveConfirmation = false
    
    let noteText: String
    let symptoms: Set<String>
    let severity: Double
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(noteText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .padding()
            }
            
            HStack(spacing: 20) {
                Button(action: saveNote) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    showingShareSheet = true
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Note Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [noteText])
        }
        .alert("Note Saved", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your note has been saved to your history.")
        }
    }
    
    private func saveNote() {
        let entry = SymptomEntry(
            id: appState.symptomHistory.count + 1,
            date: Date(),
            severity: severity,
            symptoms: Array(symptoms)
        )
        appState.addSymptomEntry(entry)
        showingSaveConfirmation = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationView {
        NotePreviewView(
            noteText: "Sample note text",
            symptoms: ["Fever", "Cough"],
            severity: 7
        )
        .environmentObject(AppState())
    }
} 