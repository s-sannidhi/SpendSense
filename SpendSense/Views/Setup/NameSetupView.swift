import SwiftUI

struct NameSetupView: View {
    @StateObject private var userStore = UserStore.shared
    @State private var firstName = ""
    @State private var lastName = ""
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What's Your Name?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text("Let us personalize your experience")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.givenName)
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.familyName)
            }
            .padding(.vertical)
            
            Button(action: {
                userStore.saveUserInfo(firstName: firstName, lastName: lastName)
                onComplete()
            }) {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(firstName.isEmpty || lastName.isEmpty)
        }
        .padding()
    }
} 