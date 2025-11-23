//
//  Post.swift
//  MotherNurture1
//
//  Created for Community Feed
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    var id: String?
    var title: String
    var description: String
    var userID: String
    var username: String
    var createdAt: Timestamp
    var likes: [String] // Array of userIDs who liked the post
    var comments: [Comment]
    
    init(id: String? = nil, title: String, description: String, userID: String, username: String, createdAt: Timestamp = Timestamp(date: Date()), likes: [String] = [], comments: [Comment] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.userID = userID
        self.username = username
        self.createdAt = createdAt
        self.likes = likes
        self.comments = comments
    }
    
    var likeCount: Int {
        return likes.count
    }
    
    var commentCount: Int {
        return comments.count
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["title"] = title
        dict["description"] = description
        dict["userID"] = userID
        dict["username"] = username
        dict["createdAt"] = createdAt
        dict["likes"] = likes
        dict["comments"] = comments.map { $0.toDictionary() }
        return dict
    }
    
    static func fromDictionary(_ data: [String: Any], id: String) -> Post? {
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let userID = data["userID"] as? String,
              let username = data["username"] as? String,
              let createdAt = data["createdAt"] as? Timestamp else {
            return nil
        }
        
        let likes = data["likes"] as? [String] ?? []
        let commentsData = data["comments"] as? [[String: Any]] ?? []
        let comments = commentsData.compactMap { Comment.fromDictionary($0) }
        
        return Post(id: id, title: title, description: description, userID: userID, username: username, createdAt: createdAt, likes: likes, comments: comments)
    }
}

struct Comment: Identifiable, Codable {
    var id: String
    var text: String
    var userID: String
    var username: String
    var createdAt: Timestamp
    
    init(id: String = UUID().uuidString, text: String, userID: String, username: String, createdAt: Timestamp = Timestamp(date: Date())) {
        self.id = id
        self.text = text
        self.userID = userID
        self.username = username
        self.createdAt = createdAt
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "text": text,
            "userID": userID,
            "username": username,
            "createdAt": createdAt
        ]
    }
    
    static func fromDictionary(_ data: [String: Any]) -> Comment? {
        guard let id = data["id"] as? String,
              let text = data["text"] as? String,
              let userID = data["userID"] as? String,
              let username = data["username"] as? String,
              let createdAt = data["createdAt"] as? Timestamp else {
            return nil
        }
        return Comment(id: id, text: text, userID: userID, username: username, createdAt: createdAt)
    }
}

