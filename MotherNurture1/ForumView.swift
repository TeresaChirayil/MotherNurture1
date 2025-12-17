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
                // Unified warm background
                Color(hex: "F8F5EE")
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
                    
                    // Topic Cards - horizontally scrollable
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Topics")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recommendedTags, id: \.self) { tag in
                                    TopicCard(
                                        tag: tag,
                                        isSelected: selectedTag == tag,
                                        onTap: {
                                            if selectedTag == tag {
                                                selectedTag = nil
                                                searchText = ""
                                            } else {
                                                selectedTag = tag
                                                searchText = tag
                                            }
                                            Task { await loadPosts() }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    // Filter Buttons
                    HStack(spacing: 10) {
                        ForEach(FeedFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                                Task { await loadPosts() }
                            }) {
                                Text(filter.rawValue)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(selectedFilter == filter ? .white : Color(hex: "5C3D2E"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? Color(hex: "8B9A7E") : Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    
                    // Posts Feed
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "8B9A7E")))
                        Spacer()
                    } else if filteredPosts.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "8B9A7E").opacity(0.5))
                            Text("No posts yet")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            Text("Be the first to start a conversation!")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
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
                // Reload profile to get latest blocked users
                if let userID = userDataManager.profile.userID {
                    do {
                        if let updatedProfile = try await FirebaseService.shared.getUserProfile(userID: userID) {
                            await MainActor.run {
                                userDataManager.profile = updatedProfile
                            }
                        }
                    } catch {
                        print("Error reloading profile: \(error)")
                    }
                }
                await loadPosts()
                await loadLikedPosts()
            }
            .onAppear {
                Task {
                    // Reload profile to get latest blocked users
                    if let userID = userDataManager.profile.userID {
                        do {
                            if let updatedProfile = try await FirebaseService.shared.getUserProfile(userID: userID) {
                                await MainActor.run {
                                    userDataManager.profile = updatedProfile
                                }
                            }
                        } catch {
                            print("Error reloading profile: \(error)")
                        }
                    }
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
            
            // Filter out posts from blocked users
            var filteredPosts = fetchedPosts
            if let currentUserID = userDataManager.profile.userID,
               let blockedUsers = userDataManager.profile.blockedUsers {
                filteredPosts = fetchedPosts.filter { post in
                    !blockedUsers.contains(post.authorID)
                }
            }
            
            await MainActor.run {
                self.posts = filteredPosts
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

// MARK: - Topic Card View
struct TopicCard: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private var iconName: String {
        switch tag.lowercased() {
        case "pregnancy": return "heart.fill"
        case "newborn": return "moon.stars.fill"
        case "breastfeeding": return "drop.fill"
        case "sleep": return "bed.double.fill"
        case "postpartum": return "sparkles"
        case "self-care": return "leaf.fill"
        case "nutrition": return "carrot.fill"
        case "milestones": return "star.fill"
        case "toddler": return "figure.walk"
        case "mental health": return "brain.head.profile"
        case "work-life": return "briefcase.fill"
        case "single parenting": return "person.fill"
        case "support": return "hand.raised.fill"
        case "birth stories": return "book.fill"
        default: return "tag.fill"
        }
    }
    
    private var gradientColors: [Color] {
        if isSelected {
            return [Color(hex: "8B9A7E"), Color(hex: "6B7A5E")]
        }
        return [Color.white, Color(hex: "F8F5EE")]
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.2) : Color(hex: "8B9A7E").opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : Color(hex: "8B9A7E"))
                }
                
                Text(tag)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color(hex: "5C3D2E"))
                    .lineLimit(1)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(
                LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(14)
            .shadow(color: isSelected ? Color(hex: "8B9A7E").opacity(0.3) : Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color(hex: "8B9A7E").opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
    @State private var showBlockConfirmation = false
    @State private var showReportConfirmation = false
    @State private var showDeleteConfirmation = false
    let post: ForumPost
    var onRefresh: (() -> Void)?
    
    init(post: ForumPost, isLiked: Bool, onRefresh: (() -> Void)? = nil) {
        self.post = post
        self._isLiked = State(initialValue: isLiked)
        self._likeCount = State(initialValue: post.likeCount)
        self._commentCount = State(initialValue: post.commentCount)
        self.onRefresh = onRefresh
    }
    
    private var isOwnPost: Bool {
        guard let userID = userDataManager.profile.userID else { return false }
        return post.authorID == userID
    }
    
    private var canBlockOrReport: Bool {
        guard let userID = userDataManager.profile.userID else { return false }
        return post.authorID != userID
    }

    private var displayContent: String {
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
        Button(action: {
            showPostDetail = true
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Header with author info and menu
                HStack(spacing: 10) {
                    // Author avatar
                    Circle()
                        .fill(Color(hex: "8B9A7E").opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(post.authorName.prefix(1).uppercased())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorName)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Text(timeAgo(post.createdAt.dateValue()))
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.5))
                    }
                    
                    Spacer()
                    
                    Menu {
                        if isOwnPost {
                            Button(role: .destructive, action: {
                                showDeleteConfirmation = true
                            }) {
                                Label("Delete Post", systemImage: "trash")
                            }
                        } else {
                            Button(role: .destructive, action: {
                                showBlockConfirmation = true
                            }) {
                                Label("Block User", systemImage: "person.crop.circle.badge.xmark")
                            }
                            
                            Button(role: .destructive, action: {
                                showReportConfirmation = true
                            }) {
                                Label("Report Post", systemImage: "flag")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.5))
                            .font(.system(size: 16))
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Title
                Text(post.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                
                // Content (avoid duplicating title)
                if !displayContent.isEmpty {
                    Text(displayContent)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                }
                
                // Tags
                if let tags = post.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "8B9A7E"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(hex: "8B9A7E").opacity(0.15))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 10)
                }
                
                // Divider
                Rectangle()
                    .fill(Color(hex: "5C3D2E").opacity(0.08))
                    .frame(height: 1)
                    .padding(.top, 14)
                
                // Actions bar
                HStack(spacing: 0) {
                    // Like button
                    Button(action: { toggleLike() }) {
                        HStack(spacing: 6) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(isLiked ? Color(hex: "E57373") : Color(hex: "5C3D2E").opacity(0.6))
                            Text("\(likeCount)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Vertical divider
                    Rectangle()
                        .fill(Color(hex: "5C3D2E").opacity(0.08))
                        .frame(width: 1, height: 24)
                    
                    // Comment button
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 17))
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                        Text("\(commentCount)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
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
        .confirmationDialog("Block User", isPresented: $showBlockConfirmation, titleVisibility: .visible) {
            Button("Block", role: .destructive) {
                Task { await blockUser() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Block \(post.authorName)? You won't see their posts anymore.")
        }
        .confirmationDialog("Report Post", isPresented: $showReportConfirmation, titleVisibility: .visible) {
            Button("Report", role: .destructive) {
                reportPost()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Report this post for inappropriate content?")
        }
        .confirmationDialog("Delete Post", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task { await deletePost() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this post? This cannot be undone.")
        }
    }
    
    private func deletePost() async {
        guard let postID = post.id else { return }
        do {
            try await FirebaseService.shared.deletePost(postID: postID)
            onRefresh?()
        } catch {
            print("Error deleting post: \(error)")
        }
    }
    
    private func blockUser() async {
        guard let currentUserID = userDataManager.profile.userID else { return }
        
        do {
            try await FirebaseService.shared.blockUser(userID: currentUserID, userIDToBlock: post.authorID)
            
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
            
            // Refresh posts to filter out blocked user
            onRefresh?()
        } catch {
            print("Error blocking user: \(error)")
        }
    }
    
    private func reportPost() {
        let postID = post.id ?? "unknown"
        MailHelper.reportPost(postID: postID, postTitle: post.title, authorName: post.authorName)
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
    
    private func timeAgo(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear], from: date, to: now)
        
        if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 min ago" : "\(minutes) mins ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    ForumView()
        .environmentObject(UserDataManager.shared)
}
