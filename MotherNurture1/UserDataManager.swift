//
//  UserDataManager.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import Foundation
import Combine
import FirebaseFirestore

class UserDataManager: ObservableObject {
    static let shared = UserDataManager()
    
    @Published var profile: UserProfile
    
    private let firebaseService = FirebaseService.shared
    
    
    
    private init() {
        self.profile = UserProfile()
    }
    
    func saveToFirebase() async throws {
        // Assign channels based on questionnaire responses
        profile.assignChannels()
        
        // Save or update the profile in Firebase
        let userID = try await firebaseService.saveUserProfile(profile)
        
        // Update the local profile with the userID if it was newly created
        if profile.userID == nil {
            profile.userID = userID
        }
        
        // Add user to their assigned channels in Firebase
        if let channelMemberships = profile.channelMemberships {
            for channelName in channelMemberships {
                do {
                    try await firebaseService.addUserToChannel(userID: userID, channelName: channelName)
                } catch {
                    print("⚠️ Error adding user to channel \(channelName): \(error)")
                    // Continue with other channels even if one fails
                }
            }
        }
    }
    
    func reset() {
        profile = UserProfile()
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
            self.profile = loadedProfile
            print("✅ Successfully loaded profile from Firebase")
        } else {
            print("⚠️ No profile found in Firebase")
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

