package com.vcomm.app.controller;

import com.vcomm.app.dto.*;
import com.vcomm.app.model.GroupMessage;
import com.vcomm.app.security.VCommPrincipal;
import com.vcomm.app.service.GroupService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/groups")
public class GroupController {
    private final GroupService service;
    public GroupController(GroupService service) { this.service=service; }
    @GetMapping public ResponseEntity<List<GroupResponse>> list(@AuthenticationPrincipal VCommPrincipal p) {
        return ResponseEntity.ok(service.list(p.userId(), p.role().name().equals("ADMIN")));
    }
    @PostMapping public ResponseEntity<GroupResponse> create(@AuthenticationPrincipal VCommPrincipal p, @Valid @RequestBody GroupCreateRequest r) {
        return ResponseEntity.ok(service.create(p.userId(), r));
    }
    @GetMapping("/{groupId}") public ResponseEntity<GroupResponse> get(@PathVariable Long groupId, @AuthenticationPrincipal VCommPrincipal p) {
        return ResponseEntity.ok(service.get(groupId, p.userId(), p.role().name().equals("ADMIN")));
    }
    @PostMapping("/{groupId}/members") public ResponseEntity<GroupMemberResponse> addMember(@PathVariable Long groupId,
            @AuthenticationPrincipal VCommPrincipal p, @Valid @RequestBody GroupMemberRequest r) {
        return ResponseEntity.ok(service.addMember(groupId, p.userId(), p.role().name().equals("ADMIN"), r.getUserId()));
    }
    @DeleteMapping("/{groupId}/members/{userId}") public ResponseEntity<ApiResponse> removeMember(@PathVariable Long groupId,
            @PathVariable Long userId, @AuthenticationPrincipal VCommPrincipal p) {
        service.removeMember(groupId, p.userId(), p.role().name().equals("ADMIN"), userId);
        return ResponseEntity.ok(new ApiResponse(true, "Group member removed."));
    }
    @GetMapping("/{groupId}/messages") public ResponseEntity<List<GroupMessage>> history(@PathVariable Long groupId, @AuthenticationPrincipal VCommPrincipal p) {
        return ResponseEntity.ok(service.history(groupId, p.userId(), p.role().name().equals("ADMIN")));
    }
    @PostMapping("/{groupId}/messages") public ResponseEntity<GroupMessage> send(@PathVariable Long groupId,
            @AuthenticationPrincipal VCommPrincipal p, @Valid @RequestBody GroupMessageRequest r) {
        return ResponseEntity.ok(service.send(groupId, p.userId(), r.getContent()));
    }
}
