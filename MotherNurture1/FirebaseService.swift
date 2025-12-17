//
//  FirebaseService.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {

    static let shared = FirebaseService()
    let db = Firestore.firestore()

    private init() {}
    
    // -----------------------------------------------------
    // MARK: - Authentication
    // -----------------------------------------------------
    /// Sign in anonymously - creates a Firebase Auth user
    func signInAnonymously() async throws -> String {
        // Check if already signed in
        if let currentUser = Auth.auth().currentUser {
            print("✅ Already signed in with UID: \(currentUser.uid)")
            return currentUser.uid
        }
        
        // Sign in anonymously
        print("🔐 Attempting anonymous sign in...")
        print("   Firebase Auth instance: \(Auth.auth())")
        do {
            let result = try await Auth.auth().signInAnonymously()
            print("✅ Signed in anonymously with UID: \(result.user.uid)")
            print("   Is anonymous: \(result.user.isAnonymous)")
            return result.user.uid
        } catch let error as NSError {
            print("❌ ========== ANONYMOUS SIGN IN ERROR ==========")
            print("Error type: \(type(of: error))")
            print("Error description: \(error.localizedDescription)")
            print("Error domain: \(error.domain)")
            print("Error code: \(error.code)")
            print("Error userInfo: \(error.userInfo)")
            
            // Check for Firebase Auth specific errors
            if error.domain.contains("FIRAuthErrorDomain") || error.domain.contains("Auth") {
                if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                    print("Firebase Auth Error Code: \(authErrorCode.rawValue)")
                    
                    if authErrorCode == .operationNotAllowed {
                        print("⚠️⚠️⚠️ CRITICAL: Anonymous authentication is NOT enabled!")
                        print("   Please go to Firebase Console → Authentication → Sign-in method")
                        print("   Enable 'Anonymous' and click Save")
                        print("   Then try again!")
                    } else if authErrorCode == .networkError {
                        print("⚠️ Network error occurred - check your internet connection")
                    } else if authErrorCode == .internalError {
                        print("⚠️ Internal Firebase error occurred")
                    } else {
                        print("⚠️ Unknown Firebase Auth error: \(authErrorCode)")
                    }
                } else {
                    print("⚠️ Could not parse AuthErrorCode for code: \(error.code)")
                }
            } else {
                print("⚠️ Error is not from Firebase Auth domain")
            }
            print("================================================")
            throw error
        } catch {
            print("❌ Unexpected error type: \(type(of: error))")
            print("Error: \(error)")
            throw error
        }
    }
    
    /// Get current authenticated user ID
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// Check if user is authenticated
    func isAuthenticated() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// Sign out
    func signOut() throws {
        try Auth.auth().signOut()
        print("✅ Signed out")
    }

    // -----------------------------------------------------
    // MARK: - Save User Profile
    // -----------------------------------------------------
    func saveUserProfile(_ profile: UserProfile) async throws -> String {
        print("💾 saveUserProfile called")
        print("   Profile userID: \(profile.userID ?? "nil")")
        print("   Profile email: \(profile.email ?? "nil")")
        
        // Get the authenticated user ID - this is the source of truth
        guard let authUserID = Auth.auth().currentUser?.uid else {
            let error = NSError(
                domain: "FirebaseService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User must be authenticated to save profile"]
            )
            print("❌ No authenticated user found!")
            throw error
        }
        
        print("   Current Auth user: \(authUserID)")
        
        // Always use the authenticated user's ID as the document ID
        // This ensures consistency and allows security rules to work properly
        let userID = authUserID
        
        var profileDict = profile.toDictionary()
        profileDict["updatedAt"] = Timestamp(date: Date())
        profileDict["userID"] = userID // Ensure userID is in the dictionary
        
        // Add createdAt if it doesn't exist
        if profileDict["createdAt"] == nil {
            profileDict["createdAt"] = Timestamp(date: Date())
        }
        
        // Always use setData with the authenticated user's ID as document ID
        print("💾 Saving user profile with ID: \(userID)")
        print("   Profile data keys: \(profileDict.keys.sorted())")
        
        do {
            // Use setData with merge: true to create or update
            try await db.collection("users").document(userID).setData(profileDict, merge: true)
            print("✅ Successfully saved user profile with ID: \(userID)")
            return userID
        } catch {
            print("❌ ========== FIRESTORE SAVE ERROR ==========")
            print("Error type: \(type(of: error))")
            print("Error description: \(error.localizedDescription)")
            
            if let nsError = error as NSError? {
                print("Error domain: \(nsError.domain)")
                print("Error code: \(nsError.code)")
                print("Error userInfo: \(nsError.userInfo)")
                
                // Check for Firestore specific errors
                if nsError.domain.contains("FIRFirestoreErrorDomain") {
                    print("⚠️ This is a Firestore error")
                    if nsError.code == 7 { // Permission denied
                        print("⚠️ PERMISSION DENIED - Check Firestore security rules!")
                        print("   Make sure authenticated users can write to /users/{userId}")
                    } else if nsError.code == 14 { // Unavailable
                        print("⚠️ Firestore is unavailable - check network connection")
                    } else if nsError.code == 13 { // Internal error
                        print("⚠️ Firestore internal error - this might be a temporary issue")
                    }
                }
            }
            print("=============================================")
            throw error
        }
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
    // MARK: - Delete User Profile
    // -----------------------------------------------------
    func deleteUserProfile(userID: String) async throws {
        guard let currentUserID = getCurrentUserID() else {
            throw NSError(domain: "FirebaseService",
                          code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        guard userID == currentUserID else {
            throw NSError(domain: "FirebaseService",
                          code: 403,
                          userInfo: [NSLocalizedDescriptionKey: "You can only delete your own profile"])
        }
        
        // Delete the user profile document
        try await db.collection("users").document(userID).delete()
        print("✅ Successfully deleted user profile: \(userID)")
        
        // Note: We don't delete the user's posts/comments automatically
        // You may want to add cascade deletion logic if needed
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
    // MARK: - Fetch All User Profiles (for matchmaking)
    // -----------------------------------------------------
    func fetchAllUserProfiles(excludingUserID: String? = nil, limit: Int = 50) async throws -> [UserProfile] {
        let query = db.collection("users").limit(to: limit)
        
        // If excluding a user, we'll filter after fetching
        // (Firestore doesn't support != operator easily, so we filter in code)
        let snapshot = try await query.getDocuments()
        
        var profiles: [UserProfile] = []
        for doc in snapshot.documents {
            // Skip the current user if specified
            if let excludingID = excludingUserID, doc.documentID == excludingID {
                continue
            }
            
            let profile = parseUserProfile(from: doc.data(), userID: doc.documentID)
            profiles.append(profile)
        }
        
        print("✅ Fetched \(profiles.count) user profiles for matchmaking")
        return profiles
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
        profile.blockedUsers = data["blockedUsers"] as? [String]

        profile.createdAt = data["createdAt"] as? Timestamp
        profile.updatedAt = data["updatedAt"] as? Timestamp

        return profile
    }
    
    // -----------------------------------------------------
    // MARK: - Forum Posts
    // -----------------------------------------------------
    func createPost(_ post: ForumPost) async throws -> String {
        // Ensure user is authenticated before creating post
        guard let currentUserID = getCurrentUserID() else {
            throw NSError(domain: "FirebaseService",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "User must be authenticated to create posts"])
        }
        
        // Verify the post authorID matches the authenticated user
        guard post.authorID == currentUserID else {
            throw NSError(domain: "FirebaseService",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Post authorID must match authenticated user"])
        }
        
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
    
    func deletePost(postID: String) async throws {
        // Ensure user is authenticated
        guard let currentUserID = getCurrentUserID() else {
            throw NSError(domain: "FirebaseService",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "User must be authenticated to delete posts"])
        }
        
        // Verify the post exists and belongs to the user
        let postRef = db.collection("forumPosts").document(postID)
        let doc = try await postRef.getDocument()
        
        guard doc.exists, let data = doc.data() else {
            throw NSError(domain: "FirebaseService",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Post not found"])
        }
        
        guard let authorID = data["authorID"] as? String, authorID == currentUserID else {
            throw NSError(domain: "FirebaseService",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "You can only delete your own posts"])
        }
        
        // Delete the post
        try await postRef.delete()
        print("✅ Deleted post: \(postID)")
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

// MARK: - Comments Extension
extension FirebaseService {

    // Create a comment (alternative to addComment)
    func createComment(_ comment: Comment) async throws -> String {
        guard let currentUserID = getCurrentUserID() else {
            print("❌ createComment: No authenticated user found")
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        print("💬 createComment called")
        print("   Current Auth UID: \(currentUserID)")
        print("   Comment authorID: \(comment.authorID)")
        print("   Comment postID: \(comment.postID)")
        print("   Comment content: \(comment.content.prefix(50))...")

        // Verify the comment authorID matches the authenticated user
        guard comment.authorID == currentUserID else {
            print("❌ createComment: authorID mismatch!")
            print("   Expected: \(currentUserID)")
            print("   Got: \(comment.authorID)")
            throw NSError(domain: "FirebaseService", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only post comments as yourself"])
        }

        let commentDict = comment.toDictionary()
        
        // If comment has an ID, use it; otherwise create a new document
        if let commentID = comment.id, !commentID.isEmpty {
            let docRef = db.collection("comments").document(commentID)
            try await docRef.setData(commentDict)
            
            // Update post comment count
            let postRef = db.collection("forumPosts").document(comment.postID)
            try await postRef.updateData([
                "commentCount": FieldValue.increment(Int64(1)),
                "updatedAt": Timestamp(date: Date())
            ])
            
            return commentID
        } else {
            // Create new comment document
            let docRef = try await db.collection("comments").addDocument(data: commentDict)
            
            // Update post comment count
            let postRef = db.collection("forumPosts").document(comment.postID)
            try await postRef.updateData([
                "commentCount": FieldValue.increment(Int64(1)),
                "updatedAt": Timestamp(date: Date())
            ])
            
            print("✅ Created new comment")
            return docRef.documentID
        }
    }

    // Delete a comment
    func deleteComment(commentID: String) async throws {
        guard let currentUserID = getCurrentUserID() else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        let docRef = db.collection("comments").document(commentID)
        let snapshot = try await docRef.getDocument()
        
        guard snapshot.exists, let data = snapshot.data() else {
            throw NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Comment not found"])
        }

        // Use authorID (not userID) to match the Comment model
        guard let authorID = data["authorID"] as? String else {
            throw NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Comment data is invalid"])
        }

        guard authorID == currentUserID else {
            throw NSError(domain: "FirebaseService", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only delete your own comments"])
        }

        // Get postID before deleting
        let postID = data["postID"] as? String ?? ""
        
        // Delete the comment
        try await docRef.delete()
        
        // Decrement comment count on the post
        if !postID.isEmpty {
            let postRef = db.collection("forumPosts").document(postID)
            try await postRef.updateData([
                "commentCount": FieldValue.increment(Int64(-1)),
                "updatedAt": Timestamp(date: Date())
            ])
        }
        
        print("✅ Deleted comment")
    }
    
    // -----------------------------------------------------
    // MARK: - Block/Unblock Users
    // -----------------------------------------------------
    func blockUser(userID: String, userIDToBlock: String) async throws {
        guard let currentUserID = getCurrentUserID() else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        guard userID == currentUserID else {
            throw NSError(domain: "FirebaseService", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only block users from your own account"])
        }
        
        // Get current user profile
        let userRef = db.collection("users").document(userID)
        let doc = try await userRef.getDocument()
        
        var blockedUsers: [String] = []
        if let data = doc.data(), let existingBlocked = data["blockedUsers"] as? [String] {
            blockedUsers = existingBlocked
        }
        
        // Add user to blocked list if not already blocked
        if !blockedUsers.contains(userIDToBlock) {
            blockedUsers.append(userIDToBlock)
            try await userRef.updateData([
                "blockedUsers": blockedUsers,
                "updatedAt": Timestamp(date: Date())
            ])
            print("✅ Blocked user: \(userIDToBlock)")
        }
    }
    
    func unblockUser(userID: String, userIDToUnblock: String) async throws {
        guard let currentUserID = getCurrentUserID() else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        guard userID == currentUserID else {
            throw NSError(domain: "FirebaseService", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only unblock users from your own account"])
        }
        
        // Get current user profile
        let userRef = db.collection("users").document(userID)
        let doc = try await userRef.getDocument()
        
        guard let data = doc.data(), var blockedUsers = data["blockedUsers"] as? [String] else {
            print("ℹ️ No blocked users to unblock")
            return
        }
        
        // Remove user from blocked list
        blockedUsers.removeAll { $0 == userIDToUnblock }
        try await userRef.updateData([
            "blockedUsers": blockedUsers,
            "updatedAt": Timestamp(date: Date())
        ])
        print("✅ Unblocked user: \(userIDToUnblock)")
    }
    
    // -----------------------------------------------------
    // MARK: - Messages
    // -----------------------------------------------------
    func getOrCreateDirectMessageChannel(otherUserId: String, otherUserName: String) async throws -> Channel {
        guard let currentUserId = getCurrentUserID() else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        let snapshot = try await db.collection("channels")
            .whereField("isDirectMessage", isEqualTo: true)
            .whereField("memberIds", arrayContains: currentUserId)
            .getDocuments()

        for doc in snapshot.documents {
            let data = doc.data()
            let memberIds = data["memberIds"] as? [String] ?? []
            if memberIds.count == 2 && memberIds.contains(otherUserId) {
                return Channel(id: doc.documentID, data: data)
            }
        }

        let channelId = db.collection("channels").document().documentID
        let channel = Channel(
            id: channelId,
            name: otherUserName,
            description: nil,
            imageURL: nil,
            isDirectMessage: true,
            memberIds: [currentUserId, otherUserId],
            adminIds: [currentUserId],
            createdAt: Date(),
            lastMessageAt: Date()
        )

        try await db.collection("channels").document(channelId).setData(channel.toDictionary(), merge: true)
        return channel
    }

    /// Send a message to a channel
    func sendMessage(_ message: Message) async throws -> String {
        let data: [String: Any] = [
            "channelID": message.channelID,
            "text": message.text,
            "authorID": message.authorID,     // MUST already be Auth UID
            "authorName": message.authorName,
            "createdAt": message.createdAt,
            "updatedAt": message.updatedAt
        ]

        let docRef = try await db.collection("channels")
            .document(message.channelID)
            .collection("messages")
            .addDocument(data: data)

        // Update channel metadata
        try await db.collection("channels")
            .document(message.channelID)
            .setData([
                "lastMessageAt": Timestamp(),
                "updatedAt": Timestamp()
            ], merge: true)

        print("✅ Sent message to channel:", message.channelID)
        return docRef.documentID
    }

    /// Fetch messages for a channel
    func fetchMessages(channelID: String, limit: Int = 100) async throws -> [Message] {
        let snapshot = try await db.collection("channels")
            .document(channelID)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            Message.fromDictionary(doc.data(), id: doc.documentID)
        }
    }
    
    /// Listen to messages in real-time for a channel
    func listenToMessages(channelID: String, onUpdate: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("channels")
            .document(channelID)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .limit(to: 100)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error listening to messages: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("⚠️ No snapshot returned from message listener")
                    return
                }
                
                let messages = snapshot.documents.compactMap { doc in
                    Message.fromDictionary(doc.data(), id: doc.documentID)
                }
                
                onUpdate(messages)
            }
    }
}

