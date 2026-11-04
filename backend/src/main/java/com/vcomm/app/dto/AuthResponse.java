package com.vcomm.app.dto;

public class AuthResponse {
    private boolean success;
    private String message;
    private UserResponse user;
    private String token;
    private String tokenType;
    private long expiresInSeconds;

    public AuthResponse() { }
    public AuthResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
    }
    public AuthResponse(boolean success, String message, UserResponse user, String token, long expiresInSeconds) {
        this.success = success;
        this.message = message;
        this.user = user;
        this.token = token;
        this.tokenType = "Bearer";
        this.expiresInSeconds = expiresInSeconds;
    }
    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public UserResponse getUser() { return user; }
    public String getToken() { return token; }
    public String getTokenType() { return tokenType; }
    public long getExpiresInSeconds() { return expiresInSeconds; }
}
