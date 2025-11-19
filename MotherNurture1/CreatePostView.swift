//
//  CreatePostView.swift
//  MotherNurture1
//
//  Created for community forum feature
//

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    
    @State private var title: String = "" // retained internally but not shown; will be derived from content
    @State private var content: String = ""
    @State private var tags: String = ""
    @State private var isPosting: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    @State private var postAnonymously: Bool = false
    @State private var showCancelConfirm: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content, tags
    }
    
    var onPostCreated: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Content Field (only)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Content")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("Share your thoughts, ask questions, or connect with the community...")
                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.4))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                        .font(.system(size: 16, design: .rounded))
                                }
                                
                                TextEditor(text: $content)
                                    .focused($focusedField, equals: .content)
                                    .frame(minHeight: 200)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .content ? Color(hex: "8B9A7E") : Color(hex: "9BA897").opacity(0.3), lineWidth: 2)
                                    )
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .font(.system(size: 16, design: .rounded))
                                    .scrollContentBackground(.hidden)
                            }
                            
                            Text("\(content.count)/1000 characters")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(content.count > 1000 ? .red : Color(hex: "5C3D2E").opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Tags Field (optional)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tags (optional)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            Text("Add tags to help others find your post")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                            
                            TextField("e.g., ParentingTips, Activities, Advice", text: $tags)
                                .focused($focusedField, equals: .tags)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .tags ? Color(hex: "8B9A7E") : Color(hex: "9BA897").opacity(0.3), lineWidth: 2)
                                )
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .font(.system(size: 16, design: .rounded))
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                }
                            
                            if !tags.isEmpty {
                                let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                                if !tagArray.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(tagArray, id: \.self) { tag in
                                                HStack(spacing: 4) {
                                                    Text("#\(tag)")
                                                        .font(.system(size: 12, weight: .medium))
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 10))
                                                }
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color(hex: "8B9A7E"))
                                                .cornerRadius(16)
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Anonymity Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $postAnonymously) {
                                Text("Post anonymously")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "8B9A7E")))
                            
                            Text("If enabled, your post will show as \"Anonymous\" to others. Your account is still associated privately.")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Post Button (Fixed at bottom)
                VStack {
                    Spacer()
                    Button(action: createPost) {
                        HStack(spacing: 12) {
                            if isPosting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Post")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(canPost ? Color(hex: "8B9A7E") : Color(hex: "9BA897").opacity(0.5))
                        .cornerRadius(16)
                        .shadow(color: canPost ? Color(hex: "8B9A7E").opacity(0.3) : .clear, radius: 8, y: 4)
                    }
                    .disabled(!canPost || isPosting)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Use navigationBarLeading to ensure visibility in sheet
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        handleCancel()
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                }
            }
            .confirmationDialog(
                "Discard this post?",
                isPresented: $showCancelConfirm,
                titleVisibility: .visible
            ) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) { }
            } message: {
                Text("You have unsent changes. This action cannot be undone.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your post has been created successfully!")
            }
        }
        .presentationDetents([.large])
    }
    
    private var canPost: Bool {
        !content.trimmingCharacters(in: .whitespaces).isEmpty &&
        content.count <= 1000
    }
    
    private func handleCancel() {
        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            tags.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            dismiss()
        } else {
            showCancelConfirm = true
        }
    }
    
    private func derivedTitle(from content: String) -> String {
        // Use the first non-empty line as the title, trimmed to 100 chars
        let firstLine = content
            .components(separatedBy: .newlines)
            .first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? "Post"
        return String(firstLine.prefix(100))
    }
    
    private func createPost() {
        // Require login (Option B: pseudonymous)
        guard let userID = userDataManager.profile.userID else {
            errorMessage = "Please log in to create a post"
            showError = true
            return
        }
        
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedContent.isEmpty else {
            errorMessage = "Please add some content"
            showError = true
            return
        }
        
        guard trimmedContent.count <= 1000 else {
            errorMessage = "Content must be 1000 characters or less"
            showError = true
            return
        }
        
        // Determine authorName based on anonymity toggle
        let displayName: String
        if postAnonymously {
            displayName = "Anonymous"
        } else {
            let authorName = "\(userDataManager.profile.firstName ?? "") \(userDataManager.profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
            displayName = authorName.isEmpty ? "user\(userID.prefix(4))" : authorName
        }
        
        // Parse tags
        let tagArray = tags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let finalTags = tagArray.isEmpty ? nil : Array(tagArray)
        
        // Derive a title from content to satisfy ForumPost initializer
        let computedTitle = derivedTitle(from: trimmedContent)
        
        let post = ForumPost(
            title: computedTitle,
            content: trimmedContent,
            authorID: userID,          // Store real userID (pseudonymous)
            authorName: displayName,   // Show "Anonymous" if toggled
            tags: finalTags
        )
        
        isPosting = true
        
        Task {
            do {
                _ = try await FirebaseService.shared.createPost(post)
                await MainActor.run {
                    isPosting = false
                    showSuccess = true
                    // Clear fields after successful post
                    title = ""
                    content = ""
                    tags = ""
                    postAnonymously = false
                    focusedField = nil
                }
                // Dismiss after a short delay
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                await MainActor.run {
                    dismiss()
                    onPostCreated?()
                }
            } catch {
                await MainActor.run {
                    isPosting = false
                    let errorDesc = error.localizedDescription.lowercased()
                    if errorDesc.contains("permission") || errorDesc.contains("insufficient") {
                        errorMessage = "Permission denied. Please check your Firebase security rules to allow write access to the 'forumPosts' collection for authenticated users."
                    } else {
                        errorMessage = "Failed to create post: \(error.localizedDescription)"
                    }
                    showError = true
                }
            }
        }
    }
}

#Preview {
    CreatePostView()
        .environmentObject(UserDataManager.shared)
}
