//
//  CreatePostView.swift
//  MotherNurture1
//
//  View for creating new posts
//

import SwiftUI

struct CreatePostView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isPosting = false
    
    let onPostCreated: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        TextField("Enter post title...", text: $title)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 200)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "9BA897"), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Post Button
                    Button(action: {
                        createPost()
                    }) {
                        Text(isPosting ? "Posting..." : "Post")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canPost ? Color(hex: "5C3D2E") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canPost || isPosting)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                }
            }
        }
    }
    
    private var canPost: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func createPost() {
        guard let userID = userDataManager.profile.userID else {
            print("Error: No user ID")
            return
        }
        
        let username = userDataManager.profile.firstName ?? "user\(userID.prefix(4))"
        
        isPosting = true
        
        Task {
            do {
                let post = Post(
                    title: title.trimmingCharacters(in: .whitespaces),
                    description: description.trimmingCharacters(in: .whitespaces),
                    userID: userID,
                    username: username
                )
                
                _ = try await FirebaseService.shared.createPost(post)
                
                await MainActor.run {
                    isPosting = false
                    dismiss()
                    onPostCreated()
                }
            } catch {
                print("Error creating post: \(error)")
                await MainActor.run {
                    isPosting = false
                }
            }
        }
    }
}

#Preview {
    CreatePostView(onPostCreated: {})
        .environmentObject(UserDataManager.shared)
}

