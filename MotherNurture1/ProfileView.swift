////
////  ProfileView.swift
////  MotherNurture1
////
////  Created by 40 GO Participant on 11/4/25.
////
//
//import SwiftUI
//
//struct ProfileView: View {
//    @EnvironmentObject var userDataManager: UserDataManager
//    @State private var isEditing = false
//    @State private var editedBio: String = ""
//    @State private var editedParentTags: Set<String> = []
//    @State private var editedInterests: Set<String> = []
//    @State private var showingImagePicker = false
//    @State private var isSaving = false
//    @State private var isLoading = false
//    
//    let parentTags = [
//        "First-time Parent",
//        "Single parent",
//        "Stay-at-home",
//        "Working part-time",
//        "Working full-time",
//        "Parent of disabled child(ren)"
//    ]
//    
//    let interests = [
//        "Reading",
//        "Cooking",
//        "Arts & Crafts",
//        "Traveling",
//        "Exercising",
//        "Gardening",
//        "Anything!"
//    ]
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Background color
//                Color(hex: "F8F5EE")
//                    .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 0) {
//                        // Top Navigation - Edit Button
//                        HStack {
//                            Spacer()
//                            
//                            Button(action: {
//                                if isEditing {
//                                    saveProfile()
//                                } else {
//                                    startEditing()
//                                }
//                            }) {
//                                if isSaving {
//                                    ProgressView()
//                                        .tint(Color(hex: "5C3D2E"))
//                                } else {
//                                    Text(isEditing ? "Save" : "Edit")
//                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
//                                        .foregroundColor(Color(hex: "5C3D2E"))
//                                        .padding(.horizontal, 16)
//                                        .padding(.vertical, 8)
//                                        .background(Color(hex: "D4C4B0"))
//                                        .cornerRadius(8)
//                                }
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            .disabled(isSaving)
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.top, 20)
//                        .padding(.bottom, 20)
//                        
//                        // Profile Picture
//                        ZStack {
//                            Circle()
//                                .fill(Color(hex: "9BA897"))
//                                .frame(width: 120, height: 120)
//                                .overlay(
//                                    Circle()
//                                        .stroke(Color.white, lineWidth: 3)
//                                )
//                            
//                            if let photoURL = userDataManager.profile.photoURL, !photoURL.isEmpty {
//                                AsyncImage(url: URL(string: photoURL)) { image in
//                                    image
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                } placeholder: {
//                                    Image(systemName: "mountain.2.fill")
//                                        .foregroundColor(.white)
//                                        .font(.system(size: 50))
//                                }
//                                .frame(width: 120, height: 120)
//                                .clipShape(Circle())
//                            } else {
//                                Image(systemName: "mountain.2.fill")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 50))
//                            }
//                            
//                            if isEditing {
//                                Button(action: {
//                                    showingImagePicker = true
//                                }) {
//                                    ZStack {
//                                        Circle()
//                                            .fill(Color(hex: "8B9A7E").opacity(0.8))
//                                            .frame(width: 40, height: 40)
//                                        
//                                        Image(systemName: "camera.fill")
//                                            .foregroundColor(.white)
//                                            .font(.system(size: 18))
//                                    }
//                                }
//                                .offset(x: 40, y: 40)
//                            }
//                        }
//                        .padding(.bottom, 16)
//                        
//                        // Name and Age
//                        if let firstName = userDataManager.profile.firstName,
//                           let lastName = userDataManager.profile.lastName {
//                            let fullName = "\(firstName) \(lastName)"
//                            let age = calculateAge()
//                            Text("\(fullName)\(age != nil ? ", \(age!)" : "")")
//                                .font(.system(size: 24, weight: .bold, design: .rounded))
//                                .foregroundColor(Color(hex: "5C3D2E"))
//                                .padding(.bottom, 24)
//                        }
//                        
//                        // Bio Section
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Bio....")
//                                .font(.system(size: 14, weight: .medium, design: .rounded))
//                                .foregroundColor(Color(hex: "5C3D2E").opacity(0.7))
//                                .padding(.horizontal, 20)
//                            
//                            if isEditing {
//                                TextField("Tell us about yourself", text: $editedBio, axis: .vertical)
//                                    .textFieldStyle(ProfileTextFieldStyle())
//                                    .lineLimit(5...10)
//                                    .padding(.horizontal, 20)
//                            } else {
//                                Text(userDataManager.profile.shortDescription ?? "")
//                                    .font(.system(size: 16, design: .rounded))
//                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                    .padding()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .frame(minHeight: 100)
//                                    .background(Color(hex: "D4C4B0"))
//                                    .cornerRadius(12)
//                                    .padding(.horizontal, 20)
//                            }
//                        }
//                        .padding(.bottom, 16)
//                        
//                        // Tags Section (under bio)
//                        if let parentTags = userDataManager.profile.parentTags, !parentTags.isEmpty {
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack(spacing: 8) {
//                                    ForEach(Array(parentTags), id: \.self) { tag in
//                                        Text("#\(tag.replacingOccurrences(of: " ", with: ""))")
//                                            .font(.system(size: 14, weight: .medium, design: .rounded))
//                                            .foregroundColor(Color(hex: "5C3D2E"))
//                                            .padding(.horizontal, 12)
//                                            .padding(.vertical, 8)
//                                            .background(Color(hex: "9BA897"))
//                                            .cornerRadius(20)
//                                    }
//                                }
//                                .padding(.horizontal, 20)
//                            }
//                            .padding(.bottom, 24)
//                        }
//                        
//                        // ABOUT ME Section
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("ABOUT ME")
//                                .font(.system(size: 16, weight: .bold, design: .rounded))
//                                .foregroundColor(Color(hex: "5C3D2E"))
//                                .padding(.horizontal, 20)
//                            
//                            VStack(alignment: .leading, spacing: 12) {
//                                if isEditing {
//                                    // Editable parent tags
//                                    FlowLayout(spacing: 8) {
//                                        ForEach(parentTags, id: \.self) { tag in
//                                            Button(action: {
//                                                if editedParentTags.contains(tag) {
//                                                    editedParentTags.remove(tag)
//                                                } else {
//                                                    editedParentTags.insert(tag)
//                                                }
//                                            }) {
//                                                Text(tag)
//                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
//                                                    .foregroundColor(editedParentTags.contains(tag) ? .white : Color(hex: "5C3D2E"))
//                                                    .padding(.horizontal, 12)
//                                                    .padding(.vertical, 8)
//                                                    .background(editedParentTags.contains(tag) ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
//                                                    .cornerRadius(20)
//                                            }
//                                            .buttonStyle(PlainButtonStyle())
//                                        }
//                                    }
//                                    .padding(.horizontal, 20)
//                                    
//                                    // Add more button (placeholder)
//                                    Button(action: {
//                                        // Handle add more
//                                    }) {
//                                        HStack {
//                                            Image(systemName: "plus")
//                                                .font(.system(size: 14, weight: .medium))
//                                                .foregroundColor(Color(hex: "5C3D2E"))
//                                            
//                                            Text("Add more")
//                                                .font(.system(size: 14, weight: .medium, design: .rounded))
//                                                .foregroundColor(Color(hex: "5C3D2E"))
//                                        }
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 8)
//                                        .background(Color(hex: "D4C4B0"))
//                                        .cornerRadius(20)
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//                                    .padding(.horizontal, 20)
//                                } else {
//                                    // Display parent tags
//                                    if let tags = userDataManager.profile.parentTags, !tags.isEmpty {
//                                        FlowLayout(spacing: 8) {
//                                            ForEach(tags, id: \.self) { tag in
//                                                Text(tag)
//                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
//                                                    .foregroundColor(Color(hex: "5C3D2E"))
//                                                    .padding(.horizontal, 12)
//                                                    .padding(.vertical, 8)
//                                                    .background(Color(hex: "9BA897"))
//                                                    .cornerRadius(20)
//                                            }
//                                        }
//                                        .padding(.horizontal, 20)
//                                    }
//                                }
//                            }
//                            .padding()
//                            .background(Color(hex: "D4C4B0"))
//                            .cornerRadius(12)
//                            .padding(.horizontal, 20)
//                        }
//                        .padding(.bottom, 24)
//                        
//                        // Interests Section
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Interests")
//                                .font(.system(size: 16, weight: .bold, design: .rounded))
//                                .foregroundColor(Color(hex: "5C3D2E"))
//                                .padding(.horizontal, 20)
//                            
//                            if isEditing {
//                                // Editable interests
//                                FlowLayout(spacing: 8) {
//                                    ForEach(interests, id: \.self) { interest in
//                                        Button(action: {
//                                            if editedInterests.contains(interest) {
//                                                editedInterests.remove(interest)
//                                            } else {
//                                                editedInterests.insert(interest)
//                                            }
//                                        }) {
//                                            Text(interest)
//                                                .font(.system(size: 14, weight: .medium, design: .rounded))
//                                                .foregroundColor(editedInterests.contains(interest) ? .white : Color(hex: "5C3D2E"))
//                                                .padding(.horizontal, 12)
//                                                .padding(.vertical, 8)
//                                                .background(editedInterests.contains(interest) ? Color(hex: "8B9A7E") : Color(hex: "D4C4B0"))
//                                                .cornerRadius(20)
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                    }
//                                }
//                                .padding(.horizontal, 20)
//                                
//                                // Add more button (placeholder)
//                                Button(action: {
//                                    // Handle add more
//                                }) {
//                                    HStack {
//                                        Image(systemName: "plus")
//                                            .font(.system(size: 14, weight: .medium))
//                                            .foregroundColor(Color(hex: "5C3D2E"))
//                                        
//                                        Text("Add more")
//                                            .font(.system(size: 14, weight: .medium, design: .rounded))
//                                            .foregroundColor(Color(hex: "5C3D2E"))
//                                    }
//                                    .padding(.horizontal, 12)
//                                    .padding(.vertical, 8)
//                                    .background(Color(hex: "D4C4B0"))
//                                    .cornerRadius(20)
//                                }
//                                .buttonStyle(PlainButtonStyle())
//                                .padding(.horizontal, 20)
//                            } else {
//                                // Display interests
//                                if let userInterests = userDataManager.profile.interests, !userInterests.isEmpty {
//                                    FlowLayout(spacing: 8) {
//                                        ForEach(userInterests, id: \.self) { interest in
//                                            Text(interest)
//                                                .font(.system(size: 14, weight: .medium, design: .rounded))
//                                                .foregroundColor(Color(hex: "5C3D2E"))
//                                                .padding(.horizontal, 12)
//                                                .padding(.vertical, 8)
//                                                .background(Color(hex: "9BA897"))
//                                                .cornerRadius(20)
//                                        }
//                                    }
//                                    .padding(.horizontal, 20)
//                                }
//                            }
//                        }
//                        .padding(.bottom, 100)
//                    }
//                }
//                .overlay(alignment: .bottom) {
//                    BottomNavBar(currentTab: .constant(.profile))
//                        .padding(.bottom, 5)
//                }
//            }
//            .toolbar(.hidden, for: .navigationBar)
//            .sheet(isPresented: $showingImagePicker) {
//                // Image picker would go here
//                Text("Image Picker Placeholder")
//            }
//            .task {
//                // Load profile from Firebase when view appears
//                await loadProfileIfNeeded()
//            }
//            .refreshable {
//                // Allow pull-to-refresh to reload profile
//                await loadProfileIfNeeded()
//            }
//        }
//    }
//    
//    private func loadProfileIfNeeded() async {
//        // Load profile if we have a userID or email
//        guard userDataManager.profile.userID != nil || (userDataManager.profile.email != nil && !userDataManager.profile.email!.isEmpty) else {
//            return
//        }
//        
//        isLoading = true
//        do {
//            if let userID = userDataManager.profile.userID {
//                try await userDataManager.loadProfileFromFirebase(userID: userID)
//            } else if let email = userDataManager.profile.email, !email.isEmpty {
//                try await userDataManager.loadProfileFromFirebase(email: email)
//            }
//        } catch {
//            print("Error loading profile: \(error)")
//        }
//        isLoading = false
//    }
//    
//    private func calculateAge() -> Int? {
//        guard let dateOfBirth = userDataManager.profile.dateOfBirth else { return nil }
//        let calendar = Calendar.current
//        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
//        return ageComponents.year
//    }
//    
//    private func startEditing() {
//        if !isEditing {
//            editedBio = userDataManager.profile.shortDescription ?? ""
//            editedParentTags = Set(userDataManager.profile.parentTags ?? [])
//            editedInterests = Set(userDataManager.profile.interests ?? [])
//        }
//        isEditing = true
//    }
//    
//    private func saveProfile() {
//        isSaving = true
//        
//        // Update profile with edited values
//        userDataManager.profile.shortDescription = editedBio.isEmpty ? nil : editedBio
//        userDataManager.profile.parentTags = Array(editedParentTags)
//        userDataManager.profile.interests = Array(editedInterests)
//        
//        // Save to Firebase
//        Task {
//            do {
//                try await userDataManager.saveToFirebase()
//                isSaving = false
//                isEditing = false
//            } catch {
//                print("Error saving profile: \(error)")
//                isSaving = false
//                // Still exit edit mode even if save fails
//                isEditing = false
//            }
//        }
//    }
//}
//
//// Flow Layout for wrapping tags
//struct FlowLayout: Layout {
//    var spacing: CGFloat = 8
//    
//    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        let result = FlowResult(
//            in: proposal.width ?? 0,
//            subviews: subviews,
//            spacing: spacing
//        )
//        return result.size
//    }
//    
//    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
//        let result = FlowResult(
//            in: bounds.width,
//            subviews: subviews,
//            spacing: spacing
//        )
//        for (index, subview) in subviews.enumerated() {
//            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
//                                     y: bounds.minY + result.frames[index].minY),
//                         proposal: .unspecified)
//        }
//    }
//    
//    struct FlowResult {
//        var size: CGSize = .zero
//        var frames: [CGRect] = []
//        
//        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
//            var currentX: CGFloat = 0
//            var currentY: CGFloat = 0
//            var lineHeight: CGFloat = 0
//            
//            for subview in subviews {
//                let size = subview.sizeThatFits(.unspecified)
//                
//                if currentX + size.width > maxWidth && currentX > 0 {
//                    currentX = 0
//                    currentY += lineHeight + spacing
//                    lineHeight = 0
//                }
//                
//                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
//                lineHeight = max(lineHeight, size.height)
//                currentX += size.width + spacing
//            }
//            
//            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
//        }
//    }
//}
//
//// Custom TextField Style for Profile
//struct ProfileTextFieldStyle: TextFieldStyle {
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//            .padding()
//            .frame(minHeight: 100)
//            .background(Color(hex: "D4C4B0"))
//            .cornerRadius(12)
//            .foregroundColor(Color(hex: "5C3D2E"))
//            .font(.system(size: 16, design: .rounded))
//    }
//}
//
//#Preview {
//    ProfileView()
//        .environmentObject(UserDataManager.shared)
//}
//
//


//
//  ProfileView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

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
                        // Top Navigation - Edit Button
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                if isEditing {
                                    saveProfile()
                                } else {
                                    startEditing()
                                }
                            }) {
                                if isSaving {
                                    ProgressView()
                                        .tint(Color(hex: "5C3D2E"))
                                } else {
                                    Text(isEditing ? "Save" : "Edit")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "D4C4B0"))
                                        .cornerRadius(8)
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
                            Text("\(fullName)\(age != nil ? ", \(age!)" : "")")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "5C3D2E"))
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
            }
            .toolbar(.hidden, for: .navigationBar)
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
        }
        isEditing = true
    }
    
    private func saveProfile() {
        isSaving = true
        
        // Update profile with edited values
        userDataManager.profile.shortDescription = editedBio.isEmpty ? nil : editedBio
        userDataManager.profile.parentTags = Array(editedParentTags)
        userDataManager.profile.interests = Array(editedInterests)
        
        // If an image was selected, save it (for now as placeholder URL)
        // In production, you'd upload to Firebase Storage and get a URL
        if let _ = selectedImage {
            userDataManager.profile.photoURL = "selected_image_\(UUID().uuidString)"
            print("🔥 [ProfileView] Selected image will be saved to profile")
        }
        
        // Save to Firebase
        Task {
            do {
                try await userDataManager.saveToFirebase()
                isSaving = false
                isEditing = false
            } catch {
                print("Error saving profile: \(error)")
                isSaving = false
                // Still exit edit mode even if save fails
                isEditing = false
            }
        }
    }
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

#Preview {
    ProfileView()
        .environmentObject(UserDataManager.shared)
}

