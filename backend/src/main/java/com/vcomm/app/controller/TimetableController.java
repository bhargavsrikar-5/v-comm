package com.vcomm.app.controller;

import com.vcomm.app.dto.ApiResponse;
import com.vcomm.app.dto.TimetableSlotRequest;
import com.vcomm.app.model.TimetableSlot;
import com.vcomm.app.security.VCommPrincipal;
import com.vcomm.app.service.TimetableService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/users/{id}/timetable/slots")
public class TimetableController {
    private final TimetableService service;
    public TimetableController(TimetableService service) { this.service = service; }
    @GetMapping
    public ResponseEntity<List<TimetableSlot>> get(@PathVariable Long id) { return ResponseEntity.ok(service.getSlots(id)); }
    @PostMapping
    public ResponseEntity<?> create(@PathVariable Long id, @AuthenticationPrincipal VCommPrincipal principal,
                                    @Valid @RequestBody TimetableSlotRequest request) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only manage your own timetable."));
        return ResponseEntity.ok(service.create(id, request));
    }
    @PutMapping("/{slotId}")
    public ResponseEntity<?> update(@PathVariable Long id, @PathVariable Long slotId, @AuthenticationPrincipal VCommPrincipal principal,
                                    @Valid @RequestBody TimetableSlotRequest request) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only manage your own timetable."));
        return service.update(id, slotId, request).<ResponseEntity<?>>map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
    @DeleteMapping("/{slotId}")
    public ResponseEntity<?> delete(@PathVariable Long id, @PathVariable Long slotId, @AuthenticationPrincipal VCommPrincipal principal) {
        if (!id.equals(principal.userId())) return ResponseEntity.status(403).body(new ApiResponse(false, "You can only manage your own timetable."));
        return service.delete(id, slotId) ? ResponseEntity.ok(new ApiResponse(true, "Timetable slot deleted.")) : ResponseEntity.notFound().build();
    }
}
