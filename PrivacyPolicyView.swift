import SwiftUI

struct PrivacyPolicyView: View {
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
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                
                Text("Last updated: April 2, 2025")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                privacySection(
                    title: "1. Information We Collect",
                    content: "We collect information that you provide directly to us, including:\n\n• Personal information (name, email address, phone number)\n• Health information (symptoms, medical history)\n• Location data (when enabled)\n• Usage data (app interactions, preferences)\n• Device information (device type, operating system)"
                )
                
                privacySection(
                    title: "2. How We Use Your Information",
                    content: "We use the collected information to:\n\n• Provide and improve our services\n• Generate personalized health insights\n• Send notifications and updates\n• Analyze app usage and trends\n• Comply with legal obligations"
                )
                
                privacySection(
                    title: "3. Data Storage and Security",
                    content: "• Your data is stored securely on our servers\n• We implement industry-standard security measures\n• Data is encrypted during transmission\n• Regular security audits are performed\n• Access to your data is strictly controlled"
                )
                
                privacySection(
                    title: "4. Data Sharing",
                    content: "We may share your information with:\n\n• Healthcare providers (with your consent)\n• Service providers who assist our operations\n• Law enforcement when required by law\n• Third parties for analytics and research"
                )
                
                privacySection(
                    title: "5. Your Rights",
                    content: "You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Request data deletion\n• Opt-out of data sharing\n• Export your data"
                )
                
                privacySection(
                    title: "6. Children's Privacy",
                    content: "Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13."
                )
                
                privacySection(
                    title: "7. Changes to This Policy",
                    content: "We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the 'Last updated' date."
                )
            }
            .padding()
        }
        .background(backgroundColor)
        .navigationTitle("Privacy Policy")
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
    
    private func privacySection(title: String, content: String) -> some View {
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
        PrivacyPolicyView()
    }
} 