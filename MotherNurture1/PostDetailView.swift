//
//  PostDetailView.swift
//  MotherNurture1
//
//  Updated with report post functionality
//

import SwiftUI
import FirebaseFirestore

struct PostDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager

    let post: ForumPost
    @State private var currentPost: ForumPost
    
    @State private var comments: [Comment] = []
    @State private var isLiked: Bool = false
    @State private var newComment: String = ""
    @State private var isLoading: Bool = false
    @State private var isPostingComment: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var commentAnonymously: Bool = false
    
    @State private var showDeletePostConfirmation: Bool = false
    @State private var showReportPostConfirmation: Bool = false
    @State private var showBlockUserConfirmation: Bool = false
    @State private var userToBlock: String? = nil
    
    init(post: ForumPost) {
        self.post = post
        _currentPost = State(initialValue: post)
    }

    private func contentWithoutTitle(_ post: ForumPost) -> String {
        let title = post.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = post.content.trimmingCharacters(in: .whitespacesAndNewlines)

        if content.caseInsensitiveCompare(title) == .orderedSame {
            return ""
        }

        let lines = content.components(separatedBy: .newlines)
        if let firstNonEmptyIndex = lines.firstIndex(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            let firstLine = lines[firstNonEmptyIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            if firstLine.caseInsensitiveCompare(title) == .orderedSame {
                let remaining = lines.dropFirst(firstNonEmptyIndex + 1).joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                return remaining
            }
        }

        return content
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Post Content
                        postContentSection
                        
                        // Comments
                        commentsSection
                        
                        // Add Comment
                        addCommentSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "5C3D2E"))
                    }
                }
                
                // Delete button for author
                if canDeletePost {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showDeletePostConfirmation = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Report button for non-author
                if !canDeletePost {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showReportPostConfirmation = true }) {
                            Image(systemName: "flag")
                                .foregroundColor(.orange)
                        }
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
            .confirmationDialog("Delete Post", isPresented: $showDeletePostConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { Task { await deletePost() } }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this post? This action cannot be undone.")
            }
            .confirmationDialog("Report Post", isPresented: $showReportPostConfirmation, titleVisibility: .visible) {
                Button("Report", role: .destructive) { Task { await reportPost() } }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Report this post as inappropriate or harmful content?")
            }
            .confirmationDialog("Block User", isPresented: $showBlockUserConfirmation, titleVisibility: .visible) {
                Button("Block", role: .destructive) {
                    if let userID = userToBlock {
                        Task { await blockUser(userID) }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Block this user? You won't see their posts or comments anymore.")
            }
        }
        .presentationDetents([.large])
    }
    
    // MARK: - Post Content
    private var postContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(currentPost.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                Spacer()
                Text(formatDate(currentPost.createdAt.dateValue()))
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(hex: "8B9A7E"))
            }
            Text(currentPost.authorName)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "8B9A7E"))

            let displayContent = contentWithoutTitle(currentPost)
            if !displayContent.isEmpty {
                Text(displayContent)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .padding(.top, 4)
            }
            
            if let tags = currentPost.tags, !tags.isEmpty {
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
            
            HStack(spacing: 20) {
                Button(action: toggleLike) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? Color.red : Color(hex: "5C3D2E"))
                        Text("\(currentPost.likeCount)")
                            .foregroundColor(Color(hex: "5C3D2E"))
                    }
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "message")
                        .foregroundColor(Color(hex: "5C3D2E"))
                    Text("\(currentPost.commentCount)")
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
    }
    
    // MARK: - Comments Section
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comments")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
                .padding(.horizontal)
            
            if isLoading {
                ProgressView().frame(maxWidth: .infinity).padding()
            } else if comments.isEmpty {
                Text("No comments yet. Be the first to comment!")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(comments) { comment in
                    CommentRowView(
                        comment: comment,
                        canDelete: canDeleteComment(comment),
                        canBlock: !canDeleteComment(comment) && (userDataManager.profile.userID != nil && comment.authorID != userDataManager.profile.userID),
                        onDelete: {
                            Task { await deleteComment(comment) }
                        },
                        onBlock: {
                            userToBlock = comment.authorID
                            showBlockUserConfirmation = true
                        },
                        onReport: {
                            reportComment(comment)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Add Comment Section
    private var addCommentSection: some View {
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
            
            // Anonymous toggle for comments
            Toggle(isOn: $commentAnonymously) {
                Text("Comment anonymously")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "8B9A7E")))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    // MARK: - Permissions
    private var canDeletePost: Bool {
        guard let userID = userDataManager.profile.userID else { return false }
        return currentPost.authorID == userID
    }
    
    private func canDeleteComment(_ comment: Comment) -> Bool {
        guard let userID = userDataManager.profile.userID else { return false }
        return comment.authorID == userID
    }
    
    // MARK: - Firebase Functions
    private func loadComments() async {
        guard let postID = currentPost.id else { return }
        isLoading = true
        do {
            var fetchedComments = try await FirebaseService.shared.fetchComments(for: postID)
            
            // Filter out comments from blocked users
            if let currentUserID = userDataManager.profile.userID,
               let blockedUsers = userDataManager.profile.blockedUsers {
                fetchedComments = fetchedComments.filter { comment in
                    !blockedUsers.contains(comment.authorID)
                }
            }
            
            await MainActor.run { self.comments = fetchedComments; self.isLoading = false }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
    
    private func postComment() {
        guard let postID = currentPost.id else {
            errorMessage = "Post ID is missing"
            showError = true
            return
        }
        
        // Use the authenticated Firebase Auth user ID directly
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            errorMessage = "Please log in to comment"
            showError = true
            return
        }
        
        let trimmedContent = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            errorMessage = "Comment cannot be empty"
            showError = true
            return
        }
        
        // Filter content for inappropriate language
        let filterResult = ContentFilterService.shared.filterContent(trimmedContent)
        if !filterResult.isSafe {
            errorMessage = filterResult.reason ?? "Your comment contains inappropriate content. Please keep comments respectful and family-friendly."
            showError = true
            return
        }
        
        // Determine authorName based on anonymity toggle
        let displayName: String
        if commentAnonymously {
            displayName = "Anonymous"
        } else {
            let authorName = "\(userDataManager.profile.firstName ?? "") \(userDataManager.profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
            displayName = authorName.isEmpty ? "user\(userID.prefix(4))" : authorName
        }
        
        let comment = Comment(
            postID: postID,
            content: trimmedContent,
            authorID: userID,
            authorName: displayName
        )
        
        isPostingComment = true
        Task {
            do {
                _ = try await FirebaseService.shared.createComment(comment)
                await MainActor.run {
                    self.newComment = ""
                    self.commentAnonymously = false
                    self.isPostingComment = false
                }
                await loadComments()
                await refreshPost()
            } catch {
                await MainActor.run {
                    self.isPostingComment = false
                    self.errorMessage = "Failed to post comment: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func deleteComment(_ comment: Comment) async {
        guard let commentID = comment.id else { return }
        do {
            try await FirebaseService.shared.deleteComment(commentID: commentID)
            await loadComments()
            await refreshPost()
        } catch {
            await MainActor.run {
                errorMessage = "Failed to delete comment: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func deletePost() async {
        guard let postID = currentPost.id else { return }
        do {
            try await FirebaseService.shared.deletePost(postID: postID)
            await MainActor.run { dismiss() }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to delete post: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func toggleLike() {
        guard let postID = currentPost.id,
              let userID = userDataManager.profile.userID else {
            errorMessage = "Please log in to like posts"
            showError = true
            return
        }
        
        Task {
            do {
                let newLikeStatus = try await FirebaseService.shared.toggleLike(postID: postID, userID: userID)
                await MainActor.run { self.isLiked = newLikeStatus }
                await refreshPost()
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to like post: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func checkLikeStatus() async {
        guard let postID = currentPost.id,
              let userID = userDataManager.profile.userID else { return }
        do {
            let liked = try await FirebaseService.shared.checkIfLiked(postID: postID, userID: userID)
            await MainActor.run { self.isLiked = liked }
        } catch {
            print("Error checking like status: \(error)")
        }
    }
    
    private func refreshPost() async {
        guard let postID = currentPost.id else { return }
        do {
            let doc = try await FirebaseService.shared.db.collection("forumPosts").document(postID).getDocument()
            if let data = doc.data(), let updatedPost = ForumPost.fromDictionary(data, id: postID) {
                await MainActor.run { self.currentPost = updatedPost }
            }
        } catch {
            print("Error refreshing post: \(error)")
        }
    }
    
    // MARK: - Report Post
    private func reportPost() async {
        guard let postID = currentPost.id else {
            await MainActor.run {
                self.errorMessage = "Post ID is missing."
                self.showError = true
            }
            return
        }
        
        // Open mail app with pre-filled report email
        MailHelper.reportPost(postID: postID, postTitle: currentPost.title, authorName: currentPost.authorName)
    }
    
    // MARK: - Report Comment
    private func reportComment(_ comment: Comment) {
        let commentID = comment.id ?? "unknown"
        let postID = currentPost.id ?? "unknown"
        MailHelper.reportComment(commentID: commentID, postID: postID, commentContent: comment.content, authorName: comment.authorName)
    }
    
    // MARK: - Block User
    private func blockUser(_ userIDToBlock: String) async {
        guard let currentUserID = userDataManager.profile.userID else {
            await MainActor.run {
                self.errorMessage = "Please log in to block users."
                self.showError = true
            }
            return
        }
        
        do {
            try await FirebaseService.shared.blockUser(userID: currentUserID, userIDToBlock: userIDToBlock)
            
            // Reload user profile to get updated blockedUsers list
            if let userID = userDataManager.profile.userID {
                do {
                    let updatedProfile = try await FirebaseService.shared.getUserProfile(userID: userID)
                    await MainActor.run {
                        if let profile = updatedProfile {
                            userDataManager.profile = profile
                        }
                    }
                } catch {
                    print("Error reloading profile after block: \(error)")
                }
            }
            
            await MainActor.run {
                // Reload comments to filter out blocked user
                Task { await loadComments() }
                // Also reload posts if needed
                Task { await refreshPost() }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to block user: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
    
    // MARK: - Helper
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
