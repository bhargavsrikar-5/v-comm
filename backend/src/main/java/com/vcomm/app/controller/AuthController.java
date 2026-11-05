package com.vcomm.app.controller;

import com.vcomm.app.dto.ApiResponse;
import com.vcomm.app.dto.AuthResponse;
import com.vcomm.app.dto.ChangePasswordRequest;
import com.vcomm.app.dto.LoginRequest;
import com.vcomm.app.service.UserService;
import com.vcomm.app.security.VCommPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = userService.login(request);
        return response.isSuccess() ? ResponseEntity.ok(response) : ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
    }

    /** Public self-registration is intentionally disabled; use the ADMIN provisioning API. */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse> registerDisabled() {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(new ApiResponse(false, "Public registration is disabled. Faculty accounts are provisioned by an administrator."));
    }

    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse> changePassword(
            @AuthenticationPrincipal VCommPrincipal principal,
            @Valid @RequestBody ChangePasswordRequest request) {
        ApiResponse response = userService.changePassword(principal.userId(), request);
        return response.isSuccess() ? ResponseEntity.ok(response) : ResponseEntity.badRequest().body(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse> logout(@AuthenticationPrincipal VCommPrincipal principal) {
        userService.logout(principal.userId());
        return ResponseEntity.ok(new ApiResponse(true, "Session revoked."));
    }
}
