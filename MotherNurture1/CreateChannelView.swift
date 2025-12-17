////
////  CreateChannelView.swift
////  MotherNurture1
////
////  Created by 40 GO Participant on 11/4/25.
////
//
//import SwiftUI
//
//struct CreateChannelView: View {
//    @Environment(\.dismiss) var dismiss
//    @Binding var isPresented: Bool
//    var onSave: ((String, String, String, String) -> Void)?
//    
//    @State private var channelName: String = ""
//    @State private var description: String = ""
//    @State private var category: String = "Parenting"
//    @State private var type: String = "Public channel"
//    @State private var showTypeDropdown: Bool = false
//    
//    let channelTypes = ["Public channel", "Private channel"]
//    
//    init(isPresented: Binding<Bool>, onSave: ((String, String, String, String) -> Void)? = nil) {
//        self._isPresented = isPresented
//        self.onSave = onSave
//    }
//    
//    var body: some View {
//        ZStack {
//            // Background color (beige to match other screens)
//            Color(hex: "F8F5EE")
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Top Navigation Bar
//                HStack {
//                    // Close button
//                    Button(action: {
//                        isPresented = false
//                        dismiss()
//                    }) {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 20, weight: .medium))
//                            .foregroundColor(Color(hex: "5C3D2E"))
//                            .frame(width: 44, height: 44)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    
//                    Spacer()
//                    
//                    // Title
//                    Text("Create a channel")
//                        .font(.system(size: 20, weight: .bold, design: .rounded))
//                        .foregroundColor(Color(hex: "5C3D2E"))
//                    
//                    Spacer()
//                    
//                    // Confirm button
//                    Button(action: {
//                        // Save channel and dismiss (only if name is not empty)
//                        if !channelName.trimmingCharacters(in: .whitespaces).isEmpty {
//                            onSave?(channelName, description, category, type)
//                        }
//                        isPresented = false
//                        dismiss()
//                    }) {
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 20, weight: .medium))
//                            .foregroundColor(Color(hex: "5C3D2E"))
//                            .frame(width: 44, height: 44)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 20)
//                .padding(.bottom, 30)
//                
//                ScrollView {
//                    VStack(spacing: 24) {
//                        // Channel Photo Section
//                        VStack(spacing: 12) {
//                            Button(action: {
//                                // Handle photo selection
//                            }) {
//                                ZStack {
//                                    Circle()
//                                        .fill(Color(hex: "8B9A7E")) // Olive green background
//                                        .frame(width: 100, height: 100)
//                                    
//                                    Image(systemName: "person")
//                                        .foregroundColor(Color(hex: "5C3D2E"))
//                                        .font(.system(size: 50))
//                                }
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            
//                            Text("Set new photo")
//                                .font(.system(size: 16, design: .rounded))
//                                .foregroundColor(Color(hex: "5C3D2E"))
//                        }
//                        .padding(.top, 20)
//                        
//                        // Form Fields
//                        VStack(alignment: .leading, spacing: 16) {
//                            // Name Field
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("Name")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                
//                                TextField("Single moms", text: $channelName)
//                                    .textFieldStyle(CreateChannelTextFieldStyle())
//                            }
//                            
//                            // Description Field
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("Description")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                
//                                TextField("Description", text: $description, axis: .vertical)
//                                    .textFieldStyle(CreateChannelTextFieldStyle())
//                                    .lineLimit(3...6)
//                            }
//                            
//                            // Category Field
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("Category")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                
//                                HStack {
//                                    TextField("Parenting", text: $category)
//                                        .padding()
//                                        .foregroundColor(Color(hex: "5C3D2E"))
//                                        .font(.system(size: 16, design: .rounded))
//                                    
//                                    Image(systemName: "chevron.down")
//                                        .foregroundColor(Color(hex: "5C3D2E"))
//                                        .font(.system(size: 14))
//                                        .padding(.trailing, 12)
//                                }
//                                .background(Color(hex: "8B9A7E"))
//                                .cornerRadius(8)
//                            }
//                            
//                            // Type Field
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text("Type")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                
//                                ZStack(alignment: .top) {
//                                    // Dropdown Button
//                                    Button(action: {
//                                        withAnimation {
//                                            showTypeDropdown.toggle()
//                                        }
//                                    }) {
//                                        HStack {
//                                            Text(type)
//                                                .foregroundColor(Color(hex: "5C3D2E"))
//                                                .font(.system(size: 16, design: .rounded))
//                                            
//                                            Spacer()
//                                            
//                                            Image(systemName: showTypeDropdown ? "chevron.up" : "chevron.down")
//                                                .foregroundColor(Color(hex: "5C3D2E"))
//                                                .font(.system(size: 14))
//                                        }
//                                        .padding()
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//                                    .background(Color(hex: "8B9A7E"))
//                                    .cornerRadius(8)
//                                    
//                                    // Dropdown Menu
//                                    if showTypeDropdown {
//                                        VStack(alignment: .leading, spacing: 0) {
//                                            ForEach(channelTypes, id: \.self) { channelType in
//                                                Button(action: {
//                                                    type = channelType
//                                                    withAnimation {
//                                                        showTypeDropdown = false
//                                                    }
//                                                }) {
//                                                    HStack {
//                                                        Text(channelType)
//                                                            .foregroundColor(Color(hex: "5C3D2E"))
//                                                            .font(.system(size: 16, design: .rounded))
//                                                        
//                                                        Spacer()
//                                                        
//                                                        if type == channelType {
//                                                            Image(systemName: "checkmark")
//                                                                .foregroundColor(Color(hex: "5C3D2E"))
//                                                                .font(.system(size: 14))
//                                                        }
//                                                    }
//                                                    .padding()
//                                                }
//                                                .buttonStyle(PlainButtonStyle())
//                                                
//                                                if channelType != channelTypes.last {
//                                                    Divider()
//                                                        .background(Color(hex: "5C3D2E").opacity(0.3))
//                                                }
//                                            }
//                                        }
//                                        .background(Color(hex: "8B9A7E"))
//                                        .cornerRadius(8)
//                                        .padding(.top, 50)
//                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 40)
//                    }
//                }
//            }
//        }
//        .toolbar(.hidden, for: .navigationBar)
//    }
//}
//
//// Custom TextField Style for Create Channel
//struct CreateChannelTextFieldStyle: TextFieldStyle {
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//            .padding()
//            .background(Color(hex: "8B9A7E")) // Olive green background
//            .cornerRadius(8)
//            .foregroundColor(Color(hex: "5C3D2E"))
//            .font(.system(size: 16, design: .rounded))
//    }
//}
//
//#Preview {
//    NavigationStack {
//        CreateChannelView(isPresented: .constant(true))
//    }
//}

//
//  CreateChannelView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct CreateChannelView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userDataManager: UserDataManager
    @Binding var isPresented: Bool
    var onSave: ((String, String, String, String, [String]) -> Void)?
    
    @State private var channelName: String = ""
    @State private var description: String = ""
    @State private var category: String = "Parenting"
    @State private var type: String = "Public channel"
    @State private var showTypeDropdown: Bool = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var showMemberPicker = false
    @State private var availableUsers: [UserProfile] = []
    @State private var selectedMemberIds: Set<String> = []
    @State private var isLoadingUsers = false
    
    let channelTypes = ["Public channel", "Private channel"]
    
    init(isPresented: Binding<Bool>, onSave: ((String, String, String, String, [String]) -> Void)? = nil) {
        self._isPresented = isPresented
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack {
            // Background color (beige to match other screens)
            Color(hex: "F8F5EE")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    // Close button
                    Button(action: {
                        isPresented = false
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Title
                    Text("Create a channel")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "5C3D2E"))
                    
                    Spacer()
                    
                    // Confirm button
                    Button(action: {
                        // Save channel and dismiss (only if name is not empty)
                        if !channelName.trimmingCharacters(in: .whitespaces).isEmpty {
                            onSave?(channelName, description, category, type, Array(selectedMemberIds))
                        }
                        isPresented = false
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Channel Photo Section
                        VStack(spacing: 12) {
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "8B9A7E")) // Olive green background
                                        .frame(width: 100, height: 100)
                                    
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person")
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                            .font(.system(size: 50))
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text("Set new photo")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 16) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                TextField("Single moms", text: $channelName)
                                    .textFieldStyle(CreateChannelTextFieldStyle())
                            }
                            
                            // Description Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                TextField("Description", text: $description, axis: .vertical)
                                    .textFieldStyle(CreateChannelTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                            
                            // Category Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                HStack {
                                    TextField("Parenting", text: $category)
                                        .padding()
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 16, design: .rounded))
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 14))
                                        .padding(.trailing, 12)
                                }
                                .background(Color(hex: "8B9A7E"))
                                .cornerRadius(8)
                            }
                            
                            // Type Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                ZStack(alignment: .top) {
                                    // Dropdown Button
                                    Button(action: {
                                        withAnimation {
                                            showTypeDropdown.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text(type)
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                .font(.system(size: 16, design: .rounded))
                                            
                                            Spacer()
                                            
                                            Image(systemName: showTypeDropdown ? "chevron.up" : "chevron.down")
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                .font(.system(size: 14))
                                        }
                                        .padding()
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .background(Color(hex: "8B9A7E"))
                                    .cornerRadius(8)
                                    
                                    // Dropdown Menu
                                    if showTypeDropdown {
                                        VStack(alignment: .leading, spacing: 0) {
                                            ForEach(channelTypes, id: \.self) { channelType in
                                                Button(action: {
                                                    type = channelType
                                                    withAnimation {
                                                        showTypeDropdown = false
                                                    }
                                                }) {
                                                    HStack {
                                                        Text(channelType)
                                                            .foregroundColor(Color(hex: "5C3D2E"))
                                                            .font(.system(size: 16, design: .rounded))
                                                        
                                                        Spacer()
                                                        
                                                        if type == channelType {
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                                .font(.system(size: 14))
                                                        }
                                                    }
                                                    .padding()
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                if channelType != channelTypes.last {
                                                    Divider()
                                                        .background(Color(hex: "5C3D2E").opacity(0.3))
                                                }
                                            }
                                        }
                                        .background(Color(hex: "8B9A7E"))
                                        .cornerRadius(8)
                                        .padding(.top, 50)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                }
                            }
                            
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
                                        Text(selectedMemberIds.isEmpty ? "Tap to add members" : "\(selectedMemberIds.count) member(s) selected")
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                            .font(.system(size: 16, design: .rounded))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                            .font(.system(size: 14))
                                    }
                                    .padding()
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(Color(hex: "8B9A7E"))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showMemberPicker) {
            MemberPickerView(
                availableUsers: $availableUsers,
                selectedMemberIds: $selectedMemberIds,
                isLoading: $isLoadingUsers,
                currentUserId: userDataManager.profile.userID
            )
        }
    }
    
    private func loadAvailableUsers() {
        guard !isLoadingUsers else { return }
        guard let currentUserId = userDataManager.profile.userID else { return }
        isLoadingUsers = true
        
        Task {
            do {
                // Only show users the current user has DM channels with (users they've chatted with)
                let users = try await FirebaseService.shared.getUsersFromDMChannels(currentUserId: currentUserId)
                await MainActor.run {
                    availableUsers = users
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
}

// MARK: - Member Picker View
struct MemberPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var availableUsers: [UserProfile]
    @Binding var selectedMemberIds: Set<String>
    @Binding var isLoading: Bool
    var currentUserId: String?
    
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
                            Text("No connections yet")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                            Text("You can only add users you've chatted with.\nStart a conversation first!")
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
                                    MemberRow(
                                        user: user,
                                        isSelected: selectedMemberIds.contains(userId),
                                        onToggle: {
                                            if selectedMemberIds.contains(userId) {
                                                selectedMemberIds.remove(userId)
                                            } else {
                                                selectedMemberIds.insert(userId)
                                            }
                                        }
                                    )
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

struct MemberRow: View {
    let user: UserProfile
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Circle()
                    .fill(Color(hex: "8B9A7E"))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String((user.firstName?.first ?? "U").uppercased()))
                            .foregroundColor(Color(hex: "5C3D2E"))
                            .font(.system(size: 16, weight: .medium))
                    )
                
                VStack(alignment: .leading) {
                    Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                        .foregroundColor(Color(hex: "5C3D2E"))
                        .font(.system(size: 16, design: .rounded))
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color(hex: "8B9A7E") : Color(hex: "5C3D2E").opacity(0.3))
                    .font(.system(size: 24))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom TextField Style for Create Channel
struct CreateChannelTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "8B9A7E")) // Olive green background
            .cornerRadius(8)
            .foregroundColor(Color(hex: "5C3D2E"))
            .font(.system(size: 16, design: .rounded))
    }
}

#Preview {
    NavigationStack {
        CreateChannelView(isPresented: .constant(true))
    }
}
