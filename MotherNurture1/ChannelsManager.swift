//
//  ChannelsManager.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Combine

class ChannelsManager: ObservableObject {
    static let shared = ChannelsManager()
    private let db = Firestore.firestore()
    
    @Published var channels: [Channel] = []
    private var listener: ListenerRegistration?
    
    private init() {}
    
    func startListening() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener = db.collection("channels")
            .whereField("memberIds", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching channels: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No channels found")
                    return
                }
                
                self.channels = documents.compactMap { document in
                    try? document.data(as: Channel.self)
                }.sorted { $0.lastMessageAt > $1.lastMessageAt }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func createChannel(name: String, description: String? = nil, isDirectMessage: Bool = false, otherUserId: String? = nil, completion: @escaping (Result<Channel, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let channelId = UUID().uuidString
        var memberIds = [currentUserId]
        var adminIds = [currentUserId]
        
        if let otherUserId = otherUserId, isDirectMessage {
            memberIds.append(otherUserId)
        }
        
        let channel = Channel(
            id: channelId,
            name: name,
            description: description,
            imageURL: nil,
            isDirectMessage: isDirectMessage,
            memberIds: memberIds,
            adminIds: adminIds,
            createdAt: Date(),
            lastMessageAt: Date()
        )
        
        do {
            try db.collection("channels").document(channelId).setData(from: channel) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(channel))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateChannel(_ channel: Channel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("channels").document(channel.id).setData(from: channel) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func leaveChannel(_ channelId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let channelRef = db.collection("channels").document(channelId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let channelDocument: DocumentSnapshot
            do {
                try channelDocument = transaction.getDocument(channelRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var channel = try? channelDocument.data(as: Channel.self) else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not decode channel"])
                errorPointer?.pointee = error
                return nil
            }
            
            // Remove user from members and admins
            channel.memberIds.removeAll { $0 == userId }
            channel.adminIds.removeAll { $0 == userId }
            
            // If no members left, delete the channel
            if channel.memberIds.isEmpty {
                transaction.deleteDocument(channelRef)
            } else {
                // If user was the last admin, assign admin to another member
                if channel.adminIds.isEmpty, let newAdmin = channel.memberIds.first {
                    channel.adminIds.append(newAdmin)
                }
                
                transaction.updateData([
                    "memberIds": channel.memberIds,
                    "adminIds": channel.adminIds
                ], forDocument: channelRef)
            }
            
            return nil
        }) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateChannelImage(channelId: String, image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("channel_images/\(channelId)/\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    // Update channel with image URL
                    self.db.collection("channels").document(channelId).updateData([
                        "imageURL": url.absoluteString
                    ]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(url))
                        }
                    }
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload is \(percentComplete)% complete")
        }
    }
    
    // Add this method to fetch channel members
    func fetchChannelMembers(channelId: String, completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        let channelRef = db.collection("channels").document(channelId)
        
        channelRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let channel = try? document?.data(as: Channel.self) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not decode channel"])))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var members: [UserProfile] = []
            var fetchError: Error?
            
            for memberId in channel.memberIds {
                dispatchGroup.enter()
                self.db.collection("users").document(memberId).getDocument { snapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    if let error = error {
                        fetchError = error
                        return
                    }
                    
                    if let user = try? snapshot?.data(as: UserProfile.self) {
                        members.append(user)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if let error = fetchError {
                    completion(.failure(error))
                } else {
                    completion(.success(members))
                }
            }
        }
    }
}

struct Channel: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var description: String?
    var imageURL: String?
    var isDirectMessage: Bool
    var memberIds: [String]
    var adminIds: [String]
    var createdAt: Date
    var lastMessageAt: Date
    var memberNames: [String: String]? // Maps userID to display name for DM channels

    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastMessageAt, relativeTo: Date())
    }
    
    func isAdmin(userId: String) -> Bool {
        return adminIds.contains(userId)
    }
    
    func isMember(userId: String) -> Bool {
        return memberIds.contains(userId)
    }
    
    // Helper to check if this is a direct message with a specific user
    func isDirectMessageWith(userId: String) -> Bool {
        return isDirectMessage && memberIds.contains(userId)
    }
}

extension Channel {
    static let mock = Channel(
        id: "1",
        name: "General",
        description: "General discussion",
        imageURL: nil,
        isDirectMessage: false,
        memberIds: [],
        adminIds: [],
        createdAt: Date(),
        lastMessageAt: Date()
    )
}


