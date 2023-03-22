//
//  ConversationListView.swift
//  AICat
//
//  Created by Lei Pan on 2023/3/20.
//

import SwiftUI

struct ConversationListView: View {
    let selectedChat: Conversation?
    let conversations: [Conversation]
    let onAddChat: () -> Void
    let onChatChanged: (Conversation) -> Void

    @Environment(\.blackbirdDatabase) var db
    @State var showClearAllChatAlert = false
    @State var showSettingsView = false

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "timelapse")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)
                .padding(.top, 32)
            Spacer().frame(height: 32)
            HStack {
                Text("Chats")
                    .font(.custom("Avenir Next", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.4))
                Spacer()
            }.padding(.leading, 20)
            ScrollView {
                LazyVStack {
                    Spacer().frame(height: 10)
                    ForEach(conversations) { conversation in
                        Button(action: { onChatChanged(conversation) }) {
                            HStack {
                                Image(systemName: conversation == mainConversation ? "command" : "bubble.left" )
                                    .aspectRatio(contentMode: .fit)
                                Text(conversation.title)
                                    .font(.custom("Avenir Next", size: 16))
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                Spacer()
                                if selectedChat?.id == conversation.id {
                                    Circle()
                                        .frame(width: 10, height: 10)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.black.opacity(0.8), .black.opacity(0.5)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing)
                                        )
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                        }
                        .tint(.black)
                        .background(.white)
                        .contextMenu {
                            if conversation != mainConversation {
                                Button(role: .destructive, action: { deleteConversation(conversation) }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                    }
                    Button(action: onAddChat) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .aspectRatio(contentMode: .fit)
                            Text("New Chat")
                                .font(.custom("Avenir Next", size: 16))
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.white)
                    }
                    .padding(.horizontal, 20)
                    .tint(.gray)
                }
            }.scrollIndicators(.hidden)
            Spacer()
            Button(action: { showClearAllChatAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Clean Chats")
                        .font(.custom("Avenir Next", size: 16))
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.vertical, 10)
            }
            .tint(.gray)
            .padding(.horizontal, 20)
            .alert("Are you sure to clean all chats", isPresented: $showClearAllChatAlert) {
                Button("Sure", role: .destructive) {
                    clearAllConversation()
                }
                Button("Cancel", role: .cancel) {
                    showClearAllChatAlert = false
                }
            }
            Link(destination: URL(string: "https://help.openai.com/en/collections/3742473-chatgpt")!) {
                HStack {
                    Image(systemName: "questionmark.circle")
                    Text("Help")
                        .font(.custom("Avenir Next", size: 16))
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 20)
            .tint(.gray)
            Button(action: { showSettingsView = true }) {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                        .font(.custom("Avenir Next", size: 16))
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 20)
            .tint(.gray)
            Spacer().frame(height: 32)
        }
        .frame(width: 300)
        .fullScreenCover(isPresented: $showSettingsView) {
            SettingsView {
                showSettingsView = false
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    func deleteConversation(_ conversation: Conversation) {
        Task {
            var c = conversation
            c.timeRemoved = Date.now.timeInSecond
            await db?.upsert(model: c)
        }
    }

    func clearAllConversation() {
        Task {
            for var c in conversations {
                c.timeRemoved = Date.now.timeInSecond
                await db?.upsert(model: c)
            }
        }
    }
}

struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationListView(
            selectedChat: nil,
            conversations: [mainConversation, Conversation(title: "How to make a gift", prompt: "")],
            onAddChat: {}, onChatChanged: { _ in }
        )
    }
}
