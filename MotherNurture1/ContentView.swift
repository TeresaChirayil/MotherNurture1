//
//  ContentView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var navigateToChannels = false
    @State private var navigateToSignUp = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var loginError: String? = nil
    @State private var isLoggingIn: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var showResetPassword: Bool = false
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isResettingPassword: Bool = false
    @State private var resetSuccess: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                    .onTapGesture { dismissKeyboard() }
                
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 30) {
                                Spacer()
                                    .frame(height: 40)
                                
                                // Logo
                                Image("myLogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 180, height: 200)
                                
                                // App Title
                                Text("MotherNurture")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                // Input Fields
                                VStack(spacing: 15) {
                                    TextField("Email", text: $email)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                    
                                    // Password field with Show/Hide toggle
                                    PasswordField(
                                        title: "Password",
                                        text: $password,
                                        isVisible: $isPasswordVisible
                                    )
                                }
                                .padding(.horizontal, 40)
                                
                                if let loginError = loginError {
                                    Text(loginError)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 40)
                                }
                                
                                // New User link and Sign Up button
                                VStack(alignment: .center, spacing: 10) {
                                    Button(action: {
                                        navigateToSignUp = true
                                    }) {
                                        Text("New User?")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                            .underline()
                                    }
                                    
                                    Button(action: handleLogin) {
                                        if isLoggingIn {
                                            ProgressView()
                                                .tint(Color(hex: "5C3D2E"))
                                                .frame(width: 100, height: 44)
                                        } else {
                                            Text("Log in")
                                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                .frame(width: 100, height: 44)
                                                .background(Color(hex: "9BA897"))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .disabled(isLoggingIn || email.isEmpty)
                                    
                                    Button(action: {
                                        if email.isEmpty {
                                            loginError = "Please enter your email first."
                                        } else {
                                            showResetPassword = true
                                        }
                                    }) {
                                        Text("Forgot Password?")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                            .underline()
                                    }
                                }
                                .padding(.bottom, 40)
                            }
                            .padding(.top, 0)
                            .contentShape(Rectangle())
                        }
                        // Dismiss keyboard when dragging
                        .gesture(DragGesture().onChanged { _ in dismissKeyboard() })
                        // Keep content visible above the keyboard
                        .padding(.bottom, keyboardHeightSafeInset(forViewHeight: geo.size.height))
                    }
                }
            }
            // Important: do not allow navigation to ChannelsView from here based on a local flag.
            // App root switches to ChannelsView when userDataManager.isAuthenticated becomes true.
            .navigationDestination(isPresented: $navigateToSignUp) {
                TutorialView()
                    .environmentObject(userDataManager)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true) // Prevent back navigation from login
            .onAppear { startObservingKeyboard() }
            .onDisappear { stopObservingKeyboard() }
            .sheet(isPresented: $showResetPassword) {
                resetPasswordSheet
            }
            .alert("Password Reset", isPresented: $resetSuccess) {
                Button("OK") { }
            } message: {
                Text("Your password has been reset. You can now log in with your new password.")
            }
        }
    }
    
    private var resetPasswordSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .padding(.top, 20)
                
                Text("Enter a new password for:\n\(email)")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                .padding(.horizontal, 40)
                
                if newPassword != confirmPassword && !confirmPassword.isEmpty {
                    Text("Passwords don't match")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.red)
                }
                
                Button(action: handleResetPassword) {
                    if isResettingPassword {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    } else {
                        Text("Reset Password")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
                .background(Color(hex: "8B9A7E"))
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .disabled(newPassword.isEmpty || newPassword != confirmPassword || isResettingPassword)
                .opacity(newPassword.isEmpty || newPassword != confirmPassword ? 0.5 : 1)
                
                Spacer()
            }
            .background(Color(hex: "F8F5EE").ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newPassword = ""
                        confirmPassword = ""
                        showResetPassword = false
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                }
            }
        }
    }
    
    private func handleResetPassword() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedEmail.isEmpty else { return }
        guard newPassword == confirmPassword else { return }
        guard newPassword.count >= 4 else {
            loginError = "Password must be at least 4 characters."
            return
        }
        
        isResettingPassword = true
        
        Task {
            do {
                // First authenticate if needed
                if !FirebaseService.shared.isAuthenticated() {
                    _ = try await FirebaseService.shared.signInAnonymously()
                }
                
                let candidates = try await FirebaseService.shared.getUserProfilesByEmail(email: trimmedEmail)
                if candidates.count > 1 {
                    throw NSError(domain: "ContentView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Multiple accounts were found for this email. Password reset is blocked to prevent changing the wrong account."])
                }

                // Find the user by email
                if let profile = candidates.first {
                    guard let userID = profile.userID else {
                        throw NSError(domain: "ContentView", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])
                    }
                    
                    // Update the password hash
                    let newHash = UserProfile.hashPassword(newPassword)
                    try await FirebaseService.shared.updateUserProfile(userID: userID, data: ["passwordHash": newHash])
                    
                    await MainActor.run {
                        isResettingPassword = false
                        showResetPassword = false
                        newPassword = ""
                        confirmPassword = ""
                        password = "" // Clear the password field so user enters new one
                        resetSuccess = true
                    }
                    print("✅ Password reset successful for \(trimmedEmail)")
                } else {
                    await MainActor.run {
                        isResettingPassword = false
                        loginError = "No account found for this email."
                        showResetPassword = false
                    }
                }
            } catch {
                await MainActor.run {
                    isResettingPassword = false
                    loginError = "Failed to reset password: \(error.localizedDescription)"
                    showResetPassword = false
                }
                print("❌ Password reset error: \(error)")
            }
        }
    }
    
    private func handleLogin() {
        loginError = nil
        guard !email.isEmpty else {
            loginError = "Please enter your email."
            return
        }
        
        guard !password.isEmpty else {
            loginError = "Please enter your password."
            return
        }
        
        // Normalize email (trim and lowercase)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedEmail.isEmpty else {
            loginError = "Please enter a valid email."
            return
        }
        
        isLoggingIn = true
        Task {
            do {
                // Reset any stale profile state before attempting login
                // This ensures a fresh start for each login attempt
                await MainActor.run {
                    userDataManager.profile = UserProfile()
                }
                
                // Load profile from Firebase with password verification
                // This will authenticate first, then query for the profile and verify password
                try await userDataManager.loadProfileFromFirebase(email: trimmedEmail, password: password)
                await MainActor.run {
                    isLoggingIn = false
                    // If we get here without error, authentication succeeded
                    // The error handling in loadProfileFromFirebase will throw if profile not found
                }
            } catch let error as NSError {
                await MainActor.run {
                    isLoggingIn = false
                    // Use the specific error message from loadProfileFromFirebase
                    if let errorMessage = error.userInfo[NSLocalizedDescriptionKey] as? String {
                        loginError = errorMessage
                    } else {
                        loginError = "Login failed. Please try again."
                    }
                }
                print("❌ Error loading profile: \(error)")
                print("   Domain: \(error.domain)")
                print("   Code: \(error.code)")
                print("   UserInfo: \(error.userInfo)")
            } catch {
                await MainActor.run {
                    isLoggingIn = false
                    loginError = "Login failed. Please try again."
                }
                print("❌ Unexpected error type: \(error)")
            }
        }
    }
    
    // Convert keyboard height to padding that feels natural
    // We compute overlap relative to the current view height passed in.
    private func keyboardHeightSafeInset(forViewHeight viewHeight: CGFloat) -> CGFloat {
        // keyboardHeight is the absolute overlap from bottom of the screen.
        // Since we avoid UIScreen.main, we just use the measured overlap value directly.
        // The -10 keeps a little breathing room like before.
        max(0, keyboardHeight - 10)
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    // MARK: - Keyboard Observing
    private func startObservingKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard
                let userInfo = notification.userInfo,
                let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double),
                let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt)
            else { return }
            
            // Convert keyboard frame to the current key window coordinate space and measure overlap
            let keyboardEndY = endFrame.origin.y
            // keyWindowScene-safe: use the screen height from the frame itself (no UIScreen.main)
            let screenHeightFromFrame = endFrame.maxY > 0 ? max(endFrame.maxY, keyboardEndY) : UIScreen.main.bounds.height
            // Note: endFrame is in screen coordinates; overlap is distance from bottom
            let newHeight = max(0, screenHeightFromFrame - keyboardEndY)
            
            let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
            UIView.animate(withDuration: duration, delay: 0, options: options) {
                self.keyboardHeight = newHeight
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.keyboardHeight = 0
        }
    }
    
    private func stopObservingKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - PasswordField (with Show/Hide toggle matching your style)
private struct PasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack {
            if isVisible {
                TextField(title, text: $text)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            } else {
                SecureField(title, text: $text)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
            }
            
            Button(action: { isVisible.toggle() }) {
                Text(isVisible ? "Hide" : "Show")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(hex: "F8F5EE").opacity(0.4))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(hex: "9BA897"))
        .cornerRadius(8)
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "9BA897"))
            .cornerRadius(8)
            .foregroundColor(Color(hex: "5C3D2E"))
            .font(.system(size: 16, design: .rounded))
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(UserDataManager.shared)
}
