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
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        setupChannelsListener()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func setupChannelsListener() {
        guard let userId = currentUserId else { return }
        
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
                
                self.channels = documents.compactMap { document in
                    Channel(id: document.documentID, data: document.data())
                }
                .sorted { $0.lastMessageAt > $1.lastMessageAt }
            }
    }
    
    func fetchChannels() async {
        guard let userId = currentUserId else { return }
        
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
            self.isLoading = false
        } catch {
            self.error = error
            self.isLoading = false
            print("Error fetching channels: \(error.localizedDescription)")
        }
    }
    
    func createChannel(_ channel: Channel) async -> Channel? {
        guard let userId = currentUserId else { return nil }
        
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
        return dict
    }
}

