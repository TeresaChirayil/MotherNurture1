////
////  LinksView.swift
////  MotherNurture1
////
////  Created by 40 GO Participant on 11/4/25.
////
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

    // Tunables for compact layout (non-scrollable content)
    private let headerHeight: CGFloat = 360 // taller photo/green area
    private let contentSpacing: CGFloat = 2    // tight spacing again
    private let chipSpacing: CGFloat = 4
    private let maxBioLines: Int = 3
    private let maxTagRows: Int = 1
    
    var body: some View {
        GeometryReader { geo in
            let maxCardHeight = min(geo.size.height, 680) // keep taller cap if needed
            
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

                // Solid separator between header and content
                Divider()
                    .background(Color.black.opacity(0.12))
                    .zIndex(1)

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
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.connectGreen)
                                        .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                        .background(Color.white)
                    }
                    
                    if isTop {
                        // Bio (slightly more breathing room)
                        Text(profile.bio)
                            .font(.title3)
                            .foregroundColor(.primaryText)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 6)
                            .padding(.bottom, 8)
                        
                        // Tags: show up to maxTagRows, then add "+N more"
                        TagRowsView(tags: profile.tags, chipSpacing: chipSpacing, maxRows: maxTagRows)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 4)
                .padding(.bottom, 2)
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

// Tags with capped rows and “+N more”
private struct TagRowsView: View {
    let tags: [String]
    let chipSpacing: CGFloat
    let maxRows: Int

    @State private var selectedTag: String? = nil
    @State private var isTooltipVisible: Bool = false

    // Track truncation state for each tag by its exact string
    @State private var truncated: [String: Bool] = [:]

    var body: some View {
        GeometryReader { geo in
            content(for: geo.size.width)
        }
        .frame(minHeight: 0)
    }

    private func buildRows(for width: CGFloat) -> [[String]] {
        var rows: [[String]] = [[]]
        var currentRowWidth: CGFloat = 0

        let paddingH: CGFloat = 6 + 6 // approximate left+right inside chip
        let chipSpacing = chipSpacing
        let font = UIFont.systemFont(ofSize: 12)

        func chipWidth(for label: String) -> CGFloat {
            let labelWidth = label.size(withAttributes: [.font: font]).width
            return labelWidth + paddingH + 12 // include background + some fudge factor
        }

        for tag in tags {
            let widthNeeded = chipWidth(for: tag)
            if currentRowWidth + widthNeeded + (rows.last!.isEmpty ? 0 : chipSpacing) <= width {
                rows[rows.count - 1].append(tag)
                currentRowWidth += widthNeeded + (rows.last!.count == 1 ? 0 : chipSpacing)
            } else {
                if rows.count < maxRows {
                    rows.append([tag])
                    currentRowWidth = widthNeeded
                } else {
                    break
                }
            }
        }

        let placedCount = rows.flatMap { $0 }.count
        let remaining = max(0, tags.count - placedCount)

        if remaining > 0, var lastRow = rows.last {
            if remaining == 1 {
                let lastVisibleIndex = placedCount
                if lastVisibleIndex < tags.count {
                    let singleHidden = tags[lastVisibleIndex]
                    let singleHiddenWidth = chipWidth(for: singleHidden)
                    let currentWidth = lastRow.reduce(CGFloat(0)) { partial, label in
                        let w = chipWidth(for: label)
                        return partial + (partial == 0 ? w : (w + chipSpacing))
                    }
                    if currentWidth + (currentWidth == 0 ? 0 : chipSpacing) + singleHiddenWidth <= width {
                        lastRow.append(singleHidden)
                        rows[rows.count - 1] = lastRow
                    } else {
                        let moreLabel = "+1 more"
                        let moreWidth = chipWidth(for: moreLabel)
                        if currentWidth + (currentWidth == 0 ? 0 : chipSpacing) + moreWidth <= width {
                            lastRow.append(moreLabel)
                            rows[rows.count - 1] = lastRow
                        }
                    }
                }
            } else {
                let moreLabel = "+\(remaining) more"
                let moreWidth = chipWidth(for: moreLabel)
                let currentWidth = lastRow.reduce(CGFloat(0)) { partial, label in
                    let w = chipWidth(for: label)
                    return partial + (partial == 0 ? w : (w + chipSpacing))
                }
                if currentWidth + (currentWidth == 0 ? 0 : chipSpacing) + moreWidth <= width {
                    lastRow.append(moreLabel)
                    rows[rows.count - 1] = lastRow
                }
            }
        }

        return rows
    }

    private func content(for width: CGFloat) -> some View {
        let rows = buildRows(for: width)

        return VStack(alignment: .leading, spacing: chipSpacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(alignment: .center, spacing: chipSpacing) {
                    ForEach(rows[rowIndex], id: \.self) { tag in
                        ZStack(alignment: .top) {
                            ChipLabel(title: tag, chipSpacing: chipSpacing, truncated: $truncated)
                                .frame(height: 32) // lock chip height for even rows
                                .contentShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    var shouldShow = false
                                    var displayText: String? = nil

                                    if tag.hasPrefix("+") && tag.contains("more") {
                                        let allVisible = rows.flatMap { $0 }.filter { !$0.hasPrefix("+") }
                                        let hidden = Array(tags.dropFirst(allVisible.count))
                                        if hidden.count == 1, let only = hidden.first {
                                            displayText = only
                                        } else if hidden.count > 1 {
                                            displayText = hidden.joined(separator: ", ")
                                        }
                                        shouldShow = displayText != nil
                                    } else {
                                        shouldShow = truncated[tag] == true
                                        displayText = tag
                                    }

                                    if shouldShow, let text = displayText {
                                        withAnimation(.easeInOut) {
                                            if isTooltipVisible && selectedTag == text {
                                                isTooltipVisible = false
                                                selectedTag = nil
                                            } else {
                                                selectedTag = text
                                                isTooltipVisible = true
                                            }
                                        }
                                    } else if isTooltipVisible {
                                        withAnimation(.easeInOut) {
                                            isTooltipVisible = false
                                            selectedTag = nil
                                        }
                                    }
                                }

                            if isTooltipVisible && selectedTag == (tag.hasPrefix("+") && tag.contains("more")
                                                                    ? {
                                                                        let allVisible = rows.flatMap { $0 }.filter { !$0.hasPrefix("+") }
                                                                        let hidden = Array(tags.dropFirst(allVisible.count))
                                                                        if hidden.count == 1, let only = hidden.first { return only }
                                                                        if hidden.count > 1 { return hidden.joined(separator: ", ") }
                                                                        return nil
                                                                      }()
                                                                    : tag) {
                                let bubbleText: String = {
                                    if tag.hasPrefix("+") && tag.contains("more") {
                                        let allVisible = rows.flatMap { $0 }.filter { !$0.hasPrefix("+") }
                                        let hidden = Array(tags.dropFirst(allVisible.count))
                                        if hidden.isEmpty { return "" }
                                        // Bullet each hidden tag on a new line
                                        return hidden.map { "• \($0)" }.joined(separator: "\n")
                                    } else {
                                        return selectedTag ?? ""
                                    }
                                }()

                                TooltipBubble(text: bubbleText)
                                    .offset(y: -44)
                                    .transition(.opacity)
                                    .zIndex(1)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .leading)
            }
        }
        .onTapGesture {
            if isTooltipVisible {
                withAnimation(.easeInOut) {
                    isTooltipVisible = false
                    selectedTag = nil
                }
            }
        }
        .contentShape(Rectangle())
    }
}

// A chip label that measures whether its text is truncated in the given layout
private struct ChipLabel: View {
    let title: String
    let chipSpacing: CGFloat

    @Binding var truncated: [String: Bool]

    // We render the visible text with lineLimit(1) and also render an invisible
    // reference that measures the intrinsic size to compare.
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(title)
                .font(.callout)
                .foregroundColor(.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.cardAccent.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    GeometryReader { visibleGeo in
                        Color.clear
                            .onAppear { updateTruncation(visibleSize: visibleGeo.size) }
                            .onChange(of: visibleGeo.size) { _, newSize in
                                updateTruncation(visibleSize: newSize)
                            }
                    }
                )
                .accessibilityLabel(Text(title))

            // Hidden reference text to get intrinsic width without line limit
            Text(title)
                .font(.callout)
                .foregroundColor(.clear)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.clear)
                .overlay(
                    GeometryReader { fullGeo in
                        Color.clear
                            .preference(key: IntrinsicWidthKey.self, value: fullGeo.size.width)
                    }
                )
                .hidden()
        }
        .onPreferenceChange(IntrinsicWidthKey.self) { fullWidth in
            // Compare fullWidth with the visible width captured in updateTruncation
            // The visible width is stored via the latest measurement
            // Because we can't store both in a single pass here, updateTruncation stores into truncated[title]
        }
    }

    private func updateTruncation(visibleSize: CGSize) {
        let font = UIFont.preferredFont(forTextStyle: .callout)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let intrinsicTextWidth = (title as NSString).size(withAttributes: attributes).width
        let intrinsic = intrinsicTextWidth + 10 + 10 // horizontal padding
        let isTruncated = intrinsic > visibleSize.width
        if truncated[title] != isTruncated {
            truncated[title] = isTruncated
        }
    }
}

private struct IntrinsicWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Readable tooltip bubble used for truncated tags and "+N more" details
private struct TooltipBubble: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
            .frame(maxWidth: 220, alignment: .leading) // cap width for readability
            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 2)
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
    @State private var navigateToMessages: Bool = false
    @State private var groupToNavigateTo: Channel? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isAnimatingSwipe: Bool = false
    
    private let swipeThreshold: CGFloat = 100
    private let rotationAngle: Double = 5.0
    
    private var rotation: Double {
        Double(offset.width / 20) * rotationAngle
    }
    
    private var topCard: Profile? {
        profiles.first
    }
    
    // Handle swipe by animating and removing the top card. No matchmaking/like recording.
    private func handleSwipe(isMatch: Bool) {
        guard !isAnimatingSwipe else { return }
        if topCard != nil {
            performSwipeAnimation(isMatch: isMatch)
            if profiles.count <= 1 {
                Task { await loadProfiles() }
            }
        }
    }
    
    private func performSwipeAnimation(isMatch: Bool) {
        guard topCard != nil else { return }
        guard !isAnimatingSwipe else { return }
        isAnimatingSwipe = true
        
        let targetOffset = CGSize(width: isMatch ? 650 : -650, height: 0)
        let springAnimation = Animation.spring(response: 0.55, dampingFraction: 0.55)
        
        lastOffset = .zero
        
        withAnimation(springAnimation) {
            offset = targetOffset
        }
        
        let animationCompletionTime = 0.35
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(animationCompletionTime * 1_000_000_000))
            withAnimation(.easeOut(duration: 0.15)) {
                if !profiles.isEmpty {
                    profiles.removeFirst()
                }
                offset = .zero
                lastOffset = .zero
            }
            isAnimatingSwipe = false
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
                            .padding(.horizontal, 24)
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
                    .disabled(topCard == nil || isAnimatingSwipe)
                    
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
                    .disabled(topCard == nil || isAnimatingSwipe)
                }
                .padding(.bottom, 60)
                
                Spacer(minLength: 0)
            }
            .background(Color.appBackground.ignoresSafeArea())
            // Removed fullScreenCover for match popup
            
            .navigationDestination(isPresented: $navigateToMessages) {
                MessagesView(channel: Channel(name: "Direct Message", timeAgo: "now", isDirectMessage: true))
                    .environmentObject(userDataManager)
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
                if matchmakingProfiles.isEmpty {
                    self.profiles = mockProfiles
                } else {
                    self.profiles = matchmakingProfiles
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load profiles: \(error.localizedDescription)"
                self.showError = true
                self.profiles = mockProfiles
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
}

// --- Preview Structure ---
struct MatchmakingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchmakingView()
    }
}

/*
 // LinksView (commented out). This older view also defined another `Profile` type,
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

