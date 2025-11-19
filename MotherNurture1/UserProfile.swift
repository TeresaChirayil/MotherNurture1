//
//  UserProfile.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable {
    // Sign Up Information
    var firstName: String?
    var lastName: String?
    var dateOfBirth: Date?
    var email: String?
    var phoneNumber: String?
    
    // Location
    var zipcode: String?
    var town: String?
    
    // Parenting Stage
    var parentingStage: String? // "Expecting", "Have children", "Both"
    
    // Family Info
    var numberOfChildren: Int?
    var childAges: [Int]?
    
    // About You
    var ageRange: String? // "18-21", "22-25", "26-29", "30+"
    var parentTags: [String]? // ["First-time Parent", "Single parent", etc.]
    
    // Interests and Hobbies
    var interests: [String]?
    
    // Connection Preference
    var connectionPreference: String? // "1-on-1", "Small Circle", "Both"
    
    // Special Needs Preference
    var specialNeedsPreference: String?
    
    // Language Preferences
    var languages: [String]?
    var otherLanguage: String?
    
    // Final Touch
    var shortDescription: String?
    var photoURL: String?
    
    // Metadata
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var userID: String?
    
    // Channel Memberships
    var channelMemberships: [String]? // Array of channel names the user belongs to
    
    init() {
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
    }
    
    // Determine which channels this user should be in based on questionnaire responses
    mutating func assignChannels() {
        var channels: [String] = []
        
        // Everyone gets added to "Get to Know Each Other!"
        channels.append("Get to Know Each Other!")
        
        // Check for "Expecting Moms"
        if let parentingStage = parentingStage {
            if parentingStage == "Expecting" || parentingStage == "Both" {
                channels.append("Expecting Moms")
            }
        }
        
        // Check for "Single Moms"
        if let parentTags = parentTags {
            if parentTags.contains("Single parent") {
                channels.append("Single Moms")
            }
            
            // Check for "Mothers of Children with Disabilities"
            if parentTags.contains("Parent of disabled child(ren)") {
                channels.append("Mothers of Children with Disabilities")
            }
        }
        
        // Also check specialNeedsPreference for disabilities
        if let specialNeedsPreference = specialNeedsPreference {
            // Check if user has a child with a specific condition or wants to connect with special needs parents
            if specialNeedsPreference.contains("specific condition") || 
               specialNeedsPreference.contains("connect with parents of children with special needs") {
                if !channels.contains("Mothers of Children with Disabilities") {
                    channels.append("Mothers of Children with Disabilities")
                }
            }
        }
        
        self.channelMemberships = channels
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let firstName = firstName { dict["firstName"] = firstName }
        if let lastName = lastName { dict["lastName"] = lastName }
        if let dateOfBirth = dateOfBirth { dict["dateOfBirth"] = Timestamp(date: dateOfBirth) }
        if let email = email { dict["email"] = email }
        if let phoneNumber = phoneNumber { dict["phoneNumber"] = phoneNumber }
        if let zipcode = zipcode { dict["zipcode"] = zipcode }
        if let town = town { dict["town"] = town }
        if let parentingStage = parentingStage { dict["parentingStage"] = parentingStage }
        if let numberOfChildren = numberOfChildren { dict["numberOfChildren"] = numberOfChildren }
        if let childAges = childAges { dict["childAges"] = childAges }
        if let ageRange = ageRange { dict["ageRange"] = ageRange }
        if let parentTags = parentTags { dict["parentTags"] = parentTags }
        if let interests = interests { dict["interests"] = interests }
        if let connectionPreference = connectionPreference { dict["connectionPreference"] = connectionPreference }
        if let specialNeedsPreference = specialNeedsPreference { dict["specialNeedsPreference"] = specialNeedsPreference }
        if let languages = languages { dict["languages"] = languages }
        if let otherLanguage = otherLanguage { dict["otherLanguage"] = otherLanguage }
        if let shortDescription = shortDescription { dict["shortDescription"] = shortDescription }
        if let photoURL = photoURL { dict["photoURL"] = photoURL }
        if let createdAt = createdAt { dict["createdAt"] = createdAt }
        if let updatedAt = updatedAt { dict["updatedAt"] = updatedAt }
        if let userID = userID { dict["userID"] = userID }
        if let channelMemberships = channelMemberships { dict["channelMemberships"] = channelMemberships }
        
        return dict
    }
}

