package com.vcomm.app.dto;
import jakarta.validation.constraints.NotNull;
public class GroupMemberRequest { @NotNull private Long userId; public Long getUserId(){return userId;} public void setUserId(Long userId){this.userId=userId;} }
