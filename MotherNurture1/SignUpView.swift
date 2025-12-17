//
//  SignUpView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var email: String = ""
    @State private var showDatePicker: Bool = false
    @State private var navigateToWelcome = false

    // Password fields
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    @State private var validationError: String? = nil
    @State private var isSubmitting: Bool = false
    @State private var showEULA: Bool = false
    @State private var hasAcceptedEULA: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color (beige to match other screens)
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    // Back button
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "8B9A7E"))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Title
                    Text("Sign Up")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    
                    Spacer()
                    
                    // Spacer to balance the back button
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Create your account")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .padding(.bottom, 2)

                            // First Name Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("First Name")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                TextField("Enter your first name", text: $firstName)
                                    .textFieldStyle(SignUpTextFieldStyle())
                                    .textContentType(.givenName)
                            }

                            // Last Name Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Last Name")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                TextField("Enter your last name", text: $lastName)
                                    .textFieldStyle(SignUpTextFieldStyle())
                                    .textContentType(.familyName)
                            }

                            // Date of Birth Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Date of Birth")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showDatePicker.toggle()
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "calendar")
                                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))

                                        Text(dateFormatter.string(from: dateOfBirth))
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(Color(hex: "3C2A1E"))

                                        Spacer()

                                        Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "E8E1D7"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())

                                if showDatePicker {
                                    DatePicker(
                                        "Date of Birth",
                                        selection: $dateOfBirth,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.compact)
                                    .accentColor(Color(hex: "5C3D2E"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "E8E1D7"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                                }
                            }

                            // Email Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))

                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(SignUpTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .textContentType(.emailAddress)
                            }

                            // Password Fields with clear labels and requirement text
                            VStack(alignment: .leading, spacing: 10) {
                                // Create Password with Show/Hide
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Create Password")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))

                                    PasswordField(
                                        title: "At least 6 characters",
                                        text: $password,
                                        isVisible: $isPasswordVisible
                                    )
                                }

                                // Confirm Password with Show/Hide
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Confirm Password")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))

                                    PasswordField(
                                        title: "Re-enter your password",
                                        text: $confirmPassword,
                                        isVisible: $isConfirmPasswordVisible
                                    )
                                }

                                Text("Passwords must be at least 6 characters long.")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.85))
                            }

                            // EULA Acceptance
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 12) {
                                    Button(action: {
                                        hasAcceptedEULA.toggle()
                                    }) {
                                        Image(systemName: hasAcceptedEULA ? "checkmark.square.fill" : "square")
                                            .foregroundColor(hasAcceptedEULA ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E"))
                                            .font(.system(size: 20))
                                    }
                                    .buttonStyle(.plain)

                                    HStack(spacing: 4) {
                                        Text("I agree to the")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                        Button(action: {
                                            showEULA = true
                                        }) {
                                            Text("Terms of Service")
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color(hex: "8B9A7E"))
                                                .underline()
                                        }
                                    }
                                }

                                if !hasAcceptedEULA && !validationError.isNilOrEmpty {
                                    Text("You must accept the Terms of Service to continue")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.top, 2)

                            // Validation error
                            if let validationError = validationError {
                                Text(validationError)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.red.opacity(0.08))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(18)
                        .background(Color(hex: "FDFBF6"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(hex: "5C3D2E").opacity(0.10), lineWidth: 1)
                        )
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 30)
                }
                
                // Sign Up Button
                Button(action: handleSignUpTapped) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "8B9A7E"))
                            .cornerRadius(12)
                    } else {
                        Text("Sign up")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "8B9A7E"))
                            .cornerRadius(12)
                            .opacity(canSubmit ? 1.0 : 0.6)
                    }
                }
                .disabled(!canSubmit || isSubmitting)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                }
                .navigationDestination(isPresented: $navigateToWelcome) {
                    WelcomeView()
                        .environmentObject(userDataManager)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showEULA) {
                EULAView(isPresented: $showEULA, hasAccepted: $hasAcceptedEULA)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }

    private var canSubmit: Bool {
        // Basic checks; you can expand with email format checks as needed
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password.count >= 6 &&
        confirmPassword == password &&
        hasAcceptedEULA
    }

    private func handleSignUpTapped() {
        validationError = nil

        // Validate
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationError = "Please enter your email."
            return
        }
        guard password.count >= 6 else {
            validationError = "Password must be at least 6 characters."
            return
        }
        guard confirmPassword == password else {
            validationError = "Passwords do not match."
            return
        }
        guard hasAcceptedEULA else {
            validationError = "You must accept the Terms of Service to continue."
            return
        }

        // Save sign-up data to UserDataManager profile
        userDataManager.profile.firstName = firstName.isEmpty ? nil : firstName
        userDataManager.profile.lastName = lastName.isEmpty ? nil : lastName
        userDataManager.profile.dateOfBirth = dateOfBirth
        userDataManager.profile.email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Authenticate user with Firebase Anonymous Auth and create account
        isSubmitting = true
        Task {
            do {
                print("🚀 ========== STARTING SIGN UP PROCESS ==========")
                let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                print("📧 Email: \(trimmedEmail)")
                
                // Check if email already exists
                // Note: This requires authentication, so we'll authenticate anonymously first if needed
                print("🔍 Step 1: Checking if email exists...")
                do {
                    // Ensure we're authenticated before checking email
                    if !FirebaseService.shared.isAuthenticated() {
                        print("⚠️ Not authenticated, signing in anonymously for email check...")
                        _ = try await FirebaseService.shared.signInAnonymously()
                        // Small delay to ensure auth state is established
                        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                    }
                    
                    let emailExists = await userDataManager.profileExists(email: trimmedEmail)
                    if emailExists {
                        print("❌ Email already exists")
                        await MainActor.run {
                            isSubmitting = false
                            validationError = "An account with this email already exists. Please log in instead."
                        }
                        return
                    }
                    print("✅ Email is available")
                } catch {
                    print("⚠️ Error checking email existence (continuing with sign up): \(error)")
                    // Continue with sign up even if email check fails
                    // The save operation will handle duplicate email errors
                }
                
                // Sign out any existing session before creating new account
                print("🔍 Step 2: Checking for existing authentication...")
                if FirebaseService.shared.isAuthenticated() {
                    print("⚠️ Existing session found, signing out...")
                    do {
                        try FirebaseService.shared.signOut()
                        print("✅ Signed out successfully")
                        // Small delay to ensure sign out completes
                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                    } catch {
                        print("⚠️ Error signing out (continuing anyway): \(error)")
                    }
                } else {
                    print("✅ No existing session")
                }
                
                // Now sign in anonymously for the new account
                print("🔍 Step 2.5: Signing in anonymously for new account...")
                do {
                    let newUserID = try await FirebaseService.shared.signInAnonymously()
                    print("✅ Signed in anonymously with ID: \(newUserID)")
                    // Small delay to ensure auth state is established
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                } catch {
                    print("❌ Failed to sign in anonymously: \(error)")
                    await MainActor.run {
                        isSubmitting = false
                        if let nsError = error as NSError?,
                           nsError.domain.contains("FIRAuthErrorDomain") || nsError.domain.contains("Auth"),
                           let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
                            if authErrorCode == .operationNotAllowed {
                                validationError = "Anonymous authentication is not enabled. Please enable it in Firebase Console: Authentication → Sign-in method → Anonymous"
                            } else if authErrorCode == .networkError {
                                validationError = "Network error. Please check your internet connection and try again."
                            } else {
                                validationError = "Authentication error. Please try again."
                            }
                        } else {
                            validationError = "Failed to create account. Please try again."
                        }
                    }
                    return
                }
                
                // Ensure profile data is set before saving
                print("🔍 Step 3: Setting profile data...")
                userDataManager.profile.firstName = firstName.isEmpty ? nil : firstName
                userDataManager.profile.lastName = lastName.isEmpty ? nil : lastName
                userDataManager.profile.dateOfBirth = dateOfBirth
                userDataManager.profile.email = trimmedEmail
                
                // Hash and store password
                userDataManager.profile.passwordHash = UserProfile.hashPassword(password)
                
                // Ensure createdAt is set
                if userDataManager.profile.createdAt == nil {
                    userDataManager.profile.createdAt = Timestamp(date: Date())
                }
                
                print("   ✅ First Name: \(userDataManager.profile.firstName ?? "nil")")
                print("   ✅ Last Name: \(userDataManager.profile.lastName ?? "nil")")
                print("   ✅ Email: \(userDataManager.profile.email ?? "nil")")
                print("   ✅ Password Hash: set")
                print("   ✅ CreatedAt: \(userDataManager.profile.createdAt != nil ? "set" : "nil")")
                
                // Save the profile to Firebase (this will authenticate anonymously if needed)
                // Don't set isAuthenticated yet - wait until questionnaire is complete
                print("🔍 Step 4: Saving to Firebase...")
                try await userDataManager.saveToFirebase(setAuthenticated: false)
                print("✅ saveToFirebase completed successfully")
                print("🎉 ========== SIGN UP SUCCESSFUL ==========")
                
                await MainActor.run {
                    isSubmitting = false
                    navigateToWelcome = true
                }
            } catch {
                // Print detailed error information
                print("❌ ========== SIGN UP ERROR ==========")
                print("Error type: \(type(of: error))")
                print("Error description: \(error.localizedDescription)")
                
                let nsError = error as NSError
                print("Error domain: \(nsError.domain)")
                print("Error code: \(nsError.code)")
                print("Error userInfo: \(nsError.userInfo)")
                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                    print("Underlying error domain: \(underlyingError.domain)")
                    print("Underlying error code: \(underlyingError.code)")
                    print("Underlying error description: \(underlyingError.localizedDescription)")
                }
                
                // Check for Firebase Auth specific errors
                if nsError.domain.contains("FIRAuthErrorDomain") || nsError.domain.contains("Auth") {
                    if let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
                        print("Firebase Auth Error Code: \(authErrorCode.rawValue)")
                        if authErrorCode == .operationNotAllowed {
                            print("⚠️ Anonymous authentication is not enabled!")
                        }
                    }
                }
                
                print("=====================================")
                
                await MainActor.run {
                    isSubmitting = false
                    let errorMessage = error.localizedDescription.lowercased()
                    
                    // Check for specific Firebase Auth and Firestore errors
                    let nsError = error as NSError
                    
                    // Firebase Auth errors
                    if nsError.domain.contains("FIRAuthErrorDomain") || nsError.domain.contains("Auth") {
                        if let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
                            switch authErrorCode {
                            case .operationNotAllowed:
                                validationError = "Anonymous authentication is not enabled. Please enable it in Firebase Console: Authentication → Sign-in method → Anonymous"
                            case .networkError:
                                validationError = "Network error. Please check your internet connection and try again."
                            case .internalError:
                                validationError = "Authentication error. Please verify Anonymous sign-in is enabled and try again."
                            case .emailAlreadyInUse:
                                validationError = "An account with this email already exists. Please log in instead."
                            default:
                                validationError = "Sign up failed. Please try again. If the problem persists, check your internet connection."
                            }
                        } else {
                            validationError = "Sign up failed. Please try again. If the problem persists, check your internet connection."
                        }
                    }
                    // Firestore errors
                    else if nsError.domain.contains("FIRFirestoreErrorDomain") {
                        switch nsError.code {
                        case 7:
                            validationError = "Permission denied. Check your Firestore security rules for /users/{userId}."
                        case 14:
                            validationError = "Firestore unavailable. Check your network connection and try again."
                        case 13:
                            validationError = "Firestore internal error. This may be temporary. Try again later."
                        default:
                            validationError = "Failed to save profile. Please try again."
                        }
                    }
                    // Generic error messages
                    else if errorMessage.contains("network") || errorMessage.contains("unavailable") {
                        validationError = "Network error. Please check your connection and try again."
                    } else if errorMessage.contains("permission") || errorMessage.contains("insufficient") {
                        validationError = "Permission denied. Please check your Firebase security rules."
                    } else if errorMessage.contains("already exists") || errorMessage.contains("already in use") || errorMessage.contains("email") && errorMessage.contains("use") {
                        validationError = "An account with this email already exists. Please log in instead."
                    } else {
                        // Generic fallback - never show "login failed" on sign up screen
                        validationError = "Failed to create account. Please try again. If the problem persists, check your internet connection."
                    }
                }
            }
        }
    }
}

// Reuse the same PasswordField style used on ContentView
private struct PasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack {
            if isVisible {
                TextField(title, text: $text)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color(hex: "3C2A1E"))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            } else {
                SecureField(title, text: $text)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color(hex: "3C2A1E"))
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
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(hex: "E8E1D7"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// Custom TextField Style for Sign Up
struct SignUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(hex: "E8E1D7")) // Light brown background
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "5C3D2E").opacity(0.12), lineWidth: 1)
            )
            .cornerRadius(12)
            .foregroundColor(Color(hex: "3C2A1E"))
            .font(.system(size: 16, design: .rounded))
    }
}

// Helper extension for optional string
extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self == nil || self!.isEmpty
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(UserDataManager.shared)
    }
}
