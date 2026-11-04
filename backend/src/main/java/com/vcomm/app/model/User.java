package com.vcomm.app.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @JsonIgnore
    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UserRole role = UserRole.FACULTY;

    @Column(length = 100)
    private String dept;

    @Column(name = "custom_id", length = 50)
    private String customId;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "photo_url", length = 500)
    private String photoUrl;

    @Column(name = "timetable_url", columnDefinition = "TEXT")
    private String timetableUrl;

    @Column(name = "is_present")
    private Boolean isPresent = false;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public User() { }

    public User(String name, String email, String passwordHash, String dept, String customId, String phoneNumber) {
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.dept = dept;
        this.customId = customId;
        this.phoneNumber = phoneNumber;
        this.isPresent = false;
        this.role = UserRole.FACULTY;
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    @JsonIgnore
    public String getPasswordHash() { return passwordHash; }
    @JsonIgnore
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public UserRole getRole() { return role; }
    public void setRole(UserRole role) { this.role = role; }
    public String getDept() { return dept; }
    public void setDept(String dept) { this.dept = dept; }
    public String getCustomId() { return customId; }
    public void setCustomId(String customId) { this.customId = customId; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public String getTimetableUrl() { return timetableUrl; }
    public void setTimetableUrl(String timetableUrl) { this.timetableUrl = timetableUrl; }
    public Boolean getIsPresent() { return isPresent != null ? isPresent : false; }
    public void setIsPresent(Boolean present) { isPresent = present; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
