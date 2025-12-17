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
    @State private var showFilterError = false
    @State private var filterErrorMessage = ""
    @State private var messages: [Message] = []
    @State private var messageListener: ListenerRegistration?
    @State private var isLoading = true
    
    private var canBlockOrReport: Bool {
        channel.isDirectMessage // Only allow block/report for direct messages
    }
    
    private var currentUserID: String? {
        userDataManager.authUserID
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
                    Text(channel.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    Spacer()
                    
                    if canBlockOrReport {
                        Menu {
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
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(hex: "8B9A7E").opacity(0.8))
                
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
                                    HStack(alignment: .bottom) {
                                        if isCurrentUser {
                                            Spacer(minLength: 40)
                                            Text(msg.text)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 14)
                                                .background(Color(hex: "D7C4B7")) // Sent: light brown
                                                .foregroundColor(Color(hex: "000000"))
                                                .cornerRadius(14)
                                                .frame(maxWidth: 260, alignment: .trailing)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                                                )
                                        } else {
                                            Text(msg.text)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 14)
                                                .background(Color(hex: "DDE3D0")) // Received: light green
                                                .foregroundColor(Color(hex: "000000"))
                                                .cornerRadius(14)
                                                .frame(maxWidth: 260, alignment: .leading)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
                                                )
                                            Spacer(minLength: 40)
                                        }
                                    }
                                    .padding(.horizontal, 20)
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
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $newMessage)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(Color(hex: "000000"))
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "F8F5EE").shadow(radius: 2))
            }
        }
        .navigationBarBackButtonHidden(true)
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
        .onAppear {
            loadMessages()
            setupMessageListener()
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
            }
        }
    }
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespaces)
        guard !trimmedMessage.isEmpty else { return }

        guard let authUID = userDataManager.authUserID else {
            print("❌ Cannot send message: not authenticated")
            return
        }

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
            authorID: authUID,
            authorName: currentUserName,
            createdAt: Timestamp(),
            updatedAt: Timestamp()
        )

        newMessage = ""

        Task {
            do {
                try await FirebaseService.shared.sendMessage(message)
                print("✅ Message sent as \(authUID)")
            } catch {
                print("❌ Message send failed:", error.localizedDescription)
                await MainActor.run {
                    newMessage = trimmedMessage
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

