//
//  ForumModels.swift
//  MotherNurture1
//
//  Created for community forum feature
//

import Foundation
import FirebaseFirestore

// MARK: - Forum Post Model
struct ForumPost: Identifiable {
    var id: String?
    var title: String
    var content: String
    var authorID: String
    var authorName: String
    var createdAt: Timestamp
    var updatedAt: Timestamp
    var likeCount: Int
    var commentCount: Int
    var tags: [String]?
    
    init(id: String? = nil, title: String, content: String, authorID: String, authorName: String, tags: [String]? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.authorID = authorID
        self.authorName = authorName
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
        self.likeCount = 0
        self.commentCount = 0
        self.tags = tags
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "content": content,
            "authorID": authorID,
            "authorName": authorName,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "likeCount": likeCount,
            "commentCount": commentCount
        ]
        if let tags = tags {
            dict["tags"] = tags
        }
        return dict
    }
    
    static func fromDictionary(_ data: [String: Any], id: String) -> ForumPost? {
        guard let title = data["title"] as? String,
              let content = data["content"] as? String,
              let authorID = data["authorID"] as? String,
              let authorName = data["authorName"] as? String,
              let createdAt = data["createdAt"] as? Timestamp,
              let updatedAt = data["updatedAt"] as? Timestamp,
              let likeCount = data["likeCount"] as? Int,
              let commentCount = data["commentCount"] as? Int else {
            return nil
        }
        
        var post = ForumPost(
            id: id,
            title: title,
            content: content,
            authorID: authorID,
            authorName: authorName,
            tags: data["tags"] as? [String]
        )
        post.createdAt = createdAt
        post.updatedAt = updatedAt
        post.likeCount = likeCount
        post.commentCount = commentCount
        return post
    }
}

// MARK: - Comment Model
struct Comment: Identifiable {
    var id: String?
    var postID: String
    var content: String
    var authorID: String
    var authorName: String
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(id: String? = nil, postID: String, content: String, authorID: String, authorName: String) {
        self.id = id
        self.postID = postID
        self.content = content
        self.authorID = authorID
        self.authorName = authorName
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "postID": postID,
            "content": content,
            "authorID": authorID,
            "authorName": authorName,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
    
    static func fromDictionary(_ data: [String: Any], id: String) -> Comment? {
        guard let postID = data["postID"] as? String,
              let content = data["content"] as? String,
              let authorID = data["authorID"] as? String,
              let authorName = data["authorName"] as? String,
              let createdAt = data["createdAt"] as? Timestamp,
              let updatedAt = data["updatedAt"] as? Timestamp else {
            return nil
        }
        
        var comment = Comment(
            id: id,
            postID: postID,
            content: content,
            authorID: authorID,
            authorName: authorName
        )
        comment.createdAt = createdAt
        comment.updatedAt = updatedAt
        return comment
    }
}

// MARK: - Like Model
struct PostLike: Identifiable {
    var id: String { "\(postID)_\(userID)" }
    var postID: String
    var userID: String
    var createdAt: Timestamp
    
    init(postID: String, userID: String) {
        self.postID = postID
        self.userID = userID
        self.createdAt = Timestamp(date: Date())
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "postID": postID,
            "userID": userID,
            "createdAt": createdAt
        ]
    }
}

