package com.vcomm.app.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "search_history")
public class SearchHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "searched_user_id", nullable = false)
    private Long searchedUserId;

    @Column(name = "searched_user_name", length = 100)
    private String searchedUserName;

    @Column(name = "searched_user_dept", length = 100)
    private String searchedUserDept;

    @Column(name = "searched_user_custom_id", length = 50)
    private String searchedUserCustomId;

    @Column(name = "searched_at", updatable = false)
    private LocalDateTime searchedAt = LocalDateTime.now();

    public SearchHistory() {
    }

    public SearchHistory(Long userId, Long searchedUserId, String searchedUserName, String searchedUserDept, String searchedUserCustomId) {
        this.userId = userId;
        this.searchedUserId = searchedUserId;
        this.searchedUserName = searchedUserName;
        this.searchedUserDept = searchedUserDept;
        this.searchedUserCustomId = searchedUserCustomId;
        this.searchedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getSearchedUserId() {
        return searchedUserId;
    }

    public void setSearchedUserId(Long searchedUserId) {
        this.searchedUserId = searchedUserId;
    }

    public String getSearchedUserName() {
        return searchedUserName;
    }

    public void setSearchedUserName(String searchedUserName) {
        this.searchedUserName = searchedUserName;
    }

    public String getSearchedUserDept() {
        return searchedUserDept;
    }

    public void setSearchedUserDept(String searchedUserDept) {
        this.searchedUserDept = searchedUserDept;
    }

    public String getSearchedUserCustomId() {
        return searchedUserCustomId;
    }

    public void setSearchedUserCustomId(String searchedUserCustomId) {
        this.searchedUserCustomId = searchedUserCustomId;
    }

    public LocalDateTime getSearchedAt() {
        return searchedAt;
    }

    public void setSearchedAt(LocalDateTime searchedAt) {
        this.searchedAt = searchedAt;
    }
}
