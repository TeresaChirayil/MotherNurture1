//  LinksView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//
import SwiftUI

// Custom Brand Colors based on tutorial view
extension Color {
    static let appBackground = Color(hex: "F8F5EE") // Cream
    static let primaryText = Color(hex: "5C3D2E") // Deep Brown
    static let connectGreen = Color(hex: "8B9A7E") // Darker Sage Green (Connect/Like)
    static let cardAccent = Color(hex: "9BA897") // Lighter Sage Green
    static let skipRed = Color.red.opacity(0.8) // Using a standard red for skip (contrast)
}

// - b-- 1. Data Model (Profile) ---
public struct Profile: Identifiable, Equatable {
    public let id: String // Use userID for stable identification
    let name: String
    let age: Int
    let location: String
    let profilePicFileName: String? // Optional: for asset names (legacy)
    let profilePicURL: String? // Optional: for photo URLs from Firebase
    let bio: String
    let tags: [String]
    let groups: [String]
    
    init(id: String = UUID().uuidString, name: String, age: Int, location: String, profilePicFileName: String? = nil, profilePicURL: String? = nil, bio: String, tags: [String], groups: [String]) {
        self.id = id
        self.name = name
        self.age = age
        self.location = location
        self.profilePicFileName = profilePicFileName
        self.profilePicURL = profilePicURL
        self.bio = bio
        self.tags = tags
        self.groups = groups
    }
}

// --- 2. Mock Data (fallback when no real profiles available) ---
let mockProfiles: [Profile] = [
    Profile(
        id: "mock_jessica",
        name: "Jessica R. ",
        age: 29,
        location: "1.2 mi away",
        profilePicFileName: "SmilingMomWithDaugther",
        profilePicURL: nil,
        bio: "Just moved to the area. Looking for a playdate partner and parenting book recommendations.",
        tags: ["New in Town", "Infant (6m)", "Book Lover", "Pumping"],
        groups: ["Get to Know Eachother!", "New Mom", "Mother of Children w/ Disabilities"]
    ),
    Profile(
        id: "mock_chloe",
        name: "Chloe D. ",
        age: 25,
        location: "0.5 mi away",
        profilePicFileName: "MomWithPointingBaby",
        profilePicURL: nil,
        bio: "SAHM running on fumes and cuddles. We love museums, baking, and quiet parks.",
        tags: ["Stay-at-Home", "Toddler (3)", "Baking Enthusiast"],
        groups: ["Get to Know Eachother!", "Expecting Moms"]
    ),
    Profile(
        id: "mock_sarah",
        name: "Sarah B. ",
        age: 23,
        location: "5 mi away",
        profilePicFileName: "GrassGirl",
        profilePicURL: nil,
        bio: "First-time mom navigating toddler tantrums. Coffee is my fuel! Looking for walking buddies and playground meetups.",
        tags: ["Working Mom", "Toddler (2)", "Loves Outdoors", "DIY & Crafts"],
        groups: ["Get to Know Eachother!", "New Moms"]
    ),
    Profile(
        id: "mock_emily",
        name: "Emily P. ",
        age: 35,
        location: "7 mi away",
        profilePicFileName: "HappyMom",
        profilePicURL: nil,
        bio: "Twin mom survivalist! Looking for someone to share cheap activity ideas. Send help (and coffee).",
        tags: ["Twin Mom", "Coffee Addict", "Budgeting"],
        groups: ["Get to Know Eachother!", "Single Moms"]
    ),
    Profile(
        id: "mock_maria",
        name: "Maria C. ",
        age: 38,
        location: "8 mi away",
        profilePicFileName: "ExtremelyHappyLady",
        profilePicURL: nil,
        bio: "Veteran mom of three, finally getting back into yoga. Seeking advice on navigating middle school.",
        tags: ["School-age Kids", "Yoga & Wellness", "Car Pool Queen", "Single Mom"],
        groups: ["Get to Know Eachother!", "Single Moms", "Mother of Children w/ Disabilities"]
    ),
]

// --- Stateless flow layout for wrapping chips (no @State) ---
private struct FlowRows: Layout {
    var spacing: CGFloat = 6
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return CGSize(width: proposal.width ?? result.maxLineWidth, height: result.totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: .unspecified
            )
        }
    }
    
    private func layout(in maxWidth: CGFloat, subviews: Subviews) -> (frames: [CGRect], totalHeight: CGFloat, maxLineWidth: CGFloat) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxLineWidth: CGFloat = 0
        
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                // wrap
                maxLineWidth = max(maxLineWidth, x - spacing)
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        maxLineWidth = max(maxLineWidth, x > 0 ? x - spacing : 0)
        let totalHeight = y + lineHeight
        return (frames, totalHeight, maxLineWidth)
    }
}

// --- 4. Individual Card View ---
struct CardView: View {
    let profile: Profile
    let isTop: Bool
    let onGroupTapped: (String) -> Void
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var showBlockConfirmation = false
    @State private var showReportConfirmation = false
    @State private var showFullBio: Bool = false

    // Tunables for compact layout (non-scrollable content)
    private let headerHeight: CGFloat = 300 // increased to show more of the photo/green area
    private let contentSpacing: CGFloat = 2    // tight spacing again
    private let chipSpacing: CGFloat = 6
    private let maxBioLines: Int = 2
    private let maxTagRows: Int = 2
    
    var body: some View {
        GeometryReader { geo in
            let maxCardHeight = min(geo.size.height, 680) // keep taller cap if needed
            
            let headerRatio: CGFloat = 0.65
            let headerHeight = maxCardHeight * headerRatio
            let contentHeight = maxCardHeight - headerHeight
            
            VStack(alignment: .leading, spacing: 0) {
                // Image/Header Area
                ZStack(alignment: .bottomLeading) {
                    // Show photo from URL if available, otherwise asset name, otherwise green placeholder
                    if let photoURL = profile.profilePicURL, !photoURL.isEmpty {
                        AsyncImage(url: URL(string: photoURL)) { phase in
                            switch phase {
                            case .empty:
                                Color(hex: "9BA897")
                                    .frame(height: headerHeight)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: headerHeight)
                                    .clipped()
                            case .failure:
                                Color(hex: "9BA897")
                                    .frame(height: headerHeight)
                            @unknown default:
                                Color(hex: "9BA897")
                                    .frame(height: headerHeight)
                            }
                        }
                    } else if let assetName = profile.profilePicFileName, !assetName.isEmpty {
                        Image(assetName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: headerHeight)
                            .clipped()
                    } else {
                        Color(hex: "9BA897")
                            .frame(height: headerHeight)
                    }

                    // Overlay content with name/age, location
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(profile.name), \(profile.age)")
                                    .font(.system(size: 24, weight: .heavy))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)

                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text(profile.location)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer(minLength: 8)
                            
                            // Menu button for block/report
                            if isTop {
                                Menu {
                                    Button(role: .destructive, action: {
                                        showBlockConfirmation = true
                                    }) {
                                        Label("Block User", systemImage: "person.crop.circle.badge.xmark")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        showReportConfirmation = true
                                    }) {
                                        Label("Report User", systemImage: "flag")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12) // small lift
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.45)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: headerHeight) // ensure header has fixed height
                .clipped() // ensure gradient/overlays don't bleed below header

                // Removed Divider() to avoid stealing vertical space

                // Content area (non-scrollable)
                VStack(alignment: .leading, spacing: contentSpacing) {
                    // Groups first
                    Group {
                        FlowRows(spacing: chipSpacing) {
                            ForEach(limitedGroups(profile.groups), id: \.self) { group in
                                Button {
                                    onGroupTapped(group)
                                } label: {
                                    Text(group)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 3)
                                        .background(Color.connectGreen)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 6) // increased for consistent gap to bio
                        .background(Color.white)
                    }
                    
                    if isTop {
                        // Bio (slightly more breathing room)
                        Text(profile.bio)
                            .font(.body)
                            .foregroundColor(.primaryText)
                            .lineLimit(maxBioLines)
                            .fixedSize(horizontal: false, vertical: true)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showFullBio = true
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 4)
                        
                        // Tags: show up to maxTagRows, then add "+N more"
                        ExpandableTagsView(tags: profile.tags, chipSpacing: chipSpacing, maxRows: maxTagRows)
                            .padding(.top, 6) // gap from bio to tags
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(height: contentHeight) // explicit content height frame added
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: maxCardHeight) // cap the total card height
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .confirmationDialog("Block User", isPresented: $showBlockConfirmation, titleVisibility: .visible) {
            Button("Block", role: .destructive) {
                Task { await blockUser() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Block \(profile.name)? You won't see their profile anymore.")
        }
        .confirmationDialog("Report User", isPresented: $showReportConfirmation, titleVisibility: .visible) {
            Button("Report", role: .destructive) {
                reportUser()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Report \(profile.name) for inappropriate behavior?")
        }
        .blur(radius: showFullBio ? 6 : 0, opaque: false)
        .overlay(alignment: .center) {
            if showFullBio {
                ZStack {
                    // Transparent hit area to allow tap outside to dismiss
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation(.easeInOut) { showFullBio = false } }

                    VStack(spacing: 12) {
                        Text("Bio")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        ScrollView {
                            Text(profile.bio)
                                .font(.body)
                                .foregroundColor(.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        }
                        .frame(maxHeight: 260)

                        Button(action: { withAnimation(.easeInOut) { showFullBio = false } }) {
                            Text("Close")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.connectGreen)
                                .cornerRadius(10)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: 320)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                    )
                    .offset(y: -20) // slightly above center like system alerts
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(2)
                .ignoresSafeArea()
            }
        }
    }
    
    // Show first few groups then "+N more"
    private func limitedGroups(_ groups: [String], cap: Int = 6) -> [String] {
        guard groups.count > cap else { return groups }
        let remaining = groups.count - cap
        return Array(groups.prefix(cap)) + ["+\(remaining) more"]
    }
    
    private func blockUser() async {
        guard let currentUserID = userDataManager.profile.userID else { return }
        
        do {
            try await FirebaseService.shared.blockUser(userID: currentUserID, userIDToBlock: profile.id)
            
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
        } catch {
            print("Error blocking user: \(error)")
        }
    }
    
    private func reportUser() {
        MailHelper.reportUser(userID: profile.id, userName: profile.name)
    }
}

private struct ExpandableTagsView: View {
    let tags: [String]
    let chipSpacing: CGFloat
    let maxRows: Int

    @State private var isExpanded: Bool = false

    var body: some View {
        GeometryReader { geo in
            content(width: geo.size.width)
        }
        .frame(minHeight: 0)
        .animation(.easeInOut, value: isExpanded)
    }

    private func buildRows(for width: CGFloat, expanded: Bool) -> ([[TagItem]], Bool, Int) {
        // Returns: rows, didTruncate, hiddenCount
        guard width > 0 else { return ([], false, 0) }

        let horizontalPadding: CGFloat = 6 + 6
        let chipExtra: CGFloat = 12 // extra background/fudge
        let font = UIFont.systemFont(ofSize: 12)

        var rows: [[TagItem]] = [[]]
        var currentRowWidth: CGFloat = 0

        func chipWidth(for text: String) -> CGFloat {
            let labelWidth = text.size(withAttributes: [.font: font]).width
            return labelWidth + horizontalPadding + chipExtra
        }

        var didTruncate = false
        var hiddenCount = 0

        if expanded {
            for tag in tags {
                let w = chipWidth(for: tag)
                if currentRowWidth + w + (rows.last!.isEmpty ? 0 : chipSpacing) <= width {
                    rows[rows.count - 1].append(.tag(tag))
                    currentRowWidth += w + (rows.last!.count == 1 ? 0 : chipSpacing)
                } else {
                    rows.append([.tag(tag)])
                    currentRowWidth = w
                }
            }
            // Append the "Show less" button if it fits
            let showLessText = "Show less"
            let showLessWidth = chipWidth(for: showLessText)
            if var last = rows.last {
                let currentWidth = last.reduce(CGFloat(0)) { partial, item in
                    switch item {
                    case .tag(let t): return partial + chipWidth(for: t)
                    case .more(let n): return partial + chipWidth(for: "+\(n) more")
                    case .showLess: return partial + showLessWidth
                    }
                } + CGFloat(max(last.count - 1, 0)) * chipSpacing
                if currentWidth + (last.isEmpty ? 0 : chipSpacing) + showLessWidth <= width {
                    last.append(.showLess)
                    rows[rows.count - 1] = last
                } else {
                    rows.append([.showLess])
                }
            }
            return (rows, false, 0)
        }

        // Collapsed: pack up to maxRows; if overflow, append +N more
        for (idx, tag) in tags.enumerated() {
            let w = chipWidth(for: tag)
            if currentRowWidth + w + (rows.last!.isEmpty ? 0 : chipSpacing) <= width {
                rows[rows.count - 1].append(.tag(tag))
                currentRowWidth += w + (rows.last!.count == 1 ? 0 : chipSpacing)
            } else {
                if rows.count < maxRows {
                    rows.append([.tag(tag)])
                    currentRowWidth = w
                } else {
                    didTruncate = true
                    hiddenCount = tags.count - idx
                    break
                }
            }
        }

        // If truncated, try to place the +N more chip on the last row; if it doesn't fit, replace last tag
        if didTruncate, let lastRow = rows.last {
            let moreText = "+\(hiddenCount) more"
            let moreWidth = chipWidth(for: moreText)
            var row = lastRow
            let currentWidth = row.reduce(CGFloat(0)) { partial, item in
                switch item {
                case .tag(let t): return partial + chipWidth(for: t)
                case .more(let n): return partial + chipWidth(for: "+\(n) more")
                case .showLess: return partial + moreWidth // unlikely in collapsed state but added for completeness
                }
            } + CGFloat(max(row.count - 1, 0)) * chipSpacing

            if currentWidth + chipSpacing + moreWidth <= width {
                row.append(.more(hiddenCount))
                rows[rows.count - 1] = row
            } else if !row.isEmpty {
                // replace the last tag with +N more
                row.removeLast()
                row.append(.more(hiddenCount))
                rows[rows.count - 1] = row
            }
        }

        return (rows, didTruncate, hiddenCount)
    }

    private enum TagItem: Hashable {
        case tag(String)
        case more(Int)
        case showLess
    }

    @ViewBuilder
    private func content(width: CGFloat) -> some View {
        let (rows, _, _) = buildRows(for: width, expanded: isExpanded)
        let chipHeight: CGFloat = 24

        VStack(alignment: .leading, spacing: chipSpacing) {
            ForEach(Array(rows.enumerated()), id: \.0) { _, row in
                HStack(spacing: chipSpacing) {
                    ForEach(row, id: \.self) { item in
                        switch item {
                        case .tag(let text):
                            Button(action: {}) {
                                Text(text)
                                    .font(.caption)
                                    .foregroundColor(.primaryText)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 5)
                                    .background(Color.cardAccent.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        case .more(let n):
                            Button(action: { withAnimation { isExpanded = true } }) {
                                Text("+\(n) more")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(Color.connectGreen)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        case .showLess:
                            Button(action: { withAnimation { isExpanded = false } }) {
                                Text("Show less")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(Color.connectGreen)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: chipHeight, alignment: .leading)
            }
        }
    }
}

// --- 5. Main Matchmaking View with Swiping Logic ---
struct MatchmakingView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var profiles: [Profile] = []
    @State private var isLoading: Bool = true
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var feedbackText: String? = nil
    @State private var showMatchPopup: Bool = false
    @State private var matchedProfile: Profile? = nil
    @State private var navigateToMessages: Bool = false
    @State private var groupToNavigateTo: Channel? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isAnimatingSwipe: Bool = false
    
    // Persisted progress (namespaced per user)
    @AppStorage("mm_seenProfileIDs") private var persistedSeenProfileIDsRaw: String = ""
    @AppStorage("mm_currentIndex") private var persistedCurrentIndex: Int = 0
    @AppStorage("mm_shuffleSeed") private var persistedShuffleSeed: Int = 0

    private var currentUserNamespace: String { userDataManager.profile.userID ?? "guest" }

    private var seenProfileIDs: Set<String> {
        get {
            let key = "mm_seenProfileIDs_\(currentUserNamespace)"
            let raw = UserDefaults.standard.string(forKey: key) ?? ""
            return Set(raw.split(separator: ",").map(String.init))
        }
        nonmutating set {
            let key = "mm_seenProfileIDs_\(currentUserNamespace)"
            let raw = newValue.joined(separator: ",")
            UserDefaults.standard.set(raw, forKey: key)
        }
    }

    private var currentIndex: Int {
        get {
            let key = "mm_currentIndex_\(currentUserNamespace)"
            return UserDefaults.standard.integer(forKey: key)
        }
        nonmutating set {
            let key = "mm_currentIndex_\(currentUserNamespace)"
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    private var shuffleSeed: Int {
        get {
            let key = "mm_shuffleSeed_\(currentUserNamespace)"
            let value = UserDefaults.standard.integer(forKey: key)
            return value
        }
        nonmutating set {
            let key = "mm_shuffleSeed_\(currentUserNamespace)"
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    private let swipeThreshold: CGFloat = 100
    private let rotationAngle: Double = 5.0
    
    private var rotation: Double {
        Double(offset.width / 20) * rotationAngle
    }
    
    private var topCard: Profile? {
        guard !profiles.isEmpty else { return nil }
        let idx = min(max(currentIndex, 0), profiles.count - 1)
        return profiles.indices.contains(idx) ? profiles[idx] : nil
    }
    
    private func performSwipeAnimation(isMatch: Bool) {
        guard topCard != nil else { return }
        guard !isAnimatingSwipe else { return }
        isAnimatingSwipe = true
        
        let targetOffset = CGSize(width: isMatch ? 500 : -500, height: 0)

        let springAnimation: Animation = isMatch
            ? .spring(response: 0.2, dampingFraction: 0.5)   // right swipe (like)
            : .spring(response: 0.25, dampingFraction: 1.0)  // left swipe (skip = faster)
        
        lastOffset = .zero
        
        withAnimation(springAnimation) {
            offset = targetOffset
        }
        
        let animationCompletionTime = 0.3
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(animationCompletionTime * 1_000_000_000))
            withAnimation(.easeOut(duration: 0.15)) {
                offset = .zero
                lastOffset = .zero
                let next = currentIndex + 1
                currentIndex = next
            }
            isAnimatingSwipe = false
        }
    }
    
    private func handleSwipe(isMatch: Bool) {
        guard !isAnimatingSwipe else { return }
        if let card = topCard {
            // Mark seen for this user
            var ids = seenProfileIDs
            ids.insert(card.id)
            seenProfileIDs = ids
            
            if isMatch {
                matchedProfile = card
                showMatchPopup = true
            }
            performSwipeAnimation(isMatch: isMatch)
            
            if currentIndex >= profiles.count {
                Task { await loadProfiles() }
            }
        }
    }
    
    private func handleGroupTap(_ groupName: String) {
        let channel = Channel(name: groupName, timeAgo: "now", isDirectMessage: false)
        groupToNavigateTo = channel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Find Your Village")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .padding(.top, 16)
                
                if isLoading {
                    ProgressView()
                        .padding(.bottom, 4)
                }
                
                if let feedback = feedbackText {
                    Text(feedback)
                        .font(.headline)
                        .foregroundColor(feedback.contains("Match") ? .connectGreen : .skipRed)
                        .animation(.easeInOut, value: feedback)
                }
                
                GeometryReader { geo in
                    let maxHeight = min(geo.size.height * 0.9, 640)
                    
                    ZStack {
                        if let card = topCard {
                            CardView(profile: card, isTop: true, onGroupTapped: { group in
                                handleGroupTap(group)
                            })
                            .environmentObject(userDataManager)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                            .background(Color.clear)
                            .offset(offset)
                            .rotationEffect(.degrees(rotation))
                            .allowsHitTesting(!isAnimatingSwipe)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        guard !isAnimatingSwipe else { return }
                                        offset = CGSize(
                                            width: gesture.translation.width + lastOffset.width,
                                            height: gesture.translation.height + lastOffset.height
                                        )
                                    }
                                    .onEnded { _ in
                                        guard !isAnimatingSwipe else { return }
                                        if offset.width > swipeThreshold {
                                            handleSwipe(isMatch: true)
                                        } else if offset.width < -swipeThreshold {
                                            handleSwipe(isMatch: false)
                                        } else {
                                            withAnimation(.spring()) {
                                                offset = .zero
                                            }
                                            lastOffset = .zero
                                        }
                                    }
                            )
                        } else if isLoading {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading profiles...")
                                    .foregroundColor(.gray)
                                    .padding(.top, 6)
                            }
                            .frame(height: maxHeight)
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundColor(.gray)
                                Text("No more profiles available")
                                    .foregroundColor(.gray)
                                Text("Check back later for new connections")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.7))
                                
                                Button(action: {
                                    Task {
                                        await loadProfiles()
                                    }
                                }) {
                                    Text("Refresh")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.connectGreen)
                                        .cornerRadius(12)
                                        .padding(.top, 8)
                                }
                            }
                            .frame(height: maxHeight)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: 640)
                
                // External working buttons (swipe actions)
                HStack(spacing: 32) {
                    Button {
                        handleSwipe(isMatch: false)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 66, height: 66)
                            .background(Color.skipRed)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .disabled(topCard == nil || isAnimatingSwipe || currentIndex >= profiles.count)
                    
                    Button {
                        handleSwipe(isMatch: true)
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 66, height: 66)
                            .background(Color.connectGreen)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .disabled(topCard == nil || isAnimatingSwipe || currentIndex >= profiles.count)
                }
                .padding(.bottom, 60)
                
                Spacer(minLength: 0)
            }
            .fullScreenCover(isPresented: $showMatchPopup) {
                if let profile = matchedProfile {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            Text("🎉 It’s a Match!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                            
                            Text("You and \(profile.name) matched!")
                                .font(.headline)
                                .foregroundColor(.primaryText)
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    if let profile = matchedProfile {
                                        let newChannel = Channel(
                                            name: profile.name.trimmingCharacters(in: .whitespaces),
                                            timeAgo: "now",
                                            isDirectMessage: true
                                        )
                                        ChannelsManager.shared.addChannel(newChannel)
                                    }
                                    navigateToMessages = true
                                    showMatchPopup = false
                                }) {
                                    Text("Message")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: 130)
                                        .background(Color.connectGreen)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showMatchPopup = false
                                }) {
                                    Text("Keep Swiping")
                                        .font(.headline)
                                        .foregroundColor(.primaryText)
                                        .padding()
                                        .frame(maxWidth: 130)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(32)
                    }
                } else {
                    Color.clear.ignoresSafeArea()
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationDestination(isPresented: $navigateToMessages) {
                if let profile = matchedProfile {
                    let channelName = profile.name.trimmingCharacters(in: .whitespaces)
                    MessagesView(channel: Channel(name: channelName, timeAgo: "now", isDirectMessage: true))
                        .environmentObject(userDataManager)
                } else {
                    MessagesView(channel: Channel(name: "Direct Message", timeAgo: "now", isDirectMessage: true))
                        .environmentObject(userDataManager)
                }
            }
            .navigationDestination(item: $groupToNavigateTo) { channel in
                MessagesView(channel: channel)
                    .environmentObject(userDataManager)
            }
            .task {
                await loadProfiles()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if currentIndex < 0 { currentIndex = 0 }
            }
        }
    }
    
    // MARK: - Load Profiles from Firebase
    private func loadProfiles() async {
        isLoading = true
        do {
            let currentUserID = userDataManager.profile.userID
            let userProfiles = try await FirebaseService.shared.fetchAllUserProfiles(
                excludingUserID: currentUserID,
                limit: 50
            )
            let matchmakingProfiles = userProfiles.compactMap { userProfile -> Profile? in
                convertToMatchmakingProfile(userProfile)
            }
            await MainActor.run {
                var base = matchmakingProfiles
                if base.isEmpty { base = mockProfiles }
                // Exclude seen
                let unseen = base.filter { !seenProfileIDs.contains($0.id) }
                // Ensure per-user seed
                if shuffleSeed == 0 {
                    let seed = Int((userDataManager.profile.userID ?? UUID().uuidString).hashValue & 0x7fffffff)
                    shuffleSeed = max(1, seed)
                }
                let shuffled = shuffleDeterministic(unseen, seed: shuffleSeed)
                self.profiles = shuffled
                if currentIndex >= self.profiles.count { currentIndex = 0 }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load profiles: \(error.localizedDescription)"
                self.showError = true
                let unseen = mockProfiles.filter { !seenProfileIDs.contains($0.id) }
                if shuffleSeed == 0 {
                    let seed = Int((userDataManager.profile.userID ?? UUID().uuidString).hashValue & 0x7fffffff)
                    shuffleSeed = max(1, seed)
                }
                self.profiles = shuffleDeterministic(unseen, seed: shuffleSeed)
                if currentIndex >= self.profiles.count { currentIndex = 0 }
            }
            print("Error loading profiles: \(error)")
        }
    }
    
    // MARK: - Convert UserProfile to Profile
    private func convertToMatchmakingProfile(_ userProfile: UserProfile) -> Profile? {
        guard let firstName = userProfile.firstName, !firstName.isEmpty else {
            return nil
        }
        
        let lastName = userProfile.lastName ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        
        let age: Int
        if let dateOfBirth = userProfile.dateOfBirth {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
            age = ageComponents.year ?? 0
        } else if let ageRange = userProfile.ageRange {
            if ageRange == "18-21" {
                age = 20
            } else if ageRange == "22-25" {
                age = 24
            } else if ageRange == "26-29" {
                age = 28
            } else if ageRange == "30+" {
                age = 32
            } else {
                age = 28
            }
        } else {
            age = 28
        }
        
        let location: String
        if let town = userProfile.town, !town.isEmpty {
            location = "\(town)"
        } else if let zipcode = userProfile.zipcode, !zipcode.isEmpty {
            location = "\(zipcode)"
        } else {
            location = "Nearby"
        }
        
        let profilePicURL: String?
        if let photoURL = userProfile.photoURL, !photoURL.isEmpty {
            if photoURL.hasPrefix("http://") || photoURL.hasPrefix("https://") {
                profilePicURL = photoURL
            } else {
                profilePicURL = nil
            }
        } else {
            profilePicURL = nil
        }
        let profilePicFileName: String? = nil
        
        let bio: String
        if let description = userProfile.shortDescription, !description.isEmpty {
            bio = description
        } else {
            let interestsText = userProfile.interests?.joined(separator: ", ") ?? ""
            let tagsText = userProfile.parentTags?.joined(separator: ", ") ?? ""
            if !interestsText.isEmpty || !tagsText.isEmpty {
                bio = "\(tagsText)\(tagsText.isEmpty ? "" : ". ")\(interestsText.isEmpty ? "" : "Loves \(interestsText).")"
            } else {
                bio = "Looking to connect with other moms!"
            }
        }
        
        var tags: [String] = []
        if let parentTags = userProfile.parentTags {
            tags.append(contentsOf: parentTags)
        }
        if let interests = userProfile.interests {
            tags.append(contentsOf: interests)
        }
        if let childAges = userProfile.childAges, !childAges.isEmpty {
            let ageStrings: [String] = childAges.compactMap { age -> String? in
                guard age >= 0 else { return nil }
                if age == 0 {
                    return "Newborn"
                } else if age < 1 {
                    return "Infant"
                } else if age < 3 {
                    return "Toddler (\(age))"
                } else if age < 13 {
                    return "Child (\(age))"
                } else {
                    return "Teen (\(age))"
                }
            }
            tags.append(contentsOf: ageStrings)
        }
        
        let groups = userProfile.channelMemberships ?? []
        let profileID = userProfile.userID ?? UUID().uuidString
        
        return Profile(
            id: profileID,
            name: fullName,
            age: age,
            location: location,
            profilePicFileName: profilePicFileName,
            profilePicURL: profilePicURL,
            bio: bio,
            tags: tags,
            groups: groups
        )
    }
    
    private func shuffleDeterministic<T>(_ array: [T], seed: Int) -> [T] {
        guard array.count > 1 else { return array }
        var rng = SeededGenerator(seed: UInt64(seed))
        return array.shuffled(using: &rng)
    }

    private struct SeededGenerator: RandomNumberGenerator {
        private var state: UInt64
        init(seed: UInt64) {
            self.state = seed != 0 ? seed : 0x9E3779B97F4A7C15
        }
        mutating func next() -> UInt64 {
            state = 2862933555777941757 &* state &+ 3037000493
            return state
        }
    }
}

// --- Preview Structure ---
struct MatchmakingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchmakingView()
    }
}

/*
 // LEGACY LinksView (commented out as requested). This older view also defined another `Profile` type,
 // which conflicted with the matchmaking Profile. Keeping it commented avoids identity/rendering issues.
 
 import SwiftUI

 struct LinksView: View {
     @Environment(\.dismiss) var dismiss
     @State private var profiles: [SimpleProfile] = [
         SimpleProfile(name: "Sarah", age: 28, bio: "Mom of two beautiful kids. Love hiking and coffee.", image: "person.circle.fill"),
         SimpleProfile(name: "Jessica", age: 32, bio: "Single mom, working professional. Enjoy reading and cooking.", image: "person.circle.fill"),
         SimpleProfile(name: "Emily", age: 30, bio: "Mom of one. Passionate about fitness and healthy living.", image: "person.circle.fill"),
         SimpleProfile(name: "Amanda", age: 35, bio: "Mother of three. Love traveling and photography.", image: "person.circle.fill")
     ]
     @State private var currentIndex = 0
     @State private var dragOffset: CGSize = .zero
     @State private var showChannels = false
     @State private var currentTab: TabDestination = .links

     var body: some View {
         NavigationStack {
             ZStack {
                 Color(hex: "F8F5EE")
                     .ignoresSafeArea()

                 VStack(spacing: 0) {
                     Spacer(minLength: 0)

                     ZStack {
                         if currentIndex < profiles.count {
                             LegacyProfileCard(profile: profiles[currentIndex])
                                 .offset(x: dragOffset.width, y: dragOffset.height)
                                 .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                                 .gesture(
                                     DragGesture()
                                         .onChanged { value in
                                             dragOffset = value.translation
                                         }
                                         .onEnded { value in
                                             if abs(value.translation.width) > 150 {
                                                 removeCurrentProfile()
                                             } else {
                                                 withAnimation {
                                                     dragOffset = .zero
                                                 }
                                             }
                                         }
                                 )
                                 .animation(.spring(), value: dragOffset)
                         } else {
                             VStack(spacing: 16) {
                                 Text("No more profiles")
                                     .font(.system(size: 20, weight: .bold, design: .rounded))
                                     .foregroundColor(Color(hex: "5C3D2E"))

                                 Text("Check back later for new matches")
                                     .font(.system(size: 16, design: .rounded))
                                     .foregroundColor(Color(hex: "5C3D2E"))
                                     .multilineTextAlignment(.center)
                             }
                             .padding(40)
                         }
                     }
                     .frame(maxWidth: .infinity)
                     .padding(.horizontal, 20)
                     .padding(.top, 20)
                     .padding(.bottom, 20)

                     Spacer()

                     HStack(spacing: 40) {
                         Button(action: swipeLeft) {
                             ZStack {
                                 Circle()
                                     .fill(Color(hex: "F8F5EE"))
                                     .frame(width: 60, height: 60)
                                     .overlay(Circle().stroke(Color(hex: "5C3D2E"), lineWidth: 2))

                                 Image(systemName: "xmark")
                                     .foregroundColor(Color(hex: "5C3D2E"))
                                     .font(.system(size: 24, weight: .bold))
                             }
                         }
                         .buttonStyle(PlainButtonStyle())

                         Button(action: swipeRight) {
                             ZStack {
                                 Circle()
                                     .fill(Color(hex: "8B9A7E"))
                                     .frame(width: 60, height: 60)

                                 Image(systemName: "heart.fill")
                                     .foregroundColor(Color(hex: "5C3D2E"))
                                     .font(.system(size: 24))
                             }
                         }
                         .buttonStyle(PlainButtonStyle())
                     }
                     .padding(.bottom, 100)
                 }
                 .overlay(alignment: .bottom) {
                     BottomNavBar(current: .constant(.links))
                         .padding(.bottom, 5)
                 }
             }
             .toolbar(.hidden, for: .navigationBar)
         }
     }

     private func swipeLeft() {
         withAnimation {
             dragOffset = CGSize(width: -500, height: 0)
         }
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
             removeCurrentProfile()
         }
     }

     private func swipeRight() {
         withAnimation {
             dragOffset = CGSize(width: 500, height: 0)
         }
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
             removeCurrentProfile()
         }
     }

     private func removeCurrentProfile() {
         if currentIndex < profiles.count {
             profiles.remove(at: currentIndex)
             dragOffset = .zero
         }
     }
 }

 struct LegacyProfileCard: View {
     let profile: SimpleProfile

     var body: some View {
         VStack(alignment: .leading, spacing: 0) {
             ZStack {
                 RoundedRectangle(cornerRadius: 20)
                     .fill(Color(hex: "8B9A7E"))
                     .frame(height: 500)

                 Image(systemName: profile.image)
                     .foregroundColor(Color(hex: "5C3D2E"))
                     .font(.system(size: 120))
             }

             VStack(alignment: .leading, spacing: 1) {
                 HStack {
                     Text(profile.name)
                         .font(.system(size: 28, weight: .bold, design: .rounded))
                         .foregroundColor(Color(hex: "5C3D2E"))

                     Text("\(profile.age)")
                         .font(.system(size: 24, weight: .medium, design: .rounded))
                         .foregroundColor(Color(hex: "5C3D2E"))
                 }

                 Text(profile.bio)
                     .font(.system(size: 16, design: .rounded))
                     .foregroundColor(Color(hex: "5C3D2E"))
                     .lineLimit(3)
             }
             .padding(20)
             .frame(maxWidth: .infinity, alignment: .leading)
             .background(Color(hex: "F8F5EE"))
         }
         .cornerRadius(20)
         .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
     }
 }

 struct SimpleProfile: Identifiable {
     let id = UUID()
     let name: String
     let age: Int
     let bio: String
     let image: String
 }
*/

