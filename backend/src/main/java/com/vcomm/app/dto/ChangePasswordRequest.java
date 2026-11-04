package com.vcomm.app.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ChangePasswordRequest {
    @NotBlank(message = "Current password is required")
    @Size(max = 128, message = "Password is too long")
    private String oldPassword;

    @NotBlank(message = "New password is required")
    @Size(min = 10, max = 128, message = "New password must contain between 10 and 128 characters")
    private String newPassword;

    public String getOldPassword() { return oldPassword; }
    public void setOldPassword(String oldPassword) { this.oldPassword = oldPassword; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}
