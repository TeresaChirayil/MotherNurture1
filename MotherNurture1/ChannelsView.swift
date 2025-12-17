import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ChannelsView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @StateObject private var viewModel = ChannelsViewModel()
    @State private var searchText: String = ""
    @State private var showCreateChannel = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isEditingChannel = false
    @State private var channelToEdit: Channel?
    @State private var showMembers = false
    @State private var selectedChannelForMembers: Channel?
    @State private var showUnreadBanner = false
    @State private var lastTotalUnread = 0
    
    private var filteredChannels: [Channel] {
        if searchText.isEmpty {
            return viewModel.channels
        } else {
            return viewModel.channels.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .bottomTrailing) {
                    // Background
                    Color(hex: "F8F5EE")
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        if showUnreadBanner && viewModel.totalUnread > 0 {
                            HStack(spacing: 10) {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.white)
                                Text("\(viewModel.totalUnread) New Message\(viewModel.totalUnread == 1 ? "" : "s")")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(hex: "8B9A7E"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 6)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .padding(.leading, 12)
                            
                            TextField("Search channels", text: $searchText)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.vertical, 8)
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(hex: "5C3D2E").opacity(0.5))
                                }
                                .padding(.trailing, 8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(Color(hex: "E8E1D7"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        
                        // Channel List
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                            Spacer()
                        } else if filteredChannels.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 48))
                                    .foregroundColor(Color(hex: "8B9A7E"))
                                
                                Text("No channels yet")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                Text("Create a new channel to start chatting")
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(filteredChannels) { channel in
                                        ChannelRow(
                                            channel: channel,
                                            currentUserId: userDataManager.profile.userID ?? "",
                                            unreadCount: viewModel.unreadCounts[channel.id] ?? 0,
                                            onLeave: { leaveChannel(channel) },
                                            onEdit: { editChannel(channel) },
                                            onShowMembers: { showChannelMembers(channel) }
                                        )
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                leaveChannel(channel)
                                            } label: {
                                                Label("Leave", systemImage: "person.fill.xmark")
                                            }

                                            if channel.isAdmin(userId: userDataManager.profile.userID ?? "") {
                                                Button {
                                                    editChannel(channel)
                                                } label: {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                                .padding(.bottom, geo.safeAreaInsets.bottom + 120)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .refreshable {
                                await viewModel.fetchChannels()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    // Add Channel Button
                    Button(action: { showCreateChannel = true }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color(hex: "8B9A7E"))
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 24)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .navigationTitle("Channels")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCreateChannel) {
                CreateChannelView(isPresented: $showCreateChannel, onSave: { name, description, category, type, selectedMemberIds in
                    let newChannel = Channel(
                        id: UUID().uuidString,
                        name: name,
                        description: description,
                        imageURL: nil,
                        isDirectMessage: false,
                        memberIds: [],
                        adminIds: [],
                        createdAt: Date(),
                        lastMessageAt: Date()
                    )
                    Task {
                        if let userId = userDataManager.profile.userID {
                            // Create the channel first
                            if let createdChannel = await viewModel.createChannel(newChannel, userId: userId) {
                                // Then add the selected members
                                if !selectedMemberIds.isEmpty {
                                    do {
                                        try await FirebaseService.shared.addMembersToChannel(
                                            channelId: createdChannel.id,
                                            memberIds: selectedMemberIds
                                        )
                                        print("✅ Added \(selectedMemberIds.count) members to channel")
                                    } catch {
                                        print("❌ Error adding members: \(error)")
                                    }
                                }
                            }
                        }
                    }
                })
                .environmentObject(userDataManager)
            }
            .sheet(item: $channelToEdit, onDismiss: {
                isEditingChannel = false
            }) { channel in
                EditChannelView(
                    channel: channel,
                    isPresented: $isEditingChannel,
                    onSave: { updatedChannel in
                        Task {
                            await viewModel.updateChannel(updatedChannel)
                        }
                    }
                )
                .environmentObject(userDataManager)
            }
            .sheet(isPresented: $showMembers) {
                if let channel = selectedChannelForMembers {
                    ChannelMembersView(channel: channel)
                }
            }
            .navigationDestination(for: Channel.self) { channel in
                MessagesView(channel: channel)
                    .environmentObject(userDataManager)
            }
            .onAppear {
                viewModel.setUserID(userDataManager.profile.userID)
            }
            .onChange(of: userDataManager.profile.userID) { _, newUserID in
                viewModel.setUserID(newUserID)
            }
            .onAppear {
                lastTotalUnread = viewModel.totalUnread
            }
            .onChange(of: viewModel.totalUnread) { _, newTotal in
                // Only pop the banner when unread increases
                if newTotal > lastTotalUnread {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showUnreadBanner = true
                    }
                    Task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showUnreadBanner = false
                            }
                        }
                    }
                }
                lastTotalUnread = newTotal
            }
        }
    }
    
    private func leaveChannel(_ channel: Channel) {
        guard let userId = userDataManager.profile.userID else { return }
        Task {
            await viewModel.leaveChannel(channelId: channel.id, userId: userId)
        }
    }
    
    private func editChannel(_ channel: Channel) {
        channelToEdit = channel
    }
    
    private func showChannelMembers(_ channel: Channel) {
        selectedChannelForMembers = channel
        showMembers = true
    }
}

// MARK: - Channel Row View
struct ChannelRow: View {
    let channel: Channel
    let currentUserId: String
    let unreadCount: Int
    let onLeave: () -> Void
    let onEdit: () -> Void
    let onShowMembers: () -> Void
    
    var isAdmin: Bool {
        channel.adminIds.contains(currentUserId)
    }
    
    var body: some View {
        NavigationLink(value: channel) {
            HStack(spacing: 12) {
                // Channel Image
                if let imageUrl = channel.imageURL, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Circle()
                                    .fill(Color(hex: channel.isDirectMessage ? "9BA897" : "8B9A7E").opacity(0.2))
                                    .frame(width: 50, height: 50)
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "8B9A7E"), lineWidth: 1))
                        case .failure:
                            ZStack {
                                Circle()
                                    .fill(Color(hex: channel.isDirectMessage ? "9BA897" : "8B9A7E"))
                                    .frame(width: 50, height: 50)
                                Image(systemName: channel.isDirectMessage ? "person.2.fill" : "bubble.left.and.bubble.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(hex: channel.isDirectMessage ? "9BA897" : "8B9A7E"))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: channel.isDirectMessage ? "person.2.fill" : "bubble.left.and.bubble.right")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        if isAdmin && !channel.isDirectMessage {
                            Button(action: onEdit) {
                                Text(channel.displayName(forUserId: currentUserId))
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .lineLimit(1)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        } else {
                            Text(channel.displayName(forUserId: currentUserId))
                                .font(.headline)
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .lineLimit(1)
                        }
                        
                        if isAdmin && !channel.isDirectMessage {
                            Text("Admin")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "8B9A7E"))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    
                    if let description = channel.description, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 8) {
                        Text("\(channel.memberIds.count) members")
                            .font(.caption)
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                        
                        if channel.isDirectMessage {
                            Text("Direct Message")
                                .font(.caption)
                                .foregroundColor(Color(hex: "8B9A7E"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "8B9A7E").opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if !channel.timeAgo.isEmpty {
                        Text(channel.timeAgo)
                            .font(.caption2)
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                    }

                    if unreadCount > 0 {
                        Text(unreadCount > 99 ? "99+" : "\(unreadCount)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, unreadCount > 9 ? 8 : 7)
                            .padding(.vertical, 4)
                            .background(Color(hex: "8B9A7E"))
                            .clipShape(Capsule())
                    }
                    
                    Button(action: onShowMembers) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(Color(hex: "8B9A7E"))
                            .font(.system(size: 14))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EditChannelView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    let channel: Channel
    @Binding var isPresented: Bool
    let onSave: (Channel) -> Void

    @State private var channelName: String
    @State private var channelDescription: String
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showMemberPicker = false
    @State private var availableUsers: [UserProfile] = []
    @State private var selectedMemberIds: Set<String> = []
    @State private var isLoadingUsers = false
    @State private var isSaving = false
    @State private var currentMembers: [UserProfile] = []
    @State private var isLoadingMembers = false
    @State private var memberToRemove: UserProfile?
    @State private var showRemoveMemberConfirm = false
    @State private var showRemoveMemberError = false
    @State private var removeMemberErrorMessage = ""

    init(channel: Channel, isPresented: Binding<Bool>, onSave: @escaping (Channel) -> Void) {
        self.channel = channel
        self._isPresented = isPresented
        self.onSave = onSave
        self._channelName = State(initialValue: channel.name)
        self._channelDescription = State(initialValue: channel.description ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Channel Photo Section
                        VStack(spacing: 12) {
                            Text("Channel Photo")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "9BA897"))
                                        .frame(width: 100, height: 100)
                                    
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else if let imageURL = channel.imageURL, let url = URL(string: imageURL) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Image(systemName: "photo")
                                                .foregroundColor(.white)
                                                .font(.system(size: 30))
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                    } else {
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    }
                                    
                                    // Edit overlay
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "pencil")
                                                .foregroundColor(.white)
                                                .font(.system(size: 20))
                                        )
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Channel Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Channel Name")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            TextField("Channel name", text: $channelName)
                                .padding()
                                .background(Color(hex: "E8E1D7"))
                                .cornerRadius(10)
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                        .padding(.horizontal, 20)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            TextField("Description (optional)", text: $channelDescription)
                                .padding()
                                .background(Color(hex: "E8E1D7"))
                                .cornerRadius(10)
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                        .padding(.horizontal, 20)
                        
                        // Current Members Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Members (\(channel.memberIds.count))")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            if isLoadingMembers {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .padding()
                            } else if currentMembers.isEmpty {
                                Text("No members found")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                                    .padding()
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(currentMembers, id: \.userID) { member in
                                        HStack(spacing: 12) {
                                            if let photoURL = member.photoURL, let url = URL(string: photoURL) {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                } placeholder: {
                                                    Circle()
                                                        .fill(Color(hex: "D4C4B0"))
                                                        .overlay(
                                                            Text(member.firstName?.prefix(1) ?? "?")
                                                                .font(.system(size: 14, weight: .medium))
                                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                        )
                                                }
                                                .frame(width: 36, height: 36)
                                                .clipShape(Circle())
                                            } else {
                                                Circle()
                                                    .fill(Color(hex: "D4C4B0"))
                                                    .frame(width: 36, height: 36)
                                                    .overlay(
                                                        Text(member.firstName?.prefix(1) ?? "?")
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(Color(hex: "5C3D2E"))
                                                    )
                                            }

                                            Text("\(member.firstName ?? "") \(member.lastName ?? "")")
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))

                                            Spacer()

                                            if channel.isAdmin(userId: userDataManager.profile.userID ?? ""),
                                               member.userID != userDataManager.profile.userID {
                                                Button(role: .destructive) {
                                                    memberToRemove = member
                                                    showRemoveMemberConfirm = true
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(Color.red.opacity(0.8))
                                                        .font(.system(size: 18))
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            } else if member.userID == userDataManager.profile.userID {
                                                Text("You")
                                                    .font(.system(size: 12, design: .rounded))
                                                    .foregroundColor(Color(hex: "8B9A7E"))
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color(hex: "8B9A7E").opacity(0.2))
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "E8E1D7"))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Add Members Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add Members")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            
                            Button(action: {
                                showMemberPicker = true
                                loadAvailableUsers()
                            }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                    Text(selectedMemberIds.isEmpty ? "Tap to add members" : "\(selectedMemberIds.count) new member(s) to add")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 14))
                                }
                                .padding()
                                .background(Color(hex: "E8E1D7"))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Edit Channel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "8B9A7E"))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSaving {
                        ProgressView()
                            .tint(Color(hex: "8B9A7E"))
                    } else {
                        Button("Save") {
                            saveChannel()
                        }
                        .foregroundColor(Color(hex: "8B9A7E"))
                        .disabled(channelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showMemberPicker) {
                EditChannelMemberPickerView(
                    availableUsers: $availableUsers,
                    selectedMemberIds: $selectedMemberIds,
                    isLoading: $isLoadingUsers,
                    existingMemberIds: channel.memberIds
                )
            }
            .onAppear {
                loadCurrentMembers()
            }
            .alert("Remove Member", isPresented: $showRemoveMemberConfirm) {
                Button("Cancel", role: .cancel) { memberToRemove = nil }
                Button("Remove", role: .destructive) {
                    removeSelectedMember()
                }
            } message: {
                Text("Are you sure you want to remove this member from the channel?")
            }
            .alert("Cannot Remove", isPresented: $showRemoveMemberError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(removeMemberErrorMessage)
            }
        }
    }

    private func removeSelectedMember() {
        guard let memberId = memberToRemove?.userID else { return }
        guard channel.memberIds.count > 1 else {
            removeMemberErrorMessage = "This channel must have at least one member."
            showRemoveMemberError = true
            memberToRemove = nil
            return
        }

        isSaving = true
        Task {
            do {
                try await FirebaseService.shared.removeMemberFromChannel(channelId: channel.id, memberId: memberId)
                await MainActor.run {
                    memberToRemove = nil
                    showRemoveMemberConfirm = false
                    isSaving = false
                }
                loadCurrentMembers()
            } catch {
                print("Error removing member: \(error)")
                await MainActor.run {
                    removeMemberErrorMessage = error.localizedDescription
                    showRemoveMemberError = true
                    isSaving = false
                }
            }
        }
    }
    
    private func loadCurrentMembers() {
        isLoadingMembers = true
        
        Task {
            var memberIds: [String] = channel.memberIds
            if let doc = try? await Firestore.firestore().collection("channels").document(channel.id).getDocument(),
               let data = doc.data(),
               let ids = data["memberIds"] as? [String] {
                memberIds = ids
            }

            var members: [UserProfile] = []
            for memberId in memberIds {
                if let profile = try? await FirebaseService.shared.getUserProfile(userID: memberId) {
                    members.append(profile)
                }
            }
            await MainActor.run {
                currentMembers = members
                isLoadingMembers = false
            }
        }
    }
    
    private func loadAvailableUsers() {
        guard !isLoadingUsers else { return }
        guard let currentUserId = userDataManager.profile.userID else { return }
        isLoadingUsers = true
        
        Task {
            do {
                // Only show users the current user has DM channels with
                let users = try await FirebaseService.shared.getUsersFromDMChannels(currentUserId: currentUserId)
                // Filter out users already in the channel
                let filteredUsers = users.filter { user in
                    guard let userId = user.userID else { return false }
                    return !channel.memberIds.contains(userId)
                }
                await MainActor.run {
                    availableUsers = filteredUsers
                    isLoadingUsers = false
                }
            } catch {
                print("Error loading users: \(error)")
                await MainActor.run {
                    isLoadingUsers = false
                }
            }
        }
    }
    
    private func saveChannel() {
        isSaving = true
        
        Task {
            do {
                var updated = channel
                updated.name = channelName
                updated.description = channelDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : channelDescription
                
                // Upload image if selected
                if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                    let fileName = "channel_\(channel.id).jpg"
                    let storageRef = Storage.storage().reference().child("channel_photos/\(fileName)")
                    _ = try await storageRef.putDataAsync(imageData, metadata: nil)
                    let downloadURL = try await storageRef.downloadURL()
                    updated.imageURL = downloadURL.absoluteString
                }
                
                // Add new members if selected
                if !selectedMemberIds.isEmpty {
                    try await FirebaseService.shared.addMembersToChannel(
                        channelId: channel.id,
                        memberIds: Array(selectedMemberIds)
                    )
                }
                
                await MainActor.run {
                    onSave(updated)
                    isSaving = false
                    isPresented = false
                    dismiss()
                }
            } catch {
                print("Error saving channel: \(error)")
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
}

// MARK: - Edit Channel Member Picker View
struct EditChannelMemberPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var availableUsers: [UserProfile]
    @Binding var selectedMemberIds: Set<String>
    @Binding var isLoading: Bool
    let existingMemberIds: [String]
    
    @State private var searchText = ""
    
    var filteredUsers: [UserProfile] {
        if searchText.isEmpty {
            return availableUsers
        }
        return availableUsers.filter { user in
            let fullName = "\(user.firstName ?? "") \(user.lastName ?? "")".lowercased()
            return fullName.contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F5EE").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "5C3D2E"))
                        TextField("Search users", text: $searchText)
                            .foregroundColor(Color(hex: "5C3D2E"))
                    }
                    .padding(10)
                    .background(Color(hex: "E8E1D7"))
                    .cornerRadius(10)
                    .padding()
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if filteredUsers.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.4))
                            Text("No users to add")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            Text("All your connections are already members,\nor start a conversation first!")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredUsers, id: \.userID) { user in
                                if let userId = user.userID {
                                    Button(action: {
                                        if selectedMemberIds.contains(userId) {
                                            selectedMemberIds.remove(userId)
                                        } else {
                                            selectedMemberIds.insert(userId)
                                        }
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(Color(hex: "D4C4B0"))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Text("\(user.firstName?.prefix(1) ?? "")")
                                                        .font(.headline)
                                                        .foregroundColor(Color(hex: "5C3D2E"))
                                                )
                                            
                                            Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                            
                                            Spacer()
                                            
                                            Image(systemName: selectedMemberIds.contains(userId) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedMemberIds.contains(userId) ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E").opacity(0.3))
                                                .font(.system(size: 22))
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Add Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "5C3D2E"))
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Channel Members View
struct ChannelMembersView: View {
    let channel: Channel
    @State private var members: [UserProfile] = []
    @State private var isLoading = true
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else if let error = error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "D4A5A5"))
                        
                        Text("Error loading members")
                            .font(.headline)
                            .foregroundColor(Color(hex: "5C3D2E"))
                        
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        Section(header: Text("Members")) {
                            ForEach(Array(zip(members.indices, members)), id: \.0) { index, member in
                                HStack(spacing: 12) {
                                    if let photoURL = member.photoURL, let url = URL(string: photoURL) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ZStack {
                                                    Circle()
                                                        .fill(Color(hex: "D4C4B0").opacity(0.3))
                                                        .frame(width: 40, height: 40)
                                                    ProgressView()
                                                }
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                            case .failure:
                                                Circle()
                                                    .fill(Color(hex: "D4C4B0"))
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Text(member.firstName?.prefix(1) ?? "?")
                                                            .font(.headline)
                                                            .foregroundColor(Color(hex: "5C3D2E"))
                                                    )
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        Circle()
                                            .fill(Color(hex: "D4C4B0"))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(member.firstName?.prefix(1) ?? "?")
                                                    .font(.headline)
                                                    .foregroundColor(Color(hex: "5C3D2E"))
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(member.firstName ?? "") \(member.lastName ?? "")")
                                            .font(.subheadline)
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                        
                                        if channel.adminIds.contains(member.userID ?? "") {
                                            Text("Admin")
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color(hex: "8B9A7E"))
                                                .foregroundColor(.white)
                                                .cornerRadius(4)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(Color(hex: "F8F5EE"))
                }
            }
            .navigationTitle("Channel Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss the sheet
                        NotificationCenter.default.post(name: NSNotification.Name("DismissChannelMembers"), object: nil)
                    }
                    .foregroundColor(Color(hex: "8B9A7E"))
                }
            }
            .onAppear {
                loadMembers()
            }
        }
    }
    
    private func loadMembers() {
        isLoading = true
        ChannelsManager.shared.fetchChannelMembers(channelId: channel.id) { result in
            switch result {
            case .success(let members):
                self.members = members.sorted { $0.firstName ?? "" < $1.firstName ?? "" }
            case .failure(let error):
                self.error = error
                print("Error fetching channel members: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}

// MARK: - Preview
struct ChannelsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ChannelsViewModel()
        viewModel.channels = [
            Channel(
                id: "1",
                name: "General",
                description: "General discussion for everyone",
                imageURL: nil,
                isDirectMessage: false,
                memberIds: ["user1", "user2", "user3"],
                adminIds: ["user1"],
                createdAt: Date(),
                lastMessageAt: Date()
            ),
            Channel(
                id: "2",
                name: "Announcements",
                description: "Important updates and announcements",
                imageURL: "https://example.com/channel.jpg",
                isDirectMessage: false,
                memberIds: ["user1", "user2", "user3", "user4"],
                adminIds: ["user1", "user2"],
                createdAt: Date().addingTimeInterval(-3600),
                lastMessageAt: Date().addingTimeInterval(-3600)
            )
        ]
        
        return NavigationView {
            ChannelsView()
                .environmentObject(UserDataManager.shared)
        }
    }
}

#Preview {
    ChannelsView()
        .environmentObject(UserDataManager.shared)
}

