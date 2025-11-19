//
//  ForumView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/5/25.
//

import SwiftUI
import FirebaseFirestore

enum FeedFilter: String, CaseIterable {
    case all = "All"
    case myPosts = "My Posts"
    case popular = "Popular"
}

struct ForumView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var showChannels = false
    @State private var showLinks = false
    @State private var currentTab: TabDestination = .forum
    @State private var showCreatePost = false
    @State private var posts: [ForumPost] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @FocusState private var searchFocused: Bool
    @State private var selectedFilter: FeedFilter = .all
    @State private var likedPostIDs: Set<String> = []
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Recommended mothering tags (used for suggestions)
    @State private var recommendedTags: [String] = [
        "Pregnancy", "Newborn", "Breastfeeding", "Sleep", "Postpartum",
        "Self-Care", "Nutrition", "Milestones", "Toddler", "Mental Health",
        "Work-Life", "Single Parenting", "Support", "Birth Stories"
    ]
    @State private var selectedTag: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Two-tone background: top white, bottom green
                VStack(spacing: 0) {
                    Color.white
                        .frame(height: 180)
                        .ignoresSafeArea(edges: .top)
                    Color(hex: "8B9A7E")
                        .ignoresSafeArea()
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with centered title
                    ZStack {
                        Text("Forum")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        HStack { Spacer() }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    .background(Color.white.opacity(0.001))
                    
                    // Search Bar
                    VStack(spacing: 6) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .font(.system(size: 18, weight: .semibold))
                            
                            TextField("Search posts, authors, or topics", text: $searchText)
                                .focused($searchFocused)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onChange(of: searchText) { _, newValue in
                                    // Keep tag selection in sync with search when it exactly matches a tag
                                    if let exactTag = recommendedTags.first(where: { $0.caseInsensitiveCompare(newValue) == .orderedSame }) {
                                        selectedTag = exactTag
                                    } else {
                                        selectedTag = nil
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                    selectedTag = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                                }
                                .accessibilityLabel("Clear search")
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(Color(hex: "F1F3EE"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "8B9A7E").opacity(0.4), lineWidth: 1)
                        )
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 20)
                        
                        // Suggestions panel (tags + titles) shown when searching
                        if shouldShowSuggestions {
                            SuggestionsPanel(
                                tagSuggestions: tagSuggestions,
                                titleSuggestions: titleSuggestions,
                                onSelect: { suggestion in
                                    searchText = suggestion
                                    // If selected suggestion is a tag, remember it
                                    if let matchedTag = recommendedTags.first(where: { "#\($0)".caseInsensitiveCompare(suggestion) == .orderedSame || $0.caseInsensitiveCompare(suggestion) == .orderedSame }) {
                                        selectedTag = matchedTag
                                    } else {
                                        selectedTag = nil
                                    }
                                    searchFocused = false
                                    Task { await loadPosts() }
                                }
                            )
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Filter Buttons - styled to match compact look
                    HStack(spacing: 10) {
                        ForEach(FeedFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                                Task { await loadPosts() }
                            }) {
                                Text(filter.rawValue)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(selectedFilter == filter ? .white : Color(hex: "5C3D2E"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 9)
                                    .background(selectedFilter == filter ? Color(hex: "8B9A7E") : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color(hex: "8B9A7E").opacity(selectedFilter == filter ? 0 : 0.45), lineWidth: 1)
                                    )
                                    .cornerRadius(18)
                                    .shadow(color: .black.opacity(selectedFilter == filter ? 0.08 : 0.04), radius: 4, x: 0, y: 2)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    
                    // Posts Feed
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Spacer()
                    } else if filteredPosts.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.6))
                            Text("No posts yet")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            Text("Be the first to create a post!")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredPosts) { post in
                                    PostRowView(
                                        post: post,
                                        isLiked: likedPostIDs.contains(post.id ?? ""),
                                        onRefresh: {
                                            Task {
                                                await loadPosts()
                                                await loadLikedPosts()
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                    
                    Spacer()
                }
                
                // Add Post Button (Big Plus Button at Bottom)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showCreatePost = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(Color(hex: "8B9A7E"))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                // Bottom Nav Bar
                VStack {
                    Spacer()
                    BottomNavBar(currentTab: $currentTab)
                        .padding(.bottom, 5)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCreatePost, onDismiss: {
                Task {
                    await loadPosts()
                    await loadLikedPosts()
                }
            }) {
                CreatePostView {
                    Task {
                        await loadPosts()
                    }
                }
                .environmentObject(userDataManager)
            }
            .task {
                await loadPosts()
                await loadLikedPosts()
            }
            .onAppear {
                Task {
                    await loadPosts()
                    await loadLikedPosts()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Suggestions
    private var shouldShowSuggestions: Bool {
        searchFocused && !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var tagSuggestions: [String] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return recommendedTags
            .filter { $0.localizedCaseInsensitiveContains(q) }
            .prefix(8)
            .map { "#\($0)" }
    }
    
    private var titleSuggestions: [String] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        // Use currently loaded posts for quick suggestions
        return posts
            .map { $0.title }
            .filter { $0.localizedCaseInsensitiveContains(q) }
            .uniqued()
            .prefix(8)
            .map { $0 }
    }
    
    private var filteredPosts: [ForumPost] {
        var filtered = posts
        
        // Apply search filter (matches title, content, author, tags)
        if !searchText.isEmpty {
            filtered = filtered.filter { post in
                post.title.localizedCaseInsensitiveContains(searchText) ||
                post.content.localizedCaseInsensitiveContains(searchText) ||
                post.authorName.localizedCaseInsensitiveContains(searchText) ||
                (post.tags ?? []).contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered
    }
    
    private func loadPosts() async {
        isLoading = true
        
        do {
            let fetchedPosts: [ForumPost]
            
            switch selectedFilter {
            case .all:
                fetchedPosts = try await FirebaseService.shared.fetchPosts()
            case .myPosts:
                guard let userID = userDataManager.profile.userID else {
                    await MainActor.run {
                        self.posts = []
                        self.isLoading = false
                    }
                    return
                }
                fetchedPosts = try await FirebaseService.shared.fetchUserPosts(userID: userID)
            case .popular:
                fetchedPosts = try await FirebaseService.shared.fetchPopularPosts()
            }
            
            await MainActor.run {
                self.posts = fetchedPosts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                let errorDesc = error.localizedDescription.lowercased()
                if errorDesc.contains("permission") || errorDesc.contains("insufficient") {
                    self.posts = []
                } else {
                    self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    private func loadLikedPosts() async {
        guard let userID = userDataManager.profile.userID else { return }
        
        do {
            let likedIDs = try await FirebaseService.shared.fetchLikedPosts(userID: userID)
            await MainActor.run {
                self.likedPostIDs = Set(likedIDs)
            }
        } catch {
            print("Error loading liked posts: \(error)")
        }
    }
}

// MARK: - Suggestions Panel View
private struct SuggestionsPanel: View {
    let tagSuggestions: [String]
    let titleSuggestions: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !tagSuggestions.isEmpty {
                SectionHeader("Tags")
                ForEach(tagSuggestions, id: \.self) { suggestion in
                    SuggestionRow(icon: "number", text: suggestion) {
                        onSelect(suggestion)
                    }
                }
                Divider().padding(.horizontal, 12)
            }
            
            if !titleSuggestions.isEmpty {
                SectionHeader("Titles")
                ForEach(titleSuggestions, id: \.self) { suggestion in
                    SuggestionRow(icon: "text.alignleft", text: suggestion) {
                        onSelect(suggestion)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    @ViewBuilder
    private func SectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
    }
    
    private struct SuggestionRow: View {
        let icon: String
        let text: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "8B9A7E"))
                        .frame(width: 18)
                    Text(text)
                        .foregroundColor(Color(hex: "5C3D2E"))
                        .font(.system(size: 15, design: .rounded))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Helpers
private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        var result: [Element] = []
        for el in self {
            if seen.insert(el).inserted {
                result.append(el)
            }
        }
        return result
    }
}

// MARK: - Post Row View
struct PostRowView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var showPostDetail = false
    @State private var isLiked: Bool
    @State private var likeCount: Int
    @State private var commentCount: Int
    let post: ForumPost
    var onRefresh: (() -> Void)?
    
    init(post: ForumPost, isLiked: Bool, onRefresh: (() -> Void)? = nil) {
        self.post = post
        self._isLiked = State(initialValue: isLiked)
        self._likeCount = State(initialValue: post.likeCount)
        self._commentCount = State(initialValue: post.commentCount)
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        Button(action: {
            showPostDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(post.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formatDate(post.createdAt.dateValue()))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color(hex: "8B9A7E"))
                    
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                        .font(.system(size: 14))
                }
                
                Text(post.authorName)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(hex: "8B9A7E"))
                
                Text(post.content)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.black)
                    .lineLimit(3)
                
                HStack(spacing: 16) {
                    Button(action: {
                        toggleLike()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .black)
                            Text("\(likeCount)")
                                .foregroundColor(.black)
                        }
                        .font(.system(size: 14, design: .rounded))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                            .foregroundColor(.black)
                        Text("\(commentCount)")
                            .foregroundColor(.black)
                    }
                    .font(.system(size: 14, design: .rounded))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.4))
                        .font(.system(size: 12))
                        .padding(.trailing, 12)
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showPostDetail, onDismiss: {
            Task {
                await reloadPost()
                onRefresh?()
            }
        }) {
            PostDetailView(post: post)
                .environmentObject(userDataManager)
        }
    }
    
    private func toggleLike() {
        guard let postID = post.id,
              let userID = userDataManager.profile.userID else { return }
        
        let previousLikeState = isLiked
        let previousCount = likeCount
        
        // Optimistic update
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        
        Task {
            do {
                let newLikeStatus = try await FirebaseService.shared.toggleLike(postID: postID, userID: userID)
                await MainActor.run {
                    self.isLiked = newLikeStatus
                    Task { await reloadPost() }
                }
            } catch {
                await MainActor.run {
                    self.isLiked = previousLikeState
                    self.likeCount = previousCount
                }
            }
        }
    }
    
    private func reloadPost() async {
        guard let postID = post.id else { return }
        
        do {
            let allPosts = try await FirebaseService.shared.fetchPosts()
            if let updatedPost = allPosts.first(where: { $0.id == postID }) {
                await MainActor.run {
                    self.likeCount = updatedPost.likeCount
                    self.commentCount = updatedPost.commentCount
                    if let userID = userDataManager.profile.userID {
                        Task {
                            do {
                                let liked = try await FirebaseService.shared.checkIfLiked(postID: postID, userID: userID)
                                await MainActor.run { self.isLiked = liked }
                            } catch {
                                print("Error checking like status: \(error)")
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error reloading post: \(error)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ForumView()
        .environmentObject(UserDataManager.shared)
}
