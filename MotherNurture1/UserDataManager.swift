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
    
    private let firebaseService = FirebaseService.shared
    
    private init() {
        self.profile = UserProfile()
        // Check if user is already authenticated on init
        checkAuthStatus()
    }
    
    private func checkAuthStatus() {
        if let currentUser = Auth.auth().currentUser {
            self.profile.userID = currentUser.uid
            self.isAuthenticated = true
        }
    }
    
    func saveToFirebase() async throws {
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
        
        // Mark authenticated after a successful save
        DispatchQueue.main.async {
            self.isAuthenticated = true
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
        // Sign out from Firebase Auth
        try? firebaseService.signOut()
    }
    
    // -----------------------------------------------------
    // MARK: - Load Profile from Firebase
    // -----------------------------------------------------
    func loadProfileFromFirebase(userID: String? = nil, email: String? = nil) async throws {
        var loadedProfile: UserProfile?
        
        if let userID = userID ?? profile.userID {
            // Load by userID if available
            loadedProfile = try await firebaseService.getUserProfile(userID: userID)
        } else if let email = email ?? profile.email {
            // Load by email if userID not available
            loadedProfile = try await firebaseService.getUserProfileByEmail(email: email)
        }
        
        if let loadedProfile = loadedProfile {
            // Ensure user is authenticated with Firebase Auth
            // If not authenticated, sign in anonymously
            if !firebaseService.isAuthenticated() {
                _ = try await firebaseService.signInAnonymously()
            }
            
            DispatchQueue.main.async {
                self.profile = loadedProfile
                self.isAuthenticated = true
            }
            print("✅ Successfully loaded profile from Firebase")
        } else {
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
            print("⚠️ No profile found in Firebase")
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
}

