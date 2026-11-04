package com.vcomm.app.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class RegisterRequest {
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Enter a valid email address")
    @Size(max = 100)
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 10, max = 128, message = "Password must contain between 10 and 128 characters")
    private String password;

    @NotBlank(message = "Department is required")
    @Size(max = 100)
    private String dept;

    @NotBlank(message = "Custom ID is required")
    @Size(max = 50)
    private String customId;

    @Size(max = 20)
    private String phoneNumber;

    public String getName() { return name; }
    public void setName(String name) { this.name = name == null ? null : name.trim(); }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email == null ? null : email.trim().toLowerCase(); }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getDept() { return dept; }
    public void setDept(String dept) { this.dept = dept == null ? null : dept.trim(); }
    public String getCustomId() { return customId; }
    public void setCustomId(String customId) { this.customId = customId == null ? null : customId.trim(); }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber == null ? null : phoneNumber.trim(); }
}
