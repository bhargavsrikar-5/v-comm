package com.vcomm.app.dto;

import com.vcomm.app.model.User;
import java.time.LocalDateTime;

public class ConversationResponse {
    private UserResponse otherUser;
    private String lastMessage;
    private LocalDateTime lastMessageTime;
    private long unreadCount;

    public ConversationResponse() { }
    public ConversationResponse(User otherUser, String lastMessage, LocalDateTime lastMessageTime, long unreadCount) {
        this.otherUser = UserResponse.from(otherUser);
        this.lastMessage = lastMessage;
        this.lastMessageTime = lastMessageTime;
        this.unreadCount = unreadCount;
    }
    public UserResponse getOtherUser() { return otherUser; }
    public String getLastMessage() { return lastMessage; }
    public LocalDateTime getLastMessageTime() { return lastMessageTime; }
    public long getUnreadCount() { return unreadCount; }
}
