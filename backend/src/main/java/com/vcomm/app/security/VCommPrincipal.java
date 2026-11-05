package com.vcomm.app.security;

import com.vcomm.app.model.UserRole;

public record VCommPrincipal(Long userId, String email, UserRole role, long tokenVersion) { }
