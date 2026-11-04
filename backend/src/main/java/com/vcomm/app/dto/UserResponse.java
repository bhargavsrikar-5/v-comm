package com.vcomm.app.dto;

import com.vcomm.app.model.User;
import com.vcomm.app.model.UserRole;

public class UserResponse {
    private Long id;
    private String name;
    private String email;
    private String dept;
    private String customId;
    private String phoneNumber;
    private String photoUrl;
    private String timetableUrl;
    private boolean isPresent;
    private UserRole role;

    public static UserResponse from(User user) {
        UserResponse response = new UserResponse();
        response.id = user.getId();
        response.name = user.getName();
        response.email = user.getEmail();
        response.dept = user.getDept();
        response.customId = user.getCustomId();
        response.phoneNumber = user.getPhoneNumber();
        response.photoUrl = user.getPhotoUrl();
        response.timetableUrl = user.getTimetableUrl();
        response.isPresent = user.getIsPresent();
        response.role = user.getRole();
        return response;
    }

    public Long getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getDept() { return dept; }
    public String getCustomId() { return customId; }
    public String getPhoneNumber() { return phoneNumber; }
    public String getPhotoUrl() { return photoUrl; }
    public String getTimetableUrl() { return timetableUrl; }
    public boolean getIsPresent() { return isPresent; }
    public UserRole getRole() { return role; }
}
