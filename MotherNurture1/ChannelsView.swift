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
                            List {
                                ForEach(filteredChannels) { channel in
                                    ChannelRow(
                                        channel: channel,
                                        currentUserId: userDataManager.authUserID ?? "",
                                        onLeave: { leaveChannel(channel) },
                                        onEdit: { editChannel(channel) },
                                        onShowMembers: { showChannelMembers(channel) }
                                    )
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            leaveChannel(channel)
                                        } label: {
                                            Label("Leave", systemImage: "person.fill.xmark")
                                        }
                                        .tint(Color(hex: "D4A5A5"))
                                        
                                        if channel.isAdmin(userId: userDataManager.authUserID ?? "") {
                                            Button {
                                                editChannel(channel)
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(Color(hex: "8B9A7E"))
                                        }
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                            .refreshable {
                                await viewModel.fetchChannels()
                            }
                        }
                    }
                    
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showCreateChannel = true }) {
                            Label("Create Channel", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Color(hex: "5C3D2E"))
                    }
                }
            }
            .sheet(isPresented: $showCreateChannel) {
                CreateChannelView(isPresented: $showCreateChannel, onSave: { name, description, category, type in
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
                        await viewModel.createChannel(newChannel)
                    }
                })
            }
            .sheet(isPresented: $isEditingChannel, onDismiss: {
                channelToEdit = nil
            }) {
                if let channel = channelToEdit {
                    EditChannelView(
                        channel: channel,
                        isPresented: $isEditingChannel,
                        onSave: { updatedChannel in
                            Task {
                                await viewModel.updateChannel(updatedChannel)
                            }
                        }
                    )
                }
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
        }
    }
    
    private func leaveChannel(_ channel: Channel) {
        guard let userId = userDataManager.authUserID else { return }
        Task {
            await viewModel.leaveChannel(channelId: channel.id, userId: userId)
        }
    }
    
    private func editChannel(_ channel: Channel) {
        channelToEdit = channel
        isEditingChannel = true
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
                        Text(channel.name)
                            .font(.headline)
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .lineLimit(1)
                        
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
    let channel: Channel
    @Binding var isPresented: Bool
    let onSave: (Channel) -> Void

    @State private var channelName: String
    @State private var channelDescription: String

    init(channel: Channel, isPresented: Binding<Bool>, onSave: @escaping (Channel) -> Void) {
        self.channel = channel
        self._isPresented = isPresented
        self.onSave = onSave
        self._channelName = State(initialValue: channel.name)
        self._channelDescription = State(initialValue: channel.description ?? "")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Channel name", text: $channelName)
                        TextField("Description", text: $channelDescription)
                    }
                }
                .scrollContentBackground(.hidden)
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
                    Button("Save") {
                        var updated = channel
                        updated.name = channelName
                        updated.description = channelDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : channelDescription
                        onSave(updated)
                        isPresented = false
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "8B9A7E"))
                    .disabled(channelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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

