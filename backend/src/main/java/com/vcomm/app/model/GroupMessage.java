package com.vcomm.app.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "group_messages", indexes = @Index(name = "idx_group_messages_group_time", columnList = "group_id, sent_at"))
public class GroupMessage {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name = "group_id", nullable = false) private Long groupId;
    @Column(name = "sender_id", nullable = false) private Long senderId;
    @Column(nullable = false, columnDefinition = "TEXT") private String content;
    @Column(name = "sent_at", nullable = false, updatable = false) private LocalDateTime sentAt = LocalDateTime.now();
    public GroupMessage() { }
    public GroupMessage(Long groupId, Long senderId, String content) { this.groupId=groupId; this.senderId=senderId; this.content=content; }
    public Long getId(){return id;} public void setId(Long id){this.id=id;}
    public Long getGroupId(){return groupId;} public void setGroupId(Long groupId){this.groupId=groupId;}
    public Long getSenderId(){return senderId;} public void setSenderId(Long senderId){this.senderId=senderId;}
    public String getContent(){return content;} public void setContent(String content){this.content=content;}
    public LocalDateTime getSentAt(){return sentAt;} public void setSentAt(LocalDateTime sentAt){this.sentAt=sentAt;}
}
