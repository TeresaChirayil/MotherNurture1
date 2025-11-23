//
//  CommunityFeedView.swift
//  MotherNurture1
//
//  Community Feed View matching the design
//

import SwiftUI
import FirebaseFirestore

struct CommunityFeedView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var posts: [Post] = []
    @State private var filteredPosts: [Post] = []
    @State private var searchText: String = ""
    @State private var selectedFilter: FilterType = .all
    @State private var isLoading = false
    @State private var showCreatePost = false
    @State private var showPostDetail: Post?
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case myPosts = "My Posts"
        case popular = "Popular"
    }
    
    var body: some View {
        ZStack {
            // Dark olive green background
            Color(hex: "5C3D2E")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    // Title and Icons
                    HStack {
                        Text("Community Feed")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            
                            Toggle("", isOn: .constant(false))
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                .labelsHidden()
                            
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search...", text: $searchText)
                            .foregroundColor(.black)
                            .onChange(of: searchText) { _, newValue in
                                filterPosts()
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    // Filter Buttons
                    HStack(spacing: 12) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                                loadPosts()
                            }) {
                                Text(filter.rawValue)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(selectedFilter == filter ? .white : Color(hex: "5C3D2E"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? Color(hex: "5C3D2E") : Color.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Posts List
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                } else if filteredPosts.isEmpty {
                    Spacer()
                    Text("No posts found")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPosts) { post in
                                PostCardView(post: post, currentUserID: userDataManager.profile.userID ?? "")
                                    .onTapGesture {
                                        showPostDetail = post
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 100) // Space for Create Post button
                    }
                    .refreshable {
                        loadPosts()
                    }
                }
                
                // Create Post Button
                Button(action: {
                    showCreatePost = true
                }) {
                    HStack {
                        Text("Create Post")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "5C3D2E"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            loadPosts()
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView(onPostCreated: {
                loadPosts()
            })
            .environmentObject(userDataManager)
        }
        .sheet(item: $showPostDetail) { post in
            PostDetailView(post: post, onPostUpdated: {
                loadPosts()
            })
                .environmentObject(userDataManager)
        }
    }
    
    private func loadPosts() {
        isLoading = true
        Task {
            do {
                let fetchedPosts: [Post]
                switch selectedFilter {
                case .all:
                    fetchedPosts = try await FirebaseService.shared.fetchAllPosts()
                case .myPosts:
                    guard let userID = userDataManager.profile.userID else {
                        fetchedPosts = []
                        break
                    }
                    fetchedPosts = try await FirebaseService.shared.fetchUserPosts(userID: userID)
                case .popular:
                    fetchedPosts = try await FirebaseService.shared.fetchPopularPosts()
                }
                
                await MainActor.run {
                    self.posts = fetchedPosts
                    filterPosts()
                    isLoading = false
                }
            } catch {
                print("Error loading posts: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func filterPosts() {
        if searchText.isEmpty {
            filteredPosts = posts
        } else {
            let lowerQuery = searchText.lowercased()
            filteredPosts = posts.filter { post in
                post.title.lowercased().contains(lowerQuery) ||
                post.description.lowercased().contains(lowerQuery)
            }
        }
    }
}

// MARK: - Post Card View
struct PostCardView: View {
    let post: Post
    let currentUserID: String
    @State private var isLiked: Bool
    @State private var likeCount: Int
    @State private var commentCount: Int
    
    init(post: Post, currentUserID: String) {
        self.post = post
        self.currentUserID = currentUserID
        _isLiked = State(initialValue: post.likes.contains(currentUserID))
        _likeCount = State(initialValue: post.likeCount)
        _commentCount = State(initialValue: post.commentCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and Date
            HStack {
                Text(post.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(formatDate(post.createdAt.dateValue()))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color(hex: "8B9A7E"))
                    
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9A7E"))
                }
            }
            
            // Username
            Text(post.username)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "8B9A7E"))
            
            // Description
            Text(post.description)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
                .lineLimit(2)
            
            // Engagement (Likes and Comments)
            HStack(spacing: 16) {
                Button(action: {
                    toggleLike()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(.black)
                        Text("\(likeCount)")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .foregroundColor(.black)
                    Text("\(commentCount)")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            HStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.trailing, 16)
            }
            .padding(.top, 16)
        )
    }
    
    private func toggleLike() {
        Task {
            do {
                try await FirebaseService.shared.toggleLike(postID: post.id ?? "", userID: currentUserID)
                await MainActor.run {
                    if isLiked {
                        likeCount -= 1
                        isLiked = false
                    } else {
                        likeCount += 1
                        isLiked = true
                    }
                }
            } catch {
                print("Error toggling like: \(error)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    CommunityFeedView()
        .environmentObject(UserDataManager.shared)
}

