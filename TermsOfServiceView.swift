import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground) : Color(.systemGray6)
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                
                Text("Last updated: April 2, 2025")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                termsSection(
                    title: "1. Acceptance of Terms",
                    content: "By accessing and using MedNotes, you agree to be bound by these Terms of Service. If you disagree with any part of these terms, you may not access the service."
                )
                
                termsSection(
                    title: "2. Description of Service",
                    content: "MedNotes is a health tracking application that allows users to:\n\n• Record and track symptoms\n• Generate health insights\n• Share information with healthcare providers\n• Receive notifications and updates"
                )
                
                termsSection(
                    title: "3. User Responsibilities",
                    content: "As a user of MedNotes, you agree to:\n\n• Provide accurate and complete information\n• Maintain the security of your account\n• Not share your account credentials\n• Use the service in compliance with laws\n• Not misuse or abuse the service"
                )
                
                termsSection(
                    title: "4. Data and Privacy",
                    content: "• We collect and process data as described in our Privacy Policy\n• You retain ownership of your data\n• We implement security measures to protect your data\n• You consent to our data practices by using the service"
                )
                
                termsSection(
                    title: "5. Intellectual Property",
                    content: "• The service and its content are protected by intellectual property rights\n• You may not copy or reproduce any part of the service\n• You retain rights to your user-generated content"
                )
                
                termsSection(
                    title: "6. Disclaimer of Warranties",
                    content: "• The service is provided 'as is' without warranties\n• We do not guarantee uninterrupted or error-free service\n• We are not responsible for third-party content"
                )
                
                termsSection(
                    title: "7. Limitation of Liability",
                    content: "• We are not liable for indirect or consequential damages\n• Our liability is limited to the amount paid for the service\n• We are not liable for user-generated content"
                )
                
                termsSection(
                    title: "8. Third-Party Services",
                    content: "• The service may contain links to third-party services\n• We are not responsible for third-party services\n• Your use of third-party services is at your own risk"
                )
                
                termsSection(
                    title: "9. Governing Law",
                    content: "These terms are governed by the laws of the jurisdiction in which we operate."
                )
                
                termsSection(
                    title: "10. Termination",
                    content: "• We may terminate or suspend your account\n• You may terminate your account at any time\n• Upon termination, your data will be handled according to our policies"
                )
                
                termsSection(
                    title: "11. Changes to Terms",
                    content: "We may modify these terms at any time. We will notify you of significant changes."
                )
            }
            .padding()
        }
        .background(backgroundColor)
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(textColor)
            }
        }
    }
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
            
            Text(content)
                .font(.body)
                .foregroundColor(textColor)
        }
    }
}

#Preview {
    NavigationView {
        TermsOfServiceView()
    }
} 