//
//  CreateChannelView.swift
//  MotherNurture1
//
//  Created by 40 GO Participant on 11/4/25.
//

import SwiftUI

struct CreateChannelView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    var onSave: ((String, String, String, String) -> Void)?
    
    @State private var channelName: String = ""
    @State private var description: String = ""
    @State private var category: String = "Parenting"
    @State private var type: String = "Public channel"
    @State private var showTypeDropdown: Bool = false
    
    let channelTypes = ["Public channel", "Private channel"]
    
    init(isPresented: Binding<Bool>, onSave: ((String, String, String, String) -> Void)? = nil) {
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
                            onSave?(channelName, description, category, type)
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
                                // Handle photo selection
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "8B9A7E")) // Olive green background
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "person")
                                        .foregroundColor(Color(hex: "5C3D2E"))
                                        .font(.system(size: 50))
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
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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
