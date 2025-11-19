//
//  PostDetailView.swift
//  MotherNurture1
//
//  Created for community forum feature
//

import SwiftUI
import FirebaseFirestore

struct PostDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    
    let post: ForumPost
    @State private var comments: [Comment] = []
    @State private var isLiked: Bool = false
    @State private var newComment: String = ""
    @State private var isLoading: Bool = false
    @State private var isPostingComment: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Post Content
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(post.title)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Spacer()
                                
                                Text(formatDate(post.createdAt.dateValue()))
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color(hex: "8B9A7E"))
                            }
                            
                            Text(post.authorName)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "8B9A7E"))
                            
                            Text(post.content)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .padding(.top, 4)
                            
                            if let tags = post.tags, !tags.isEmpty {
                                HStack(spacing: 8) {
                                    ForEach(tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.system(size: 12, weight: .medium))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(hex: "8B9A7E").opacity(0.2))
                                            .cornerRadius(6)
                                    }
                                }
                                .padding(.top, 8)
                            }
                            
                            // Like and Comment Count
                            HStack(spacing: 20) {
                                Button(action: toggleLike) {
                                    HStack(spacing: 6) {
                                        Image(systemName: isLiked ? "heart.fill" : "heart")
                                            .foregroundColor(isLiked ? Color.red : Color(hex: "5C3D2E"))
                                        Text("\(post.likeCount)")
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                    }
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "message")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                    Text("\(post.commentCount)")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                }
                            }
                            .font(.system(size: 14, design: .rounded))
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                        
                        // Comments Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Comments")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .padding(.horizontal)
                            
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if comments.isEmpty {
                                Text("No comments yet. Be the first to comment!")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                ForEach(comments) { comment in
                                    CommentRowView(comment: comment)
                                }
                            }
                        }
                        
                        // Add Comment Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add a comment")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            HStack(spacing: 12) {
                                TextField("Write a comment...", text: $newComment, axis: .vertical)
                                    .padding()
                                    .background(Color(hex: "9BA897"))
                                    .cornerRadius(8)
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .font(.system(size: 16, design: .rounded))
                                    .lineLimit(3...6)
                                
                                Button(action: postComment) {
                                    if isPostingComment {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "5C3D2E")))
                                    } else {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(newComment.isEmpty ? Color(hex: "5C3D2E").opacity(0.3) : Color(hex: "8B9A7E"))
                                    }
                                }
                                .disabled(newComment.isEmpty || isPostingComment)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                    .padding()
                }
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "5C3D2E"))
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .task {
                await loadComments()
                await checkLikeStatus()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .presentationDetents([.large])
    }
    
    private func loadComments() async {
        guard let postID = post.id else { return }
        isLoading = true
        
        do {
            let fetchedComments = try await FirebaseService.shared.fetchComments(for: postID)
            await MainActor.run {
                self.comments = fetchedComments
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
    
    private func checkLikeStatus() async {
        guard let postID = post.id,
              let userID = userDataManager.profile.userID else { return }
        
        do {
            let liked = try await FirebaseService.shared.checkIfLiked(postID: postID, userID: userID)
            await MainActor.run {
                self.isLiked = liked
            }
        } catch {
            print("Error checking like status: \(error)")
        }
    }
    
    private func toggleLike() {
        guard let postID = post.id,
              let userID = userDataManager.profile.userID else {
            errorMessage = "Please log in to like posts"
            showError = true
            return
        }
        
        Task {
            do {
                let newLikeStatus = try await FirebaseService.shared.toggleLike(postID: postID, userID: userID)
                await MainActor.run {
                    self.isLiked = newLikeStatus
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to like post: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func postComment() {
        guard let postID = post.id,
              let userID = userDataManager.profile.userID else {
            errorMessage = "Please log in to comment"
            showError = true
            return
        }
        
        let authorName = "\(userDataManager.profile.firstName ?? "") \(userDataManager.profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        let finalAuthorName = authorName.isEmpty ? "user\(userID.prefix(4))" : authorName
        
        let comment = Comment(
            postID: postID,
            content: newComment.trimmingCharacters(in: .whitespacesAndNewlines),
            authorID: userID,
            authorName: finalAuthorName
        )
        
        isPostingComment = true
        
        Task {
            do {
                _ = try await FirebaseService.shared.addComment(comment)
                await MainActor.run {
                    self.newComment = ""
                    self.isPostingComment = false
                }
                await loadComments()
            } catch {
                await MainActor.run {
                    self.isPostingComment = false
                    self.errorMessage = "Failed to post comment: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Comment Row View
struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.authorName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "8B9A7E"))
                
                Spacer()
                
                Text(formatDate(comment.createdAt.dateValue()))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
            }
            
            Text(comment.content)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
        }
        .padding()
        .background(Color(hex: "DDE3D0"))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    PostDetailView(post: ForumPost(
        title: "Sample Post",
        content: "This is a sample post content",
        authorID: "user123",
        authorName: "John Doe"
    ))
    .environmentObject(UserDataManager.shared)
}

