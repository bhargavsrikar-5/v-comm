package com.vcomm.app.controller;

import com.vcomm.app.dto.ApiResponse;
import com.vcomm.app.dto.UserResponse;
import com.vcomm.app.dto.UserUpdateRequest;
import com.vcomm.app.model.SearchHistory;
import com.vcomm.app.security.VCommPrincipal;
import com.vcomm.app.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ResponseEntity<List<UserResponse>> getUsers(@RequestParam(required = false) String query) {
        return ResponseEntity.ok(userService.searchUsers(query));
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        return userService.getUserById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id,
                                         @AuthenticationPrincipal VCommPrincipal principal,
                                         @Valid @RequestBody UserUpdateRequest request) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only update your own profile."));
        return userService.updateUser(id, request).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateStatus(@PathVariable Long id,
                                           @AuthenticationPrincipal VCommPrincipal principal,
                                           @RequestBody(required = false) Map<String, Boolean> body) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only update your own presence."));
        Boolean isPresent = body != null && body.containsKey("isPresent") ? body.get("isPresent") : null;
        return userService.updateStatus(id, isPresent).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}/timetable")
    public ResponseEntity<?> updateTimetable(@PathVariable Long id,
                                              @AuthenticationPrincipal VCommPrincipal principal,
                                              @RequestBody(required = false) Map<String, String> body) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only update your own timetable."));
        String timetableUrl = body != null ? body.get("timetableUrl") : null;
        return userService.updateTimetableUrl(id, timetableUrl).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/search-history")
    public ResponseEntity<?> getSearchHistory(@PathVariable Long id, @AuthenticationPrincipal VCommPrincipal principal) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only view your own search history."));
        return ResponseEntity.ok(userService.getSearchHistory(id));
    }

    @PostMapping("/{id}/search-history")
    public ResponseEntity<?> saveSearchHistory(@PathVariable Long id,
                                                @AuthenticationPrincipal VCommPrincipal principal,
                                                @RequestBody Map<String, Long> body) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only update your own search history."));
        Long searchedUserId = body == null ? null : body.get("searchedUserId");
        if (searchedUserId == null) return ResponseEntity.badRequest().body(new ApiResponse(false, "searchedUserId is required."));
        SearchHistory saved = userService.saveSearchHistory(id, searchedUserId);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{id}/search-history")
    public ResponseEntity<ApiResponse> clearSearchHistory(@PathVariable Long id,
                                                           @AuthenticationPrincipal VCommPrincipal principal,
                                                           @RequestParam(required = false) Long searchedUserId) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only clear your own search history."));
        if (searchedUserId != null) {
            userService.deleteSearchHistoryItem(id, searchedUserId);
            return ResponseEntity.ok(new ApiResponse(true, "Search item removed."));
        }
        userService.clearSearchHistory(id);
        return ResponseEntity.ok(new ApiResponse(true, "Search history cleared."));
    }
}
