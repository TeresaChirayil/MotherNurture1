//
//  ProfileView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var isEditing = false
    @State private var editedBio: String = ""
    @State private var editedParentTags: Set<String> = []
    @State private var editedInterests: Set<String> = []
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var isSaving = false
    @State private var isLoading = false
    @State private var showLogoutAlert = false
    @State private var showDeleteProfileAlert = false
    @State private var isDeleting = false
    @State private var showDatePicker = false
    @State private var editedDateOfBirth: Date = Date()
    @State private var originalPhotoURL: String? = nil
    
    let parentTags = [
        "First-time Parent",
        "Single parent",
        "Stay-at-home",
        "Working part-time",
        "Working full-time",
        "Parent of disabled child(ren)"
    ]
    
    let interests = [
        "Reading",
        "Cooking",
        "Arts & Crafts",
        "Traveling",
        "Exercising",
        "Gardening",
        "Anything!"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(hex: "F8F5EE")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Top Navigation - Sign Out and Menu
                        HStack {
                            // Sign Out Button
                            Button(action: { showLogoutAlert = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                }
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                            }
                            .alert("Are you sure you want to sign out?", isPresented: $showLogoutAlert) {
                                Button("Cancel", role: .cancel) { }
                                Button("Sign Out", role: .destructive) {
                                    signOut()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            Spacer()

                            // Menu Button (Edit and Delete Account)
                            Menu {
                                Button(action: {
                                    if isEditing {
                                        saveProfile()
                                    } else {
                                        startEditing()
                                    }
                                }) {
                                    Label(isEditing ? "Save" : "Edit", systemImage: isEditing ? "checkmark" : "pencil")
                                }
                                .disabled(isSaving)
                                
                                Divider()
                                
                                Button(role: .destructive, action: {
                                    showDeleteProfileAlert = true
                                }) {
                                    Label("Delete Account", systemImage: "trash")
                                }
                            } label: {
                                if isSaving {
                                    ProgressView()
                                        .tint(Color(hex: "5C3D2E"))
                                } else {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.system(size: 24, weight: .regular))
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isSaving)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        // Profile Picture
                        ZStack {
                            Circle()
                                .fill(Color(hex: "9BA897"))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                            
                            // Show selected image, then photoURL, then placeholder
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else if let photoURL = userDataManager.profile.photoURL, !photoURL.isEmpty {
                                AsyncImage(url: URL(string: photoURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "mountain.2.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 50))
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "mountain.2.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 50))
                            }
                            
                            if isEditing {
                                Button(action: {
                                    showingImagePicker = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "8B9A7E").opacity(0.8))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .offset(x: 40, y: 40)
                            }
                        }
                        .padding(.bottom, 16)
                        
                        // Name and Age
                        if let firstName = userDataManager.profile.firstName,
                           let lastName = userDataManager.profile.lastName {
                            let fullName = "\(firstName) \(lastName)"
                            let age = calculateAge()
                            
                            VStack(spacing: 8) {
                                Text(fullName)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                
                                if isEditing {
                                    VStack(spacing: 8) {
                                        HStack(spacing: 8) {
                                            Text("Date of Birth:")
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                showDatePicker.toggle()
                                            }) {
                                                Text(dateFormatter.string(from: editedDateOfBirth))
                                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                                    .foregroundColor(Color(hex: "8B9A7E"))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color(hex: "D4C4B0"))
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        if showDatePicker {
                                            DatePicker(
                                                "Date of Birth",
                                                selection: $editedDateOfBirth,
                                                displayedComponents: .date
                                            )
                                            .datePickerStyle(.compact)
                                            .accentColor(Color(hex: "5C3D2E"))
                                            .padding(.horizontal, 20)
                                        }
                                        
                                        if let calculatedAge = calculateAge(from: editedDateOfBirth) {
                                            Text("Age: \(calculatedAge)")
                                                .font(.system(size: 14, design: .rounded))
                                                .foregroundColor(Color(hex: "8B9A7E"))
                                                .padding(.horizontal, 20)
                                        }
                                    }
                                } else {
                                    if let age = age {
                                        Text("Age: \(age)")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(Color(hex: "8B9A7E"))
                                    }
                                }
                            }
                            .padding(.bottom, 24)
                        }
                        
                        // Bio Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio....")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
                                .padding(.horizontal, 20)
                            
                            if isEditing {
                                TextField("Tell us about yourself", text: $editedBio, axis: .vertical)
                                    .textFieldStyle(ProfileTextFieldStyle())
                                    .lineLimit(5...10)
                                    .padding(.horizontal, 20)
                            } else {
                                Text(userDataManager.profile.shortDescription ?? "")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(hex: "5C3D2E"))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(minHeight: 100)
                                    .background(Color(hex: "D4C4B0"))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 16)
                        
                        // Tags Section (under bio)
                        if let parentTags = userDataManager.profile.parentTags, !parentTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(parentTags), id: \.self) { tag in
                                        Text("#\(tag.replacingOccurrences(of: " ", with: ""))")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(hex: "9BA897"))
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 24)
                        }
                        
                        // ABOUT ME Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ABOUT ME")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .padding(.horizontal, 20)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                if isEditing {
                                    // Editable parent tags
                                    FlowLayout(spacing: 8) {
                                        ForEach(parentTags, id: \.self) { tag in
                                            Button(action: {
                                                if editedParentTags.contains(tag) {
                                                    editedParentTags.remove(tag)
                                                } else {
                                                    editedParentTags.insert(tag)
                                                }
                                            }) {
                                                Text(tag)
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(editedParentTags.contains(tag) ? .white : Color(hex: "5C3D2E"))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(editedParentTags.contains(tag) ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                                    .cornerRadius(20)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // Add more button (placeholder)
                                    Button(action: {
                                        // Handle add more
                                    }) {
                                        HStack {
                                            Image(systemName: "plus")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                            
                                            Text("Add more")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "D4C4B0"))
                                        .cornerRadius(20)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal, 20)
                                } else {
                                    // Display parent tags
                                    if let tags = userDataManager.profile.parentTags, !tags.isEmpty {
                                        FlowLayout(spacing: 8) {
                                            ForEach(tags, id: \.self) { tag in
                                                Text(tag)
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(Color(hex: "5C3D2E"))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(Color(hex: "9BA897"))
                                                    .cornerRadius(20)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(hex: "D4C4B0"))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 24)
                        
                        // Interests Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Interests")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
                                .padding(.horizontal, 20)
                            
                            if isEditing {
                                // Editable interests
                                FlowLayout(spacing: 8) {
                                    ForEach(interests, id: \.self) { interest in
                                        Button(action: {
                                            if editedInterests.contains(interest) {
                                                editedInterests.remove(interest)
                                            } else {
                                                editedInterests.insert(interest)
                                            }
                                        }) {
                                            Text(interest)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(editedInterests.contains(interest) ? .white : Color(hex: "5C3D2E"))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(editedInterests.contains(interest) ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
                                                .cornerRadius(20)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Add more button (placeholder)
                                Button(action: {
                                    // Handle add more
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                        
                                        Text("Add more")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(hex: "5C3D2E"))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "D4C4B0"))
                                    .cornerRadius(20)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                            } else {
                                // Display interests
                                if let userInterests = userDataManager.profile.interests, !userInterests.isEmpty {
                                    FlowLayout(spacing: 8) {
                                        ForEach(userInterests, id: \.self) { interest in
                                            Text(interest)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(hex: "5C3D2E"))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color(hex: "9BA897"))
                                                .cornerRadius(20)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
                .overlay(alignment: .bottom) {
                    BottomNavBar(currentTab: .constant(.profile))
                        .padding(.bottom, 5)
                }
                .toolbar(.hidden, for: .navigationBar)
                .alert("Delete Account", isPresented: $showDeleteProfileAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deleteProfile()
                    }
                } message: {
                    Text("Are you sure you want to delete your account? This action cannot be undone. All your data, including your profile, posts, and comments, will be permanently deleted.")
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                .task {
                    // Load profile from Firebase when view appears
                    await loadProfileIfNeeded()
                }
                .refreshable {
                    // Allow pull-to-refresh to reload profile
                    await loadProfileIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Private Functions
    private func loadProfileIfNeeded() async {
        // Load profile if we have a userID or email
        guard userDataManager.profile.userID != nil || (userDataManager.profile.email != nil && !userDataManager.profile.email!.isEmpty) else {
            return
        }
        
        isLoading = true
        do {
            if let userID = userDataManager.profile.userID {
                try await userDataManager.loadProfileFromFirebase(userID: userID)
            } else if let email = userDataManager.profile.email, !email.isEmpty {
                try await userDataManager.loadProfileFromFirebase(email: email)
            }
        } catch {
            print("Error loading profile: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Sign Out
    private func signOut() {
        do {
            try Auth.auth().signOut()
            userDataManager.clearProfile()

            // Trigger redirect — tell the app the user is now logged out
            userDataManager.isAuthenticated = false

            print("Signed out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func calculateAge() -> Int? {
        guard let dateOfBirth = userDataManager.profile.dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year
    }
    
    private func startEditing() {
        if !isEditing {
            editedBio = userDataManager.profile.shortDescription ?? ""
            editedParentTags = Set(userDataManager.profile.parentTags ?? [])
            editedInterests = Set(userDataManager.profile.interests ?? [])
            editedDateOfBirth = userDataManager.profile.dateOfBirth ?? Date()
            originalPhotoURL = userDataManager.profile.photoURL // Preserve original photoURL
            selectedImage = nil // Clear any previously selected image
        }
        isEditing = true
    }
    
    private func saveProfile() {
        isSaving = true
        
        // Update profile with edited values
        userDataManager.profile.shortDescription = editedBio.isEmpty ? nil : editedBio
        userDataManager.profile.parentTags = Array(editedParentTags)
        userDataManager.profile.interests = Array(editedInterests)
        userDataManager.profile.dateOfBirth = editedDateOfBirth
        
        // Handle profile picture: preserve existing photoURL if no new image selected
        // If a new image was selected, save it (for now as placeholder URL)
        // In production, you'd upload to Firebase Storage and get a URL
        if let _ = selectedImage {
            // Only update photoURL if a new image was selected
            // This preserves the existing photoURL if user didn't change the image
            let newPhotoURL = "selected_image_\(UUID().uuidString)"
            userDataManager.profile.photoURL = newPhotoURL
            print("🔥 [ProfileView] New image selected, saving to profile")
        } else {
            // If no new image selected, preserve the original photoURL
            userDataManager.profile.photoURL = originalPhotoURL
        }
        
        // Save to Firebase
        Task {
            do {
                try await userDataManager.saveToFirebase()
                await MainActor.run {
                    // Clear selectedImage after successful save so photoURL persists
                    selectedImage = nil
                    isSaving = false
                    isEditing = false
                }
            } catch {
                print("Error saving profile: \(error)")
                await MainActor.run {
                    isSaving = false
                    // Still exit edit mode even if save fails
                    isEditing = false
                }
            }
        }
    }
    
    private func deleteProfile() {
        guard userDataManager.profile.userID != nil else {
            print("❌ Cannot delete profile: No userID")
            return
        }
        
        isDeleting = true
        Task {
            do {
                // Delete account using UserDataManager method
                try await userDataManager.deleteAccount()
                
                // Account deletion will automatically sign out and reset
                await MainActor.run {
                    isDeleting = false
                    print("✅ Account deleted successfully")
                }
            } catch {
                print("❌ Error deleting account: \(error.localizedDescription)")
                await MainActor.run {
                    isDeleting = false
                    // Show error alert to user
                    showDeleteProfileAlert = false
                    // You could add an error alert here if needed
                }
            }
        }
    }
    
    private func calculateAge(from date: Date) -> Int? {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }

    // Flow Layout for wrapping tags
    struct FlowLayout: Layout {
        var spacing: CGFloat = 8
        
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let result = FlowResult(
                in: proposal.width ?? 0,
                subviews: subviews,
                spacing: spacing
            )
            return result.size
        }
        
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            let result = FlowResult(
                in: bounds.width,
                subviews: subviews,
                spacing: spacing
            )
            for (index, subview) in subviews.enumerated() {
                subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                          y: bounds.minY + result.frames[index].minY),
                              proposal: .unspecified)
            }
        }
        
        struct FlowResult {
            var size: CGSize = .zero
            var frames: [CGRect] = []
            
            init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
                var currentX: CGFloat = 0
                var currentY: CGFloat = 0
                var lineHeight: CGFloat = 0
                
                for subview in subviews {
                    let size = subview.sizeThatFits(.unspecified)
                    
                    if currentX + size.width > maxWidth && currentX > 0 {
                        currentX = 0
                        currentY += lineHeight + spacing
                        lineHeight = 0
                    }
                    
                    frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                    lineHeight = max(lineHeight, size.height)
                    currentX += size.width + spacing
                }
                
                self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
            }
        }
    }
    
    // Custom TextField Style for Profile
    struct ProfileTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding()
                .frame(minHeight: 100)
                .background(Color(hex: "D4C4B0"))
                .cornerRadius(12)
                .foregroundColor(Color(hex: "5C3D2E"))
                .font(.system(size: 16, design: .rounded))
        }
    }
}

// MARK: - Preview
#Preview {
    // Prefer a lightweight, non-shared instance for preview to avoid cycles
    // If UserDataManager had a public init, we would use it. Since it's a singleton,
    // we can still use shared but keep data simple and avoid triggering Firebase work.
    let previewManager = UserDataManager.shared
    var profile = UserProfile()
    profile.firstName = "Alex"
    profile.lastName = "Doe"
    profile.email = "preview@example.com"
    profile.dateOfBirth = Calendar.current.date(byAdding: .year, value: -30, to: Date())
    profile.shortDescription = "Loves hiking, cooking, and meeting new parents."
    profile.parentTags = ["First-time Parent", "Working full-time"]
    profile.interests = ["Reading", "Cooking"]
    previewManager.profile = profile
    
    return ProfileView()
        .environmentObject(previewManager)
}
