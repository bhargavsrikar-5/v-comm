package com.vcomm.app.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "group_memberships", uniqueConstraints = @UniqueConstraint(name = "uq_group_member", columnNames = {"group_id", "user_id"}))
public class GroupMembership {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name = "group_id", nullable = false) private Long groupId;
    @Column(name = "user_id", nullable = false) private Long userId;
    @Column(nullable = false, length = 10) private String role;
    @Column(name = "joined_at", nullable = false) private LocalDateTime joinedAt = LocalDateTime.now();
    @Column(name = "last_read_at") private LocalDateTime lastReadAt;
    public GroupMembership() { }
    public GroupMembership(Long groupId, Long userId, String role) { this.groupId=groupId; this.userId=userId; this.role=role; }
    public Long getId(){return id;} public void setId(Long id){this.id=id;}
    public Long getGroupId(){return groupId;} public void setGroupId(Long groupId){this.groupId=groupId;}
    public Long getUserId(){return userId;} public void setUserId(Long userId){this.userId=userId;}
    public String getRole(){return role;} public void setRole(String role){this.role=role;}
    public LocalDateTime getJoinedAt(){return joinedAt;} public void setJoinedAt(LocalDateTime joinedAt){this.joinedAt=joinedAt;}
    public LocalDateTime getLastReadAt(){return lastReadAt;} public void setLastReadAt(LocalDateTime lastReadAt){this.lastReadAt=lastReadAt;}
}
