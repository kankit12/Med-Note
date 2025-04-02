import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var name: String = ""
    @State private var occupation: String = ""
    @State private var region: String = "United States"
    @State private var age: Int = 25
    @State private var gender: UserProfile.Gender = .preferNotToSay
    @State private var showingSaveConfirmation = false
    
    let regions = ["United States", "Canada", "United Kingdom", "Australia", "Germany", "France", "Japan", "India"]
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Your Name", text: $name)
                TextField("Occupation", text: $occupation)
                
                Picker("Region", selection: $region) {
                    ForEach(regions, id: \.self) { region in
                        Text(region).tag(region)
                    }
                }
                
                Stepper("Age: \(age)", value: $age, in: 1...120)
                
                Picker("Gender", selection: $gender) {
                    ForEach(UserProfile.Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
            }
            
            Section {
                Button(action: saveProfile) {
                    Text("Save Profile")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
                .disabled(name.isEmpty || occupation.isEmpty)
            }
            
            if appState.userProfile != nil {
                Section(header: Text("Current Profile")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name: \(appState.userProfile?.name ?? "")")
                        Text("Occupation: \(appState.userProfile?.occupation ?? "")")
                        Text("Region: \(appState.userProfile?.region ?? "")")
                        Text("Age: \(appState.userProfile?.age ?? 0)")
                        Text("Gender: \(appState.userProfile?.gender.rawValue ?? "")")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Profile")
        .onAppear {
            if let profile = appState.userProfile {
                name = profile.name
                occupation = profile.occupation
                region = profile.region
                age = profile.age
                gender = profile.gender
            }
        }
        .alert("Profile Saved", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your profile has been updated successfully.")
        }
    }
    
    private func saveProfile() {
        let profile = UserProfile(
            name: name,
            occupation: occupation,
            region: region,
            age: age,
            gender: gender
        )
        appState.updateProfile(profile)
        showingSaveConfirmation = true
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
} 