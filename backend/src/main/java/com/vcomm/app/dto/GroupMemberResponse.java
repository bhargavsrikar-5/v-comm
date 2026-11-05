package com.vcomm.app.dto;
import com.vcomm.app.model.GroupMembership;
import com.vcomm.app.model.User;
import java.time.LocalDateTime;
public record GroupMemberResponse(Long userId, String name, String email, String role, LocalDateTime joinedAt) {
    public static GroupMemberResponse from(GroupMembership membership, User user) {
        return new GroupMemberResponse(user.getId(), user.getName(), user.getEmail(), membership.getRole(), membership.getJoinedAt());
    }
}
