package com.vcomm.app.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class MessageRequest {
    @NotNull(message = "Receiver ID is required")
    private Long receiverId;

    @NotBlank(message = "Content is required")
    @Size(max = 4000, message = "Message must not exceed 4,000 characters")
    private String content;

    public Long getReceiverId() { return receiverId; }
    public void setReceiverId(Long receiverId) { this.receiverId = receiverId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content == null ? null : content.trim(); }
}
