//
//  PostDetailView.swift
//  MotherNurture1
//
//  View for viewing full post details and comments
//

import SwiftUI
import FirebaseCore

struct PostDetailView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Environment(\.dismiss) var dismiss
    
    @State var post: Post
    @State private var isLiked: Bool
    @State private var likeCount: Int
    @State private var commentText: String = ""
    @State private var isPostingComment = false
    @State private var refreshTrigger = UUID()
    
    let onPostUpdated: (() -> Void)?
    
    init(post: Post, onPostUpdated: (() -> Void)? = nil) {
        self._post = State(initialValue: post)
        self._isLiked = State(initialValue: post.likes.contains(UserDataManager.shared.profile.userID ?? ""))
        self._likeCount = State(initialValue: post.likeCount)
        self.onPostUpdated = onPostUpdated
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Post Content
                            VStack(alignment: .leading, spacing: 12) {
                                // Title and Date
                                HStack {
                                    Text(post.title)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                    
                                    Spacer()
                                    
                                    Text(formatDate(post.createdAt.dateValue()))
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color(hex: "8B9A7E"))
                                }
                                
                                // Username
                                Text(post.username)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "8B9A7E"))
                                
                                // Description
                                Text(post.description)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .padding(.top, 8)
                                
                                // Engagement
                                HStack(spacing: 24) {
                                    Button(action: {
                                        toggleLike()
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                                .foregroundColor(isLiked ? .red : Color(hex: "5C3D2E"))
                                            Text("\(likeCount)")
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                        }
                                    }
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "bubble.right")
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                        Text("\(post.comments.count)")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                    }
                                }
                                .padding(.top, 12)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Comments Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Comments")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .padding(.horizontal, 20)
                                
                                if post.comments.isEmpty {
                                    Text("No comments yet. Be the first to comment!")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 20)
                                } else {
                                    ForEach(post.comments) { comment in
                                        CommentRowView(comment: comment)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                            .padding(.top, 20)
                            
                            // Add Comment Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Add a comment")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                HStack(spacing: 12) {
                                    TextField("Write a comment...", text: $commentText, axis: .vertical)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .lineLimit(3...6)
                                    
                                    Button(action: {
                                        postComment()
                                    }) {
                                        if isPostingComment {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(canPostComment ? Color(hex: "5C3D2E") : Color.gray)
                                        }
                                    }
                                    .disabled(!canPostComment || isPostingComment)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                }
            }
            .onAppear {
                loadPost()
            }
        }
    }
    
    private var canPostComment: Bool {
        !commentText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func toggleLike() {
        guard let postID = post.id else { return }
        guard let userID = userDataManager.profile.userID else { return }
        
        Task {
            do {
                try await FirebaseService.shared.toggleLike(postID: postID, userID: userID)
                await MainActor.run {
                    if isLiked {
                        likeCount -= 1
                        isLiked = false
                    } else {
                        likeCount += 1
                        isLiked = true
                    }
                    loadPost()
                    onPostUpdated?()
                }
            } catch {
                print("Error toggling like: \(error)")
            }
        }
    }
    
    private func postComment() {
        guard let postID = post.id else { return }
        guard let userID = userDataManager.profile.userID else { return }
        
        let username = userDataManager.profile.firstName ?? "user\(userID.prefix(4))"
        
        isPostingComment = true
        
        Task {
            do {
                let comment = Comment(
                    text: commentText.trimmingCharacters(in: .whitespaces),
                    userID: userID,
                    username: username
                )
                
                try await FirebaseService.shared.addComment(postID: postID, comment: comment)
                
                await MainActor.run {
                    commentText = ""
                    isPostingComment = false
                    loadPost()
                    onPostUpdated?()
                }
            } catch {
                print("Error posting comment: \(error)")
                await MainActor.run {
                    isPostingComment = false
                }
            }
        }
    }
    
    private func loadPost() {
        guard let postID = post.id else { return }
        
        Task {
            do {
                if let updatedPost = try await FirebaseService.shared.fetchPost(postID: postID) {
                    await MainActor.run {
                        self.post = updatedPost
                        self.isLiked = updatedPost.likes.contains(userDataManager.profile.userID ?? "")
                        self.likeCount = updatedPost.likeCount
                    }
                }
            } catch {
                print("Error loading post: \(error)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Comment Row View
struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.username)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                
                Spacer()
                
                Text(formatDate(comment.createdAt.dateValue()))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(hex: "8B9A7E"))
            }
            
            Text(comment.text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
        }
        .padding(12)
        .background(Color(hex: "DDE3D0"))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    PostDetailView(post: Post(
        title: "Sample Post",
        description: "This is a sample post description",
        userID: "user1",
        username: "user1"
    ))
    .environmentObject(UserDataManager.shared)
}
