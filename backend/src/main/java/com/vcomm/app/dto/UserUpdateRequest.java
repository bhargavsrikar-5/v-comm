package com.vcomm.app.dto;

import jakarta.validation.constraints.Size;

public class UserUpdateRequest {
    @Size(min = 2, max = 100)
    private String name;
    @Size(max = 100)
    private String dept;
    @Size(max = 50)
    private String customId;
    @Size(max = 20)
    private String phoneNumber;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDept() { return dept; }
    public void setDept(String dept) { this.dept = dept; }
    public String getCustomId() { return customId; }
    public void setCustomId(String customId) { this.customId = customId; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
}
