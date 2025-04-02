import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultRecipient") private var defaultRecipient = ""
    @AppStorage("locationEnabled") private var locationEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingProfile = false
    
    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                if let profile = appState.userProfile {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(profile.name)
                                .font(.headline)
                            Text(profile.occupation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Edit") {
                            showingProfile = true
                        }
                    }
                } else {
                    Button("Set Up Profile") {
                        showingProfile = true
                    }
                }
            }
            
            Section(header: Text("General")) {
                TextField("Default Note Recipient", text: $defaultRecipient)
                
                Toggle("Enable Location Services", isOn: $locationEnabled)
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                Toggle("Use System Mode", isOn: $appState.useSystemDarkMode)
                
                if !appState.useSystemDarkMode {
                    Toggle("Dark Mode", isOn: $appState.isDarkMode)
                }
            }
            
            Section(header: Text("Health Trends")) {
                NavigationLink(destination: LocationSettingsView()) {
                    Label("Location Settings", systemImage: "location")
                }
                
                NavigationLink(destination: NotificationSettingsView()) {
                    Label("Notification Settings", systemImage: "bell")
                }
            }
            
            Section(header: Text("Data")) {
                Button(action: {
                    appState.clearHistory()
                }) {
                    Label("Clear History", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                
                NavigationLink(destination: TermsOfServiceView()) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            }
            
            Section(header: Text("Support")) {
                Link(destination: URL(string: "https://mednotes.app/support")!) {
                    Label("Help Center", systemImage: "questionmark.circle")
                }
                
                Link(destination: URL(string: "mailto:support@mednotes.app")!) {
                    Label("Contact Support", systemImage: "envelope")
                }
                
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("MedNotes Team")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
}

struct LocationSettingsView: View {
    @AppStorage("selectedRegion") private var selectedRegion = "United States"
    
    var body: some View {
        Form {
            Section(header: Text("Region")) {
                Picker("Select Region", selection: $selectedRegion) {
                    Text("United States").tag("United States")
                    Text("Canada").tag("Canada")
                    Text("United Kingdom").tag("United Kingdom")
                    Text("Australia").tag("Australia")
                }
            }
            
            Section(header: Text("Location Services")) {
                Text("Enable location services to receive local health trend updates.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Location Settings")
    }
}

struct NotificationSettingsView: View {
    @AppStorage("trendAlerts") private var trendAlerts = true
    @AppStorage("reminderAlerts") private var reminderAlerts = true
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Health Trend Alerts", isOn: $trendAlerts)
                Toggle("Daily Reminders", isOn: $reminderAlerts)
            }
            
            Section(header: Text("Reminder Time")) {
                DatePicker("Daily Reminder", selection: .constant(Date()), displayedComponents: .hourAndMinute)
            }
        }
        .navigationTitle("Notification Settings")
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
} 