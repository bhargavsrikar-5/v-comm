package com.vcomm.app.controller;

import com.vcomm.app.dto.ApiResponse;
import com.vcomm.app.dto.RegisterRequest;
import com.vcomm.app.dto.UserResponse;
import com.vcomm.app.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final UserService userService;

    public AdminController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserResponse>> listUsers() {
        return ResponseEntity.ok(userService.searchUsers(null));
    }

    @PostMapping("/users")
    public ResponseEntity<?> createFaculty(@Valid @RequestBody RegisterRequest request) {
        try {
            return ResponseEntity.status(HttpStatus.CREATED).body(userService.createFaculty(request));
        } catch (IllegalArgumentException exception) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(new ApiResponse(false, exception.getMessage()));
        }
    }
}
