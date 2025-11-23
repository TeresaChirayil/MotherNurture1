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
    // MARK: - Community Posts
    // -----------------------------------------------------
    
    /// Create a new post
    func createPost(_ post: Post) async throws -> String {
        let postDict = post.toDictionary()
        let docRef = try await db.collection("posts").addDocument(data: postDict)
        print("✅ Created new post: \(docRef.documentID)")
        return docRef.documentID
    }
    
    /// Fetch all posts, ordered by creation date (newest first)
    func fetchAllPosts() async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            Post.fromDictionary(doc.data(), id: doc.documentID)
        }
    }
    
    /// Fetch posts by a specific user
    func fetchUserPosts(userID: String) async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .whereField("userID", isEqualTo: userID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            Post.fromDictionary(doc.data(), id: doc.documentID)
        }
    }
    
    /// Fetch popular posts (by like count)
    func fetchPopularPosts() async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        let posts = snapshot.documents.compactMap { doc -> Post? in
            Post.fromDictionary(doc.data(), id: doc.documentID)
        }
        
        // Sort by like count (descending), then by date
        return posts.sorted { post1, post2 in
            if post1.likeCount != post2.likeCount {
                return post1.likeCount > post2.likeCount
            }
            return post1.createdAt.dateValue() > post2.createdAt.dateValue()
        }
    }
    
    /// Search posts by title or description
    func searchPosts(query: String) async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        let allPosts = snapshot.documents.compactMap { doc -> Post? in
            Post.fromDictionary(doc.data(), id: doc.documentID)
        }
        
        let lowerQuery = query.lowercased()
        return allPosts.filter { post in
            post.title.lowercased().contains(lowerQuery) ||
            post.description.lowercased().contains(lowerQuery)
        }
    }
    
    /// Toggle like on a post
    func toggleLike(postID: String, userID: String) async throws {
        let postRef = db.collection("posts").document(postID)
        let doc = try await postRef.getDocument()
        
        guard let data = doc.data(),
              var likes = data["likes"] as? [String] else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not found"])
        }
        
        if likes.contains(userID) {
            likes.removeAll { $0 == userID }
        } else {
            likes.append(userID)
        }
        
        try await postRef.updateData(["likes": likes])
        print("✅ Toggled like for post: \(postID)")
    }
    
    /// Add a comment to a post
    func addComment(postID: String, comment: Comment) async throws {
        let postRef = db.collection("posts").document(postID)
        let doc = try await postRef.getDocument()
        
        guard var data = doc.data(),
              var comments = data["comments"] as? [[String: Any]] else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not found"])
        }
        
        comments.append(comment.toDictionary())
        try await postRef.updateData(["comments": comments])
        print("✅ Added comment to post: \(postID)")
    }
    
    /// Fetch a single post by ID
    func fetchPost(postID: String) async throws -> Post? {
        let doc = try await db.collection("posts").document(postID).getDocument()
        guard doc.exists, let data = doc.data() else { return nil }
        return Post.fromDictionary(data, id: doc.documentID)
    }
}
