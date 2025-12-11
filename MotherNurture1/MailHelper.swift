//
//  MailHelper.swift
//  MotherNurture1
//
//  Helper utility for opening mail app with pre-filled email
//

import Foundation
import UIKit

struct MailHelper {
    static let reportEmail = "mothernurture0025@gmail.com"
    
    /// Opens the default mail app with a pre-filled email to the report address
    /// - Parameters:
    ///   - subject: Subject line for the email
    ///   - body: Body content for the email
    ///   - contentType: Type of content being reported (e.g., "User", "Post", "Message")
    ///   - contentID: ID or identifier of the content being reported
    static func openMailApp(subject: String = "Report from MotherNurture App", body: String = "", contentType: String = "", contentID: String = "") {
        var emailBody = body
        
        if !contentType.isEmpty && !contentID.isEmpty {
            if !emailBody.isEmpty {
                emailBody += "\n\n"
            }
            emailBody += "Content Type: \(contentType)\n"
            emailBody += "Content ID: \(contentID)"
        }
        
        // URL encode the subject and body
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create mailto URL
        var mailtoURLString = "mailto:\(reportEmail)?subject=\(encodedSubject)"
        if !encodedBody.isEmpty {
            mailtoURLString += "&body=\(encodedBody)"
        }
        
        guard let mailtoURL = URL(string: mailtoURLString) else {
            print("Error: Could not create mailto URL")
            return
        }
        
        // Open the mail app
        if UIApplication.shared.canOpenURL(mailtoURL) {
            UIApplication.shared.open(mailtoURL)
        } else {
            print("Error: Cannot open mail app. Please configure a mail app in Settings.")
        }
    }
    
    /// Opens mail app to report a user
    static func reportUser(userID: String, userName: String) {
        let subject = "Report User - \(userName)"
        let body = "I would like to report the following user:\n\nUser Name: \(userName)\nUser ID: \(userID)\n\nPlease provide details about why you are reporting this user:"
        openMailApp(subject: subject, body: body, contentType: "User", contentID: userID)
    }
    
    /// Opens mail app to report a post
    static func reportPost(postID: String, postTitle: String, authorName: String) {
        let subject = "Report Post - \(postTitle)"
        let body = "I would like to report the following post:\n\nPost Title: \(postTitle)\nAuthor: \(authorName)\nPost ID: \(postID)\n\nPlease provide details about why you are reporting this post:"
        openMailApp(subject: subject, body: body, contentType: "Post", contentID: postID)
    }
    
    /// Opens mail app to report a message/channel
    static func reportMessage(channelID: String, channelName: String, userName: String? = nil) {
        let subject = "Report Message/Channel - \(channelName)"
        var body = "I would like to report the following message/channel:\n\nChannel Name: \(channelName)\nChannel ID: \(channelID)"
        if let userName = userName {
            body += "\nUser Name: \(userName)"
        }
        body += "\n\nPlease provide details about why you are reporting this content:"
        openMailApp(subject: subject, body: body, contentType: "Message/Channel", contentID: channelID)
    }
}
