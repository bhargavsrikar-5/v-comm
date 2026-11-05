package com.vcomm.app.service;

import com.vcomm.app.dto.*;
import com.vcomm.app.model.*;
import com.vcomm.app.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class GroupService {
    private final GroupChatRepository groups;
    private final GroupMembershipRepository memberships;
    private final GroupMessageRepository messages;
    private final UserRepository users;
    public GroupService(GroupChatRepository groups, GroupMembershipRepository memberships,
                        GroupMessageRepository messages, UserRepository users) {
        this.groups=groups; this.memberships=memberships; this.messages=messages; this.users=users;
    }

    @Transactional
    public GroupResponse create(Long creatorId, GroupCreateRequest request) {
        GroupChat group = groups.save(new GroupChat(request.getName(), request.getDescription(), creatorId));
        memberships.save(new GroupMembership(group.getId(), creatorId, "ADMIN"));
        return response(group, creatorId);
    }

    @Transactional(readOnly = true)
    public List<GroupResponse> list(Long userId, boolean platformAdmin) {
        List<GroupChat> visible = platformAdmin ? groups.findAll() : memberships.findByUserIdOrderByJoinedAtDesc(userId).stream()
                .map(m -> groups.findById(m.getGroupId()).orElse(null)).filter(Objects::nonNull).toList();
        return visible.stream().map(group -> response(group, userId)).toList();
    }

    @Transactional(readOnly = true)
    public GroupResponse get(Long groupId, Long userId, boolean platformAdmin) {
        requireMember(groupId, userId, platformAdmin);
        return response(group(groupId), userId);
    }

    @Transactional
    public GroupMemberResponse addMember(Long groupId, Long actorId, boolean platformAdmin, Long targetUserId) {
        GroupChat group = group(groupId);
        requireGroupAdmin(group, actorId, platformAdmin);
        User target = users.findById(targetUserId).orElseThrow(() -> new IllegalArgumentException("Faculty account was not found."));
        if (memberships.existsByGroupIdAndUserId(groupId, targetUserId)) throw new IllegalArgumentException("This faculty member is already in the group.");
        GroupMembership member = memberships.save(new GroupMembership(groupId, targetUserId, "MEMBER"));
        return GroupMemberResponse.from(member, target);
    }

    @Transactional
    public void removeMember(Long groupId, Long actorId, boolean platformAdmin, Long targetUserId) {
        GroupChat group = group(groupId);
        requireGroupAdmin(group, actorId, platformAdmin);
        if (Objects.equals(group.getOwnerId(), targetUserId)) throw new IllegalArgumentException("The group owner cannot be removed. Transfer ownership before leaving.");
        GroupMembership member = memberships.findByGroupIdAndUserId(groupId, targetUserId)
                .orElseThrow(() -> new IllegalArgumentException("Group member was not found."));
        memberships.delete(member);
    }

    @Transactional
    public GroupMessage send(Long groupId, Long senderId, String content) {
        requireMember(groupId, senderId, false);
        if (content == null || content.isBlank() || content.length() > 4000) throw new IllegalArgumentException("Message must contain 1 to 4000 characters.");
        return messages.save(new GroupMessage(groupId, senderId, content.trim()));
    }

    @Transactional
    public List<GroupMessage> history(Long groupId, Long userId, boolean platformAdmin) {
        requireMember(groupId, userId, platformAdmin);
        GroupMembership membership = memberships.findByGroupIdAndUserId(groupId, userId).orElse(null);
        if (membership != null) {
            membership.setLastReadAt(LocalDateTime.now());
            memberships.save(membership);
        }
        List<GroupMessage> result = new ArrayList<>(messages.findTop100ByGroupIdOrderBySentAtDesc(groupId));
        Collections.reverse(result);
        return result;
    }

    private GroupResponse response(GroupChat group, Long userId) {
        GroupMembership mine = memberships.findByGroupIdAndUserId(group.getId(), userId).orElse(null);
        List<GroupMemberResponse> members = memberships.findByGroupIdOrderByJoinedAtAsc(group.getId()).stream()
                .map(m -> users.findById(m.getUserId()).map(user -> GroupMemberResponse.from(m, user)).orElse(null))
                .filter(Objects::nonNull).toList();
        GroupMessage latest = messages.findTop100ByGroupIdOrderBySentAtDesc(group.getId()).stream().findFirst().orElse(null);
        long unread = 0;
        if (mine != null) unread = mine.getLastReadAt() == null
                ? messages.countByGroupIdAndSenderIdNot(group.getId(), userId)
                : messages.countByGroupIdAndSenderIdNotAndSentAtAfter(group.getId(), userId, mine.getLastReadAt());
        return new GroupResponse(group.getId(), group.getName(), group.getDescription(), group.getOwnerId(), group.getCreatedAt(),
                mine == null ? (Objects.equals(group.getOwnerId(), userId) ? "ADMIN" : null) : mine.getRole(), unread,
                latest == null ? "" : latest.getContent(), latest == null ? null : latest.getSentAt(), members);
    }

    private GroupChat group(Long groupId) { return groups.findById(groupId).orElseThrow(() -> new IllegalArgumentException("Group was not found.")); }
    private void requireMember(Long groupId, Long userId, boolean platformAdmin) {
        group(groupId);
        if (!platformAdmin && !memberships.existsByGroupIdAndUserId(groupId, userId)) throw new AccessDeniedException("Group membership is required.");
    }
    private void requireGroupAdmin(GroupChat group, Long actorId, boolean platformAdmin) {
        if (platformAdmin) return;
        GroupMembership actor = memberships.findByGroupIdAndUserId(group.getId(), actorId).orElse(null);
        if (actor == null || !"ADMIN".equals(actor.getRole())) throw new AccessDeniedException("Only a group administrator may manage membership.");
    }
}
