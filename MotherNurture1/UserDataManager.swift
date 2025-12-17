//
//  UserDataManager.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class UserDataManager: ObservableObject {
    static let shared = UserDataManager()
    
    @Published var profile: UserProfile
    @Published var isAuthenticated: Bool = false

    var authUserID: String? {
        Auth.auth().currentUser?.uid
    }
    
    private let firebaseService = FirebaseService.shared
    
    private init() {
        self.profile = UserProfile()
        // Start with isAuthenticated = false to always show login screen
        // User must explicitly log in through ContentView
        self.isAuthenticated = false
    }
    
    private func checkAuthStatus() {
        if let currentUser = Auth.auth().currentUser {
            self.profile.userID = currentUser.uid
            self.isAuthenticated = true
        }
    }
    
    func saveToFirebase(setAuthenticated: Bool = true) async throws {
        print("📝 Starting saveToFirebase...")
        print("Profile email: \(profile.email ?? "nil")")
        print("Profile userID: \(profile.userID ?? "nil")")
        
        // Ensure user is authenticated with Firebase Auth
        var userID: String
        if let currentUserID = firebaseService.getCurrentUserID() {
            print("✅ User already authenticated: \(currentUserID)")
            userID = currentUserID
        } else {
            print("🔐 No authenticated user, signing in anonymously...")
            do {
                userID = try await firebaseService.signInAnonymously()
                print("✅ Successfully signed in anonymously: \(userID)")
                
                // Small delay to ensure auth state is fully established
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                
                // Verify auth state is established
                if Auth.auth().currentUser?.uid != userID {
                    print("⚠️ Auth state mismatch, waiting a bit more...")
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 more seconds
                }
                
                print("✅ Auth state verified: \(Auth.auth().currentUser?.uid ?? "nil")")
            } catch {
                print("❌ Error signing in anonymously: \(error)")
                throw error
            }
        }
        
        // Set the userID in the profile
        profile.userID = userID
        print("📝 Profile userID set to: \(userID)")
        
        // Verify we have required data
        guard profile.email != nil && !profile.email!.isEmpty else {
            let error = NSError(
                domain: "UserDataManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Email is required to save profile"]
            )
            print("❌ Profile email is missing!")
            throw error
        }
        
        // Assign channels based on questionnaire responses
        profile.assignChannels()
        print("📝 Channels assigned: \(profile.channelMemberships ?? [])")
        
        // Save or update the profile in Firebase
        print("💾 Saving profile to Firebase...")
        do {
            let savedUserID = try await firebaseService.saveUserProfile(profile)
            print("✅ Profile saved successfully with userID: \(savedUserID)")
            
            // Ensure userID is set
            profile.userID = savedUserID
        
            // Mark authenticated after a successful save (only if setAuthenticated is true)
            if setAuthenticated {
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
            }
            
            // Add user to their assigned channels in Firebase
            if let channelMemberships = profile.channelMemberships {
                print("📝 Adding user to \(channelMemberships.count) channels...")
                for channelName in channelMemberships {
                    do {
                        try await firebaseService.addUserToChannel(userID: savedUserID, channelName: channelName)
                        print("✅ Added to channel: \(channelName)")
                    } catch {
                        print("⚠️ Error adding user to channel \(channelName): \(error)")
                        // Continue with other channels even if one fails
                    }
                }
            }
            
            // Auto-join the welcome channel "Get to Know Each Other!"
            do {
                try await firebaseService.joinWelcomeChannel(userID: savedUserID)
                print("✅ Joined welcome channel")
            } catch {
                print("⚠️ Error joining welcome channel: \(error)")
            }
        } catch {
            print("❌ Error saving profile to Firebase: \(error)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            throw error
        }
    }
    
    func reset() {
        profile = UserProfile()
        isAuthenticated = false
    }
    
    // -----------------------------------------------------
    // MARK: - Load Profile from Firebase
    // -----------------------------------------------------
    func loadProfileFromFirebase(userID: String? = nil, email: String? = nil, password: String? = nil) async throws {
        // CRITICAL: Authenticate FIRST before querying Firestore
        // Firestore security rules require authentication to read user profiles
        if !firebaseService.isAuthenticated() {
            print("🔐 Not authenticated, signing in anonymously to enable Firestore access...")
            do {
                _ = try await firebaseService.signInAnonymously()
                print("✅ Authenticated successfully")
                // Small delay to ensure auth state is fully established
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            } catch {
                print("❌ Failed to authenticate: \(error)")
                throw NSError(
                    domain: "UserDataManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Authentication failed. Please check your internet connection and try again."]
                )
            }
        } else {
            print("✅ Already authenticated")
        }
        
        // Now query Firestore (we're authenticated, so this will work)
        var loadedProfile: UserProfile?
        
        do {
            // Prioritize the explicitly provided parameters over stored profile values
            // This ensures retry attempts use the new input, not stale data
            if let userID = userID {
                // Load by userID if explicitly provided
                print("🔍 Loading profile by userID: \(userID)")
                loadedProfile = try await firebaseService.getUserProfile(userID: userID)
            } else if let email = email {
                // Load by email if explicitly provided
                print("🔍 Loading profile by email: \(email)")
                loadedProfile = try await firebaseService.getUserProfileByEmail(email: email)
            } else if let storedUserID = profile.userID {
                // Fall back to stored userID
                print("🔍 Loading profile by stored userID: \(storedUserID)")
                loadedProfile = try await firebaseService.getUserProfile(userID: storedUserID)
            } else if let storedEmail = profile.email {
                // Fall back to stored email
                print("🔍 Loading profile by stored email: \(storedEmail)")
                loadedProfile = try await firebaseService.getUserProfileByEmail(email: storedEmail)
            } else {
                throw NSError(
                    domain: "UserDataManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No userID or email provided"]
                )
            }
        } catch let error as NSError {
            // Provide more specific error messages
            if error.domain.contains("FIRFirestoreErrorDomain") || error.domain.contains("Firestore") {
                if error.code == 7 { // Permission denied
                    print("❌ Permission denied - this should not happen if authentication succeeded")
                    throw NSError(
                        domain: "UserDataManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Permission denied. Please try again."]
                    )
                } else if error.code == 14 { // Unavailable
                    print("❌ Firestore unavailable")
                    throw NSError(
                        domain: "UserDataManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Service unavailable. Please check your internet connection and try again."]
                    )
                }
            }
            // Re-throw other errors
            throw error
        }
        
        if let loadedProfile = loadedProfile {
            // Verify password if provided
            if let password = password {
                // Check if user has a password hash stored
                if loadedProfile.passwordHash != nil {
                    // User has password - verify it
                    guard loadedProfile.verifyPassword(password) else {
                        print("❌ Invalid password")
                        throw NSError(
                            domain: "UserDataManager",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Incorrect password. Please try again."]
                        )
                    }
                    print("✅ Password verified")
                } else {
                    // Legacy user without password - allow login and try to set their password
                    print("⚠️ Legacy user without password hash - allowing login")
                    // Try to save password hash but don't fail login if it doesn't work
                    if let userID = loadedProfile.userID {
                        do {
                            let newHash = UserProfile.hashPassword(password)
                            try await firebaseService.updateUserProfile(userID: userID, data: ["passwordHash": newHash])
                            print("✅ Password hash saved for legacy user")
                        } catch {
                            print("⚠️ Could not save password hash (will try again later): \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.profile = loadedProfile
                self.isAuthenticated = true
            }
            print("✅ Successfully loaded profile from Firebase")
            print("   UserID: \(loadedProfile.userID ?? "nil")")
            print("   Email: \(loadedProfile.email ?? "nil")")
            
            // Auto-join the welcome channel for existing users logging in
            if let userID = loadedProfile.userID {
                do {
                    try await firebaseService.joinWelcomeChannel(userID: userID)
                    print("✅ Ensured user is in welcome channel")
                } catch {
                    print("⚠️ Error joining welcome channel: \(error)")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
            print("⚠️ No profile found in Firebase")
            throw NSError(
                domain: "UserDataManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No account found for this email. Please create a new account."]
            )
        }
    }
    
    // -----------------------------------------------------
    // MARK: - Authenticate User (for sign up)
    // -----------------------------------------------------
    func authenticateUser() async throws {
        // Sign in anonymously to get Firebase Auth UID
        let userID = try await firebaseService.signInAnonymously()
        profile.userID = userID
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }
    
    // -----------------------------------------------------
    // MARK: - Check if Profile Exists
    // -----------------------------------------------------
    func profileExists(email: String) async -> Bool {
        do {
            let profile = try await firebaseService.getUserProfileByEmail(email: email)
            return profile != nil
        } catch {
            print("Error checking profile existence: \(error)")
            return false
        }
    }
    
    // -----------------------------------------------------
    // MARK: - Clear Profile (instance method)
    // -----------------------------------------------------
    func clearProfile() {
        // Reset in-memory profile
        self.profile = UserProfile()
        
        // If you persist profile to UserDefaults or Keychain, clear that too:
        UserDefaults.standard.removeObject(forKey: "userProfile") // if you use this key
        
        // Add any additional cleanup (e.g., local caches) here.
    }
    
    // -----------------------------------------------------
    // MARK: - Delete Account
    // -----------------------------------------------------
    func deleteAccount() async throws {
        guard let userID = profile.userID else {
            throw NSError(
                domain: "UserDataManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No userID found. Cannot delete account."]
            )
        }
        
        print("🗑️ Starting account deletion for user: \(userID)")
        
        // Delete user profile from Firestore
        try await firebaseService.deleteUserProfile(userID: userID)
        print("✅ User profile deleted from Firestore")
        
        // Delete Firebase Auth account (if it exists and is not anonymous)
        if let currentUser = Auth.auth().currentUser {
            // For anonymous users, we can just sign out
            // For email/password users, we need to delete the account
            if !currentUser.isAnonymous {
                do {
                    try await currentUser.delete()
                    print("✅ Firebase Auth account deleted")
                } catch {
                    print("⚠️ Could not delete Firebase Auth account: \(error.localizedDescription)")
                    // Continue with sign out even if deletion fails
                }
            }
            
            // Sign out from Firebase Auth
            try? firebaseService.signOut()
        }
        
        // Clear local profile and reset authentication state on main thread
        // This must happen on main thread for SwiftUI to observe the change
        await MainActor.run {
            // Clear profile first
            self.profile = UserProfile()
            
            // Then set authentication to false - this triggers the app to show login screen
            self.isAuthenticated = false
            
            print("✅ Authentication state reset")
            print("   isAuthenticated: \(self.isAuthenticated)")
            print("   profile.userID: \(self.profile.userID ?? "nil")")
            print("   profile.email: \(self.profile.email ?? "nil")")
        }
        
        // Small delay to ensure state propagation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        print("✅ Account deletion completed")
    }
}
