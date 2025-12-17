import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

@MainActor
class ChannelsViewModel: ObservableObject {
    @Published var channels: [Channel] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var unreadCounts: [String: Int] = [:]
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    /// The profile userID (Firestore document ID) - this is the stable user identity
    /// that should be used for channel membership, NOT the Firebase Auth UID
    private var profileUserID: String?
    
    init() {
        // Don't auto-setup listener here - wait for setUserID to be called
        // This ensures we use the correct profile-based userID
    }
    
    deinit {
        listener?.remove()
        for (_, l) in messageListeners {
            l.remove()
        }
        messageListeners.removeAll()
    }

    var totalUnread: Int {
        unreadCounts.values.reduce(0, +)
    }
    
    /// Set the user ID and start listening for channels
    /// This should be called with userDataManager.profile.userID
    func setUserID(_ userID: String?) {
        // If same userID, don't restart listener
        if profileUserID == userID && listener != nil {
            return
        }
        
        profileUserID = userID
        listener?.remove()
        listener = nil

        for (_, l) in messageListeners {
            l.remove()
        }
        messageListeners.removeAll()
        unreadCounts.removeAll()
        
        guard let userID = userID, !userID.isEmpty else {
            channels = []
            return
        }
        
        loadCachedChannels(userId: userID)
        syncUnreadListeners(for: userID)
        setupChannelsListener(for: userID)
    }
    
    private func setupChannelsListener(for userId: String) {
        listener?.remove()
        listener = nil
        
        isLoading = true
        
        listener = db.collection("channels")
            .whereField("memberIds", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    print("Error fetching channels: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.channels = []
                    return
                }
                
                let updatedChannels = documents.compactMap { document in
                    Channel(id: document.documentID, data: document.data())
                }
                .sorted { $0.lastMessageAt > $1.lastMessageAt }

                self.channels = updatedChannels
                self.saveCachedChannels(userId: userId, channels: updatedChannels)

                self.syncUnreadListeners(for: userId)
            }
    }

    private func syncUnreadListeners(for userId: String) {
        let channelIds = Set(channels.map { $0.id })

        // Remove listeners for channels no longer present
        for (channelId, l) in messageListeners where !channelIds.contains(channelId) {
            l.remove()
            messageListeners.removeValue(forKey: channelId)
            unreadCounts.removeValue(forKey: channelId)
        }

        // Add listeners for new channels
        for channel in channels where messageListeners[channel.id] == nil {
            let channelId = channel.id
            let l = db.collection("channels")
                .document(channelId)
                .collection("messages")
                .order(by: "createdAt", descending: true)
                .limit(to: 100)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    if let error = error {
                        print("❌ Error listening for unread messages: \(error.localizedDescription)")
                        return
                    }
                    guard let docs = snapshot?.documents else {
                        Task { @MainActor in
                            self.unreadCounts[channelId] = 0
                        }
                        return
                    }

                    var unread = 0
                    for doc in docs {
                        guard let msg = Message.fromDictionary(doc.data(), id: doc.documentID) else { continue }
                        if msg.authorID == userId { continue }
                        if msg.readBy.contains(userId) { continue }
                        unread += 1
                    }

                    Task { @MainActor in
                        self.unreadCounts[channelId] = unread
                    }
                }

            messageListeners[channelId] = l
        }
    }
    
    func fetchChannels() async {
        guard let userId = profileUserID, !userId.isEmpty else { return }
        
        isLoading = true
        
        do {
            let querySnapshot = try await db.collection("channels")
                .whereField("memberIds", arrayContains: userId)
                .getDocuments()
            
            var fetchedChannels: [Channel] = []
            
            for document in querySnapshot.documents {
                let channel = Channel(id: document.documentID, data: document.data())
                fetchedChannels.append(channel)
            }
            
            self.channels = fetchedChannels.sorted { $0.lastMessageAt > $1.lastMessageAt }
            self.saveCachedChannels(userId: userId, channels: self.channels)
            self.isLoading = false
        } catch {
            self.error = error
            self.isLoading = false
            print("Error fetching channels: \(error.localizedDescription)")
        }
    }

    private func cacheKey(userId: String) -> String {
        "cachedChannels_\(userId)"
    }

    private func loadCachedChannels(userId: String) {
        let key = cacheKey(userId: userId)
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let cached = try decoder.decode([Channel].self, from: data)
            if !cached.isEmpty {
                self.channels = cached
            }
        } catch {
            return
        }
    }

    private func saveCachedChannels(userId: String, channels: [Channel]) {
        let key = cacheKey(userId: userId)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(channels)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            return
        }
    }
    
    func createChannel(_ channel: Channel, userId: String) async -> Channel? {
        guard !userId.isEmpty else { return nil }
        
        isLoading = true
        
        do {
            var channelToCreate = channel
            
            // Set creator as admin and member
            channelToCreate.memberIds = [userId]
            channelToCreate.adminIds = [userId]
            channelToCreate.createdAt = Date()
            channelToCreate.lastMessageAt = Date()
            
            let documentRef = try await db.collection("channels").addDocument(data: channelToCreate.toDictionary())
            
            // Update the channel with the new ID
            channelToCreate.id = documentRef.documentID
            
            // Add channel to user's channelMemberships
            try await db.collection("users").document(userId).updateData([
                "channelMemberships": FieldValue.arrayUnion([documentRef.documentID])
            ])
            
            isLoading = false
            return channelToCreate
        } catch {
            self.error = error
            isLoading = false
            print("Error creating channel: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateChannel(_ channel: Channel) async -> Bool {
        let channelId = channel.id
        
        isLoading = true
        
        do {
            try await db.collection("channels").document(channelId).updateData(channel.toDictionary())
            isLoading = false
            return true
        } catch {
            self.error = error
            isLoading = false
            print("Error updating channel: \(error.localizedDescription)")
            return false
        }
    }
    
    func updateChannelImage(channelId: String, image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            self.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])
            return nil
        }
        
        let storageRef = storage.reference()
        let imageName = "channel_\(channelId)_\(Int(Date().timeIntervalSince1970)).jpg"
        let imageRef = storageRef.child("channel_images/\(imageName)")
        
        do {
            let _ = try await imageRef.putDataAsync(imageData)
            let downloadURL = try await imageRef.downloadURL()
            
            // Update channel with new image URL
            try await db.collection("channels").document(channelId).updateData([
                "imageURL": downloadURL.absoluteString
            ])
            
            return downloadURL.absoluteString
        } catch {
            self.error = error
            print("Error uploading channel image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func leaveChannel(channelId: String, userId: String) async -> Bool {
        do {
            // Remove user from channel members
            try await db.collection("channels").document(channelId).updateData([
                "memberIds": FieldValue.arrayRemove([userId]),
                "adminIds": FieldValue.arrayRemove([userId])
            ])
            
            // Remove channel from user's channelMemberships
            try await db.collection("users").document(userId).updateData([
                "channelMemberships": FieldValue.arrayRemove([channelId])
            ])
            
            // If no members left, delete the channel
            let channelDoc = try await db.collection("channels").document(channelId).getDocument()
            if let memberIds = channelDoc.data()?["memberIds"] as? [String], memberIds.isEmpty {
                try await db.collection("channels").document(channelId).delete()
            }
            
            return true
        } catch {
            self.error = error
            print("Error leaving channel: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchChannelMembers(channelId: String) async -> [UserProfile] {
        do {
            let document = try await db.collection("channels").document(channelId).getDocument()
            guard let data = document.data(),
                  let memberIds = data["memberIds"] as? [String] else {
                return []
            }
            
            var members: [UserProfile] = []
            
            for memberId in memberIds {
                let userDoc = try await db.collection("users").document(memberId).getDocument()
                if let userData = userDoc.data() {
                    var user = UserProfile()
                    user.userID = memberId
                    user.firstName = userData["firstName"] as? String
                    user.lastName = userData["lastName"] as? String
                    user.photoURL = userData["photoURL"] as? String
                    members.append(user)
                }
            }
            
            return members
        } catch {
            print("Error fetching channel members: \(error.localizedDescription)")
            return []
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
extension Channel {
    // Convenience initializer to build a Channel from Firestore document data
    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["name"] as? String ?? ""
        self.description = data["description"] as? String
        self.imageURL = data["imageURL"] as? String
        self.isDirectMessage = data["isDirectMessage"] as? Bool ?? false
        self.memberIds = data["memberIds"] as? [String] ?? []
        self.adminIds = data["adminIds"] as? [String] ?? []
        self.memberNames = data["memberNames"] as? [String: String]

        if let createdAtTS = data["createdAt"] as? Timestamp {
            self.createdAt = createdAtTS.dateValue()
        } else if let createdAtDate = data["createdAt"] as? Date {
            self.createdAt = createdAtDate
        } else {
            self.createdAt = Date()
        }

        if let lastMessageAtTS = data["lastMessageAt"] as? Timestamp {
            self.lastMessageAt = lastMessageAtTS.dateValue()
        } else if let lastMessageAtDate = data["lastMessageAt"] as? Date {
            self.lastMessageAt = lastMessageAtDate
        } else {
            self.lastMessageAt = self.createdAt
        }
    }

    // Convert Channel to Firestore dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["name"] = self.name
        if let description = self.description { dict["description"] = description }
        if let imageURL = self.imageURL { dict["imageURL"] = imageURL }
        dict["isDirectMessage"] = self.isDirectMessage
        dict["memberIds"] = self.memberIds
        dict["adminIds"] = self.adminIds
        dict["createdAt"] = self.createdAt
        dict["lastMessageAt"] = self.lastMessageAt
        if let memberNames = self.memberNames { dict["memberNames"] = memberNames }
        return dict
    }
    
    /// Get the display name for this channel based on the current user
    /// For DM channels, shows the other person's name
    func displayName(forUserId currentUserId: String?) -> String {
        guard isDirectMessage, let currentUserId = currentUserId, let memberNames = memberNames else {
            return name
        }
        
        // For DM channels, find the other user's name
        for (userId, userName) in memberNames {
            if userId != currentUserId {
                return userName
            }
        }
        
        // Fallback to channel name
        return name
    }
}

