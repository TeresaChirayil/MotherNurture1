//
//  FirebaseService.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import Foundation
import FirebaseFirestore

class FirebaseService {

    static let shared = FirebaseService()
    let db = Firestore.firestore()

    private init() {}

    // -----------------------------------------------------
    // MARK: - Save User Profile
    // -----------------------------------------------------
    func saveUserProfile(_ profile: UserProfile) async throws -> String {
        var profileDict = profile.toDictionary()
        profileDict["updatedAt"] = Timestamp(date: Date())

        // Update if userID exists
        if let userID = profile.userID {
            try await db.collection("users").document(userID).setData(profileDict, merge: true)
            print("✅ Updated existing user profile")
            return userID
        }

        // Create a new document
        let docRef = try await db.collection("users").addDocument(data: profileDict)
        print("✅ Created new user profile")
        return docRef.documentID
    }

    // -----------------------------------------------------
    // MARK: - Update User Profile
    // -----------------------------------------------------
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard let userID = profile.userID else {
            throw NSError(domain: "FirebaseService",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No userID provided"])
        }

        var profileDict = profile.toDictionary()
        profileDict["updatedAt"] = Timestamp(date: Date())

        try await db.collection("users").document(userID).setData(profileDict, merge: true)
        print("✅ Successfully updated profile")
    }

    // -----------------------------------------------------
    // MARK: - Fetch User Profile
    // -----------------------------------------------------
    func getUserProfile(userID: String) async throws -> UserProfile? {
        let doc = try await db.collection("users").document(userID).getDocument()

        guard doc.exists, let data = doc.data() else { return nil }
        return parseUserProfile(from: data, userID: userID)
    }
    
    // -----------------------------------------------------
    // MARK: - Fetch User Profile by Email
    // -----------------------------------------------------
    func getUserProfileByEmail(email: String) async throws -> UserProfile? {
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments()
        
        guard let doc = snapshot.documents.first else { return nil }
        return parseUserProfile(from: doc.data(), userID: doc.documentID)
    }
    
    // -----------------------------------------------------
    // MARK: - Fetch User Profile by UserID (stored locally)
    // -----------------------------------------------------
    func loadUserProfile(userID: String) async throws -> UserProfile? {
        return try await getUserProfile(userID: userID)
    }

    // -----------------------------------------------------
    // MARK: - Add User to Channel
    // -----------------------------------------------------
    func addUserToChannel(userID: String, channelName: String) async throws {
        // Add user to the channel's members collection
        try await db.collection("channels")
            .document(channelName)
            .collection("members")
            .document(userID)
            .setData([
                "userID": userID,
                "joinedAt": Timestamp(date: Date())
            ])
        
        print("✅ Added user \(userID) to channel: \(channelName)")
    }
    
    // -----------------------------------------------------
    // MARK: - Get Channel Members
    // -----------------------------------------------------
    func getChannelMembers(channelName: String) async throws -> [String] {
        let snapshot = try await db.collection("channels")
            .document(channelName)
            .collection("members")
            .getDocuments()
        
        return snapshot.documents.map { $0.documentID }
    }
    
    // -----------------------------------------------------
    // MARK: - Parse Logic
    // -----------------------------------------------------
    private func parseUserProfile(from data: [String: Any], userID: String) -> UserProfile {
        var profile = UserProfile()
        profile.userID = userID

        profile.firstName = data["firstName"] as? String
        profile.lastName = data["lastName"] as? String

        if let ts = data["dateOfBirth"] as? Timestamp {
            profile.dateOfBirth = ts.dateValue()
        }

        profile.email = data["email"] as? String
        profile.phoneNumber = data["phoneNumber"] as? String
        profile.zipcode = data["zipcode"] as? String
        profile.town = data["town"] as? String
        profile.parentingStage = data["parentingStage"] as? String
        profile.numberOfChildren = data["numberOfChildren"] as? Int
        profile.childAges = data["childAges"] as? [Int]
        profile.ageRange = data["ageRange"] as? String
        profile.parentTags = data["parentTags"] as? [String]
        profile.interests = data["interests"] as? [String]
        profile.connectionPreference = data["connectionPreference"] as? String
        profile.specialNeedsPreference = data["specialNeedsPreference"] as? String
        profile.languages = data["languages"] as? [String]
        profile.otherLanguage = data["otherLanguage"] as? String
        profile.shortDescription = data["shortDescription"] as? String
        profile.photoURL = data["photoURL"] as? String
        profile.channelMemberships = data["channelMemberships"] as? [String]

        profile.createdAt = data["createdAt"] as? Timestamp
        profile.updatedAt = data["updatedAt"] as? Timestamp

        return profile
    }
    
    // -----------------------------------------------------
    // MARK: - Forum Posts
    // -----------------------------------------------------
    func createPost(_ post: ForumPost) async throws -> String {
        let postDict = post.toDictionary()
        let docRef = try await db.collection("forumPosts").addDocument(data: postDict)
        print("✅ Created new forum post")
        return docRef.documentID
    }
    
    func fetchPosts(limit: Int = 50) async throws -> [ForumPost] {
        let snapshot = try await db.collection("forumPosts")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            ForumPost.fromDictionary(doc.data(), id: doc.documentID)
        }
    }
    
    func fetchUserPosts(userID: String) async throws -> [ForumPost] {
        let snapshot = try await db.collection("forumPosts")
            .whereField("authorID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            ForumPost.fromDictionary(doc.data(), id: doc.documentID)
        }
    }
    
    func fetchPopularPosts(limit: Int = 50) async throws -> [ForumPost] {
        let snapshot = try await db.collection("forumPosts")
            .order(by: "likeCount", descending: true)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            ForumPost.fromDictionary(doc.data(), id: doc.documentID)
        }
    }
    
    // -----------------------------------------------------
    // MARK: - Comments
    // -----------------------------------------------------
    func addComment(_ comment: Comment) async throws -> String {
        let commentDict = comment.toDictionary()
        let docRef = try await db.collection("comments").addDocument(data: commentDict)
        
        // Update post comment count
        let postRef = db.collection("forumPosts").document(comment.postID)
        try await postRef.updateData([
            "commentCount": FieldValue.increment(Int64(1)),
            "updatedAt": Timestamp(date: Date())
        ])
        
        print("✅ Added comment to post")
        return docRef.documentID
    }
    
    func fetchComments(for postID: String) async throws -> [Comment] {
        let snapshot = try await db.collection("comments")
            .whereField("postID", isEqualTo: postID)
            .order(by: "createdAt", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            Comment.fromDictionary(doc.data(), id: doc.documentID)
        }
    }
    
    // -----------------------------------------------------
    // MARK: - Likes
    // -----------------------------------------------------
    func toggleLike(postID: String, userID: String) async throws -> Bool {
        let likeRef = db.collection("likes").document("\(postID)_\(userID)")
        
        // Check if like exists
        let doc = try await likeRef.getDocument()
        
        if doc.exists {
            // Unlike: delete the like document
            try await likeRef.delete()
            
            // Decrement like count
            let postRef = db.collection("forumPosts").document(postID)
            try await postRef.updateData([
                "likeCount": FieldValue.increment(Int64(-1))
            ])
            
            print("✅ Removed like from post")
            return false
        } else {
            // Like: create the like document
            let like = PostLike(postID: postID, userID: userID)
            try await likeRef.setData(like.toDictionary())
            
            // Increment like count
            let postRef = db.collection("forumPosts").document(postID)
            try await postRef.updateData([
                "likeCount": FieldValue.increment(Int64(1))
            ])
            
            print("✅ Added like to post")
            return true
        }
    }
    
    func checkIfLiked(postID: String, userID: String) async throws -> Bool {
        let likeRef = db.collection("likes").document("\(postID)_\(userID)")
        let doc = try await likeRef.getDocument()
        return doc.exists
    }
    
    func fetchLikedPosts(userID: String) async throws -> [String] {
        let snapshot = try await db.collection("likes")
            .whereField("userID", isEqualTo: userID)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            doc.data()["postID"] as? String ?? ""
        }.filter { !$0.isEmpty }
    }
}
