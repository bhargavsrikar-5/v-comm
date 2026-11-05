package com.vcomm.app.dto;
import com.vcomm.app.model.GroupChat;
import java.time.LocalDateTime;
import java.util.List;
public record GroupResponse(Long id, String name, String description, Long ownerId, LocalDateTime createdAt,
                            String myRole, long unreadCount, String lastMessage, LocalDateTime lastMessageAt,
                            List<GroupMemberResponse> members) { }
