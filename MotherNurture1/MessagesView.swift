//
//  MessagesView.swift
//  MotherNurture1
//

import SwiftUI
import FirebaseFirestore

struct MessagesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    let channel: Channel
    
    @State private var newMessage: String = ""
    @State private var showBlockConfirmation = false
    @State private var showReportConfirmation = false
    @State private var showEndChatConfirmation = false
    @State private var showFilterError = false
    @State private var filterErrorMessage = ""
    @State private var showSendError = false
    @State private var sendErrorMessage = ""
    @State private var messages: [Message] = []
    @State private var messageListener: ListenerRegistration?
    @State private var isLoading = true
    @State private var selectedUserProfile: UserProfile? = nil
    @State private var showUserProfile = false
    @State private var userProfilesCache: [String: UserProfile] = [:]
    @State private var showEditChannel = false
    @State private var editableChannel: Channel
    @State private var isEditingTitle = false
    @State private var editedTitle: String = ""
    @State private var isSavingTitle = false
    @State private var showTitleSaveError = false
    @State private var titleSaveErrorMessage = ""
    @State private var otherUserDeleted = false
    @State private var showOtherUserDeletedAlert = false
    
    init(channel: Channel) {
        self.channel = channel
        self._editableChannel = State(initialValue: channel)
        self._editedTitle = State(initialValue: channel.name)
    }
    
    private var canBlockOrReport: Bool {
        channel.isDirectMessage // Only allow block/report for direct messages
    }
    
    private var currentUserID: String? {
        userDataManager.profile.userID
    }

    private var canEditTitle: Bool {
        guard let userId = currentUserID, !editableChannel.isDirectMessage else { return false }
        return editableChannel.isAdmin(userId: userId)
    }
    
    private var currentUserName: String {
        let firstName = userDataManager.profile.firstName ?? ""
        let lastName = userDataManager.profile.lastName ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return fullName.isEmpty ? "User" : fullName
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F8F5EE").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .font(.system(size: 20, weight: .medium))
                    }
                    
                    // Make header tappable in DMs to view profile
                    if channel.isDirectMessage {
                        Button(action: {
                            loadOtherUserProfile()
                        }) {
                            HStack(spacing: 8) {
                                // Show profile pic of other user
                                if let otherUserId = editableChannel.memberIds.first(where: { $0 != currentUserID }),
                                   let cachedProfile = userProfilesCache[otherUserId] {
                                    ProfilePicView(profile: cachedProfile, name: channel.displayName(forUserId: currentUserID), size: 32)
                                } else {
                                    ProfilePicView(profile: nil, name: channel.displayName(forUserId: currentUserID), size: 32)
                                }
                                
                                Text(editableChannel.displayName(forUserId: currentUserID))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        if canEditTitle && isEditingTitle {
                            TextField("Channel name", text: $editedTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .textFieldStyle(.plain)
                                .submitLabel(.done)
                                .disabled(isSavingTitle)
                                .onSubmit {
                                    saveEditedTitle()
                                }
                        } else if canEditTitle {
                            Button(action: {
                                editedTitle = editableChannel.name
                                isEditingTitle = true
                            }) {
                                Text(editableChannel.displayName(forUserId: currentUserID))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Text(editableChannel.displayName(forUserId: currentUserID))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                    }
                    
                    Spacer()
                    
                    // Edit button for group channels (not DMs)
                    if !channel.isDirectMessage {
                        if canEditTitle && isEditingTitle {
                            Button(action: {
                                saveEditedTitle()
                            }) {
                                if isSavingTitle {
                                    ProgressView()
                                        .tint(Color(hex: "5C3D2E"))
                                } else {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 18, weight: .medium))
                                }
                            }
                            .disabled(isSavingTitle)

                            Button(role: .cancel, action: {
                                isEditingTitle = false
                                editedTitle = editableChannel.name
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }

                        Button(action: {
                            showEditChannel = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                    
                    Menu {
                        if canBlockOrReport {
                            Button(role: .destructive, action: {
                                showBlockConfirmation = true
                            }) {
                                Label("Block User", systemImage: "person.crop.circle.badge.xmark")
                            }
                            
                            Button(role: .destructive, action: {
                                showReportConfirmation = true
                            }) {
                                Label("Report User/Content", systemImage: "flag")
                            }
                        }
                        
                        Button(role: .destructive, action: {
                            showEndChatConfirmation = true
                        }) {
                            Label("End Chat", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(hex: "8B9A7E").opacity(0.8))

                if channel.isDirectMessage && otherUserDeleted {
                    Text("This user has deleted their account. You can no longer send messages in this chat.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "E8E1D7"))
                }
                
                // Messages list
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else if messages.isEmpty {
                                VStack(spacing: 8) {
                                    Text("No messages yet")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                                    Text("Start the conversation!")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.4))
                                }
                                .padding(.top, 40)
                            } else {
                                ForEach(messages) { msg in
                                    let isCurrentUser = currentUserID != nil && msg.authorID == currentUserID
                                    let isGroupChannel = !channel.isDirectMessage
                                    
                                    // Check if message is read by others (for sent messages)
                                    let otherMemberIds = editableChannel.memberIds.filter { $0 != currentUserID }
                                    let isReadByOthers = !otherMemberIds.isEmpty && otherMemberIds.allSatisfy { msg.readBy.contains($0) }
                                    
                                    HStack(alignment: .top, spacing: 8) {
                                        // Profile pic for messages from others
                                        if !isCurrentUser {
                                            Button(action: {
                                                loadAndShowProfile(userId: msg.authorID)
                                            }) {
                                                ProfilePicView(
                                                    profile: userProfilesCache[msg.authorID],
                                                    name: msg.authorName,
                                                    size: 32
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        
                                        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                                            // Show sender name in group channels for messages from others
                                            if isGroupChannel && !isCurrentUser && !msg.authorName.isEmpty {
                                                Text(msg.authorName)
                                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                                    .padding(.horizontal, 4)
                                            }
                                            
                                            Text(msg.text)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 14)
                                                .background(isCurrentUser ? Color(hex: "D7C4B7") : Color(hex: "DDE3D0"))
                                                .foregroundColor(Color(hex: "000000"))
                                                .cornerRadius(14)
                                                .frame(maxWidth: 240, alignment: isCurrentUser ? .trailing : .leading)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                                                )
                                            
                                            // Time stamp and delivery status
                                            HStack(spacing: 4) {
                                                Text(msg.formattedTime)
                                                    .font(.system(size: 10, design: .rounded))
                                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.5))
                                                
                                                // Show delivery/read status for sent messages
                                                if isCurrentUser {
                                                    if isReadByOthers {
                                                        Text("Read")
                                                            .font(.system(size: 10, design: .rounded))
                                                            .foregroundColor(Color(hex: "8B9A7E"))
                                                    } else if msg.isDelivered {
                                                        Text("Delivered")
                                                            .font(.system(size: 10, design: .rounded))
                                                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.5))
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        
                                        // Spacer for alignment
                                        if !isCurrentUser {
                                            Spacer(minLength: 20)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 2)
                                    .id(msg.id)
                                }
                            }
                        }
                        .padding(.top, 10)
                        // ✅ Updated iOS 17+ syntax
                        .onChange(of: messages.count) {
                            if let last = messages.last {
                                withAnimation {
                                    scrollProxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            
        
                
                // Message input field
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("Type a message...", text: $newMessage, axis: .vertical)
                        .lineLimit(1...6)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(Color(hex: "000000"))
                        .disabled(channel.isDirectMessage && otherUserDeleted)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .font(.system(size: 20))
                    }
                    .disabled(channel.isDirectMessage && otherUserDeleted)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "F8F5EE").shadow(radius: 2))
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("User Unavailable", isPresented: $showOtherUserDeletedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This user has deleted their account.")
        }
        .alert("Couldn't Update Name", isPresented: $showTitleSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(titleSaveErrorMessage)
        }
        .confirmationDialog("Block User", isPresented: $showBlockConfirmation, titleVisibility: .visible) {
            Button("Block", role: .destructive) {
                Task { await blockUser() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Block \(channel.name)? You won't see their messages anymore.")
        }
        .confirmationDialog("Report User/Content", isPresented: $showReportConfirmation, titleVisibility: .visible) {
            Button("Report", role: .destructive) {
                reportUser()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Report this user or content for inappropriate behavior?")
        }
        .alert("Message Blocked", isPresented: $showFilterError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(filterErrorMessage)
        }
        .confirmationDialog("End Chat", isPresented: $showEndChatConfirmation, titleVisibility: .visible) {
            Button("End Chat", role: .destructive) {
                Task { await endChat() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Leave this conversation? You can start a new chat with this person later if you change your mind.")
        }
        .alert("Message Failed", isPresented: $showSendError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(sendErrorMessage)
        }
        .sheet(isPresented: $showUserProfile) {
            if let profile = selectedUserProfile {
                UserProfileSheetView(profile: profile)
                    .environmentObject(userDataManager)
            }
        }
        .sheet(isPresented: $showEditChannel) {
            EditChannelView(
                channel: editableChannel,
                isPresented: $showEditChannel,
                onSave: { updatedChannel in
                    editableChannel = updatedChannel
                    // Update channel in Firestore
                    Task {
                        do {
                            try await FirebaseService.shared.updateChannel(updatedChannel)
                        } catch {
                            print("Error updating channel: \(error.localizedDescription)")
                        }
                    }
                }
            )
            .environmentObject(userDataManager)
        }
        .onAppear {
            loadMessages()
            setupMessageListener()
            markMessagesAsRead()
            // Pre-load other user's profile for DM header
            if channel.isDirectMessage {
                Task {
                    await refreshDMState()
                }
            }
        }
        .onDisappear {
            messageListener?.remove()
            messageListener = nil
        }
    }
    
    private func loadMessages() {
        Task {
            do {
                let fetchedMessages = try await FirebaseService.shared.fetchMessages(channelID: channel.id)
                await MainActor.run {
                    messages = fetchedMessages
                    isLoading = false
                }
            } catch {
                print("❌ Error loading messages: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func setupMessageListener() {
        // Remove existing listener if any
        messageListener?.remove()
        
        // Set up real-time listener
        messageListener = FirebaseService.shared.listenToMessages(channelID: channel.id) { updatedMessages in
            Task { @MainActor in
                self.messages = updatedMessages
                self.isLoading = false
                // Keep read state up-to-date while viewing the chat
                self.markMessagesAsRead()
            }
        }
    }

    private func saveEditedTitle() {
        guard canEditTitle else { return }
        let trimmed = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSavingTitle = true
        Task {
            do {
                var updated = editableChannel
                updated.name = trimmed
                try await FirebaseService.shared.updateChannel(updated)
                await MainActor.run {
                    editableChannel = updated
                    isEditingTitle = false
                    isSavingTitle = false
                }
            } catch {
                await MainActor.run {
                    titleSaveErrorMessage = error.localizedDescription
                    showTitleSaveError = true
                    isSavingTitle = false
                }
            }
        }
    }

    private func sendMessage() {
        if channel.isDirectMessage && otherUserDeleted {
            sendErrorMessage = "This user has deleted their account. You can no longer send messages in this chat."
            showSendError = true
            return
        }
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespaces)
        guard !trimmedMessage.isEmpty else { return }

        guard let profileUserID = userDataManager.profile.userID else {
            print("❌ Cannot send message: no profile userID")
            sendErrorMessage = "Unable to send message. Please log in again."
            showSendError = true
            return
        }
        
        print("📤 Attempting to send message...")
        print("   Channel ID: \(channel.id)")
        print("   Profile UserID: \(profileUserID)")
        print("   Author Name: \(currentUserName)")

        // Filter content
        let filterResult = ContentFilterService.shared.filterContent(trimmedMessage)
        if !filterResult.isSafe {
            filterErrorMessage = filterResult.reason ?? "Your message contains inappropriate content"
            showFilterError = true
            return
        }

        let message = Message(
            channelID: channel.id,
            text: trimmedMessage,
            authorID: profileUserID,
            authorName: currentUserName,
            createdAt: Timestamp(),
            updatedAt: Timestamp()
        )

        newMessage = ""

        Task {
            do {
                let messageId = try await FirebaseService.shared.sendMessage(message)
                print("✅ Message sent successfully! ID: \(messageId)")
            } catch {
                print("❌ Message send failed: \(error)")
                await MainActor.run {
                    newMessage = trimmedMessage
                    sendErrorMessage = "Failed to send message: \(error.localizedDescription)"
                    showSendError = true
                }
            }
        }
    }

    private func blockUser() async {
        guard let currentUserID = userDataManager.profile.userID else { return }
        
        // For direct messages, we need to find the user ID from the channel name
        // The channel name should match the user's name (firstName + lastName)
        // We'll search for a user profile matching this name
        var userIDToBlock: String? = nil
        
        do {
            // Fetch all user profiles and find one matching the channel name
            let allProfiles = try await FirebaseService.shared.fetchAllUserProfiles(excludingUserID: currentUserID, limit: 100)
            
            // Try to find a user whose full name matches the channel name
            for profile in allProfiles {
                let fullName = "\(profile.firstName ?? "") \(profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
                if fullName == channel.name || profile.firstName == channel.name {
                    userIDToBlock = profile.userID
                    break
                }
            }
            
            // If we found the user, block them
            if let userID = userIDToBlock {
                try await FirebaseService.shared.blockUser(userID: currentUserID, userIDToBlock: userID)
                
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
                
                print("✅ Successfully blocked user: \(channel.name)")
            } else {
                print("⚠️ Could not find user with name: \(channel.name)")
                // Note: In a production app, you might want to show an alert to the user
            }
        } catch {
            print("Error blocking user: \(error)")
        }
    }
    
    private func reportUser() {
        let channelID = channel.id
        MailHelper.reportMessage(channelID: channelID, channelName: channel.name, userName: channel.name)
    }
    
    private func endChat() async {
        guard let userId = userDataManager.profile.userID else {
            print("❌ Cannot end chat: no profile userID")
            return
        }
        
        do {
            // Remove user from the channel
            try await Firestore.firestore().collection("channels").document(channel.id).updateData([
                "memberIds": FieldValue.arrayRemove([userId])
            ])
            
            // Remove channel from user's memberships
            try await Firestore.firestore().collection("users").document(userId).updateData([
                "channelMemberships": FieldValue.arrayRemove([channel.id])
            ])
            
            print("✅ Successfully left chat: \(channel.name)")
            
            // Dismiss the view
            await MainActor.run {
                dismiss()
            }
        } catch {
            print("❌ Error ending chat: \(error.localizedDescription)")
        }
    }
    
    private func markMessagesAsRead() {
        guard let userId = currentUserID else { return }
        
        Task {
            let db = Firestore.firestore()
            let messagesRef = db.collection("channels").document(channel.id).collection("messages")
            
            do {
                // Fetch recent messages, then mark any unread messages as read.
                // (Firestore has limitations around isNotEqualTo without specific ordering)
                let snapshot = try await messagesRef
                    .order(by: "createdAt", descending: true)
                    .limit(to: 100)
                    .getDocuments()

                for doc in snapshot.documents {
                    let data = doc.data()
                    let authorId = data["authorID"] as? String ?? ""
                    if authorId == userId { continue }

                    var readBy = data["readBy"] as? [String] ?? []
                    if readBy.contains(userId) { continue }

                    readBy.append(userId)
                    try await doc.reference.updateData(["readBy": readBy])
                }
            } catch {
                print("⚠️ Error marking messages as read: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadAndShowProfile(userId: String) {
        // Check cache first
        if let cachedProfile = userProfilesCache[userId] {
            selectedUserProfile = cachedProfile
            showUserProfile = true
            return
        }
        
        // Load from Firebase
        Task {
            do {
                let profile = try await FirebaseService.shared.getUserProfile(userID: userId)
                await MainActor.run {
                    if let profile = profile {
                        userProfilesCache[userId] = profile
                        selectedUserProfile = profile
                        showUserProfile = true
                        otherUserDeleted = false
                    } else {
                        if channel.isDirectMessage {
                            otherUserDeleted = true
                        }
                        showOtherUserDeletedAlert = true
                    }
                }
            } catch {
                print("⚠️ Error loading user profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadUserProfiles() {
        // Pre-load profiles for all message authors
        let authorIds = Set(messages.map { $0.authorID }).filter { $0 != currentUserID }
        
        for authorId in authorIds {
            if userProfilesCache[authorId] == nil {
                Task {
                    do {
                        let profile = try await FirebaseService.shared.getUserProfile(userID: authorId)
                        await MainActor.run {
                            if let profile = profile {
                                userProfilesCache[authorId] = profile
                            }
                        }
                    } catch {
                        print("⚠️ Error pre-loading profile for \(authorId): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func loadOtherUserProfile() {
        // For DM channels, find the other user and show their profile
        if otherUserDeleted {
            showOtherUserDeletedAlert = true
            return
        }
        guard let otherUserId = editableChannel.memberIds.first(where: { $0 != currentUserID }) else {
            otherUserDeleted = true
            showOtherUserDeletedAlert = true
            return
        }
        loadAndShowProfile(userId: otherUserId)
    }

    private func refreshDMState() async {
        do {
            let doc = try await Firestore.firestore().collection("channels").document(channel.id).getDocument()
            if let data = doc.data(), let memberIds = data["memberIds"] as? [String] {
                await MainActor.run {
                    editableChannel.memberIds = memberIds
                }
            }
        } catch {
            print("⚠️ Error refreshing DM channel state: \(error.localizedDescription)")
        }

        guard let currentUserID else { return }
        guard let otherUserId = editableChannel.memberIds.first(where: { $0 != currentUserID }) else {
            await MainActor.run {
                otherUserDeleted = true
            }
            return
        }

        do {
            let profile = try await FirebaseService.shared.getUserProfile(userID: otherUserId)
            await MainActor.run {
                if let profile {
                    userProfilesCache[otherUserId] = profile
                    otherUserDeleted = false
                } else {
                    otherUserDeleted = true
                }
            }
        } catch {
            print("⚠️ Error refreshing DM other user profile: \(error.localizedDescription)")
        }
    }
}

// MARK: - Profile Pic View
struct ProfilePicView: View {
    let profile: UserProfile?
    let name: String
    let size: CGFloat
    
    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        } else if let first = parts.first {
            return String(first.prefix(1)).uppercased()
        }
        return "?"
    }
    
    var body: some View {
        if let photoURL = profile?.photoURL, let url = URL(string: photoURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                case .failure:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        } else {
            placeholderView
        }
    }
    
    var placeholderView: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "8B9A7E"))
                .frame(width: size, height: size)
            Text(initials)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - User Profile Sheet View
struct UserProfileSheetView: View {
    let profile: UserProfile
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    
    @State private var showBlockConfirmation = false
    @State private var showMessageSent = false
    @State private var navigateToChat = false
    @State private var dmChannel: Channel? = nil
    
    var fullName: String {
        let first = profile.firstName ?? ""
        let last = profile.lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Profile Picture
                ProfilePicView(profile: profile, name: fullName, size: 80)
                    .padding(.top, 16)
                
                // Name
                Text(fullName.isEmpty ? "User" : fullName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "5C3D2E"))
                
                // Location
                if let town = profile.town, !town.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .foregroundColor(Color(hex: "8B9A7E"))
                            .font(.system(size: 12))
                        Text(town)
                            .foregroundColor(Color(hex: "5C3D2E"))
                    }
                    .font(.system(size: 14, design: .rounded))
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: startDirectMessage) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Message")
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "8B9A7E"))
                        .cornerRadius(10)
                    }
                    
                    Button(action: { showBlockConfirmation = true }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            Text("Block")
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "D4A5A5"))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // About section
                if let description = profile.shortDescription, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("About")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        Text(description)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                            .lineLimit(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                }
                
                // Info row with parenting stage and children
                HStack(spacing: 20) {
                    if let stage = profile.parentingStage, !stage.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Stage")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                            Text(stage)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                    }
                    
                    if let numChildren = profile.numberOfChildren, numChildren > 0 {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Children")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                            Text("\(numChildren)")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // Interests (compact)
                if let interests = profile.interests, !interests.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Interests")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Text(interests.prefix(5).joined(separator: " • "))
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.8))
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .background(Color(hex: "F8F5EE").ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                }
            }
            .confirmationDialog("Block User", isPresented: $showBlockConfirmation, titleVisibility: .visible) {
                Button("Block", role: .destructive) {
                    blockUser()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Block \(fullName)? You won't see their messages anymore.")
            }
            .alert("Message Sent", isPresented: $showMessageSent) {
                Button("OK") { dismiss() }
            } message: {
                Text("Chat started with \(fullName)")
            }
        }
    }
    
    private func startDirectMessage() {
        guard let currentUserId = userDataManager.profile.userID,
              let otherUserId = profile.userID else { return }
        
        let currentUserName = "\(userDataManager.profile.firstName ?? "") \(userDataManager.profile.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        let displayCurrentUserName = currentUserName.isEmpty ? "User" : currentUserName
        
        Task {
            do {
                _ = try await FirebaseService.shared.getOrCreateDirectMessageChannel(
                    currentUserId: currentUserId,
                    currentUserName: displayCurrentUserName,
                    otherUserId: otherUserId,
                    otherUserName: fullName
                )
                await MainActor.run {
                    showMessageSent = true
                }
            } catch {
                print("❌ Error creating DM: \(error.localizedDescription)")
            }
        }
    }
    
    private func blockUser() {
        guard let currentUserId = userDataManager.profile.userID,
              let otherUserId = profile.userID else { return }
        
        Task {
            do {
                try await FirebaseService.shared.blockUser(userID: currentUserId, userIDToBlock: otherUserId)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("❌ Error blocking user: \(error.localizedDescription)")
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
            Text(value)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(Color(hex: "5C3D2E"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    MessagesView(channel: Channel(
        id: "preview-channel",
        name: "Single moms",
        description: nil,
        imageURL: nil,
        isDirectMessage: false,
        memberIds: [],
        adminIds: [],
        createdAt: Date(),
        lastMessageAt: Date()
    ))
}

