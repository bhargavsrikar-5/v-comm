package com.vcomm.app.controller;

import com.vcomm.app.dto.ApiResponse;
import com.vcomm.app.dto.EventRequest;
import com.vcomm.app.model.Event;
import com.vcomm.app.security.VCommPrincipal;
import com.vcomm.app.service.EventService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/events")
public class EventController {
    private final EventService eventService;

    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @GetMapping
    public ResponseEntity<List<Event>> getEvents(
            @AuthenticationPrincipal VCommPrincipal principal,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Long userId = principal.userId();
        return ResponseEntity.ok(date == null
                ? eventService.getEventsByUser(userId)
                : eventService.getEventsByDate(userId, date));
    }

    @GetMapping("/today")
    public ResponseEntity<List<Event>> getTodayEvents(@AuthenticationPrincipal VCommPrincipal principal) {
        return ResponseEntity.ok(eventService.getTodayEvents(principal.userId()));
    }

    @GetMapping("/upcoming")
    public ResponseEntity<List<Event>> getUpcomingEvents(@AuthenticationPrincipal VCommPrincipal principal) {
        return ResponseEntity.ok(eventService.getUpcomingEvents(principal.userId()));
    }

    @PostMapping
    public ResponseEntity<Event> createEvent(@AuthenticationPrincipal VCommPrincipal principal,
                                              @Valid @RequestBody EventRequest request) {
        return ResponseEntity.ok(eventService.createEvent(principal.userId(), request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Event> updateEvent(@AuthenticationPrincipal VCommPrincipal principal,
                                              @PathVariable Long id,
                                              @Valid @RequestBody EventRequest request) {
        return eventService.updateEvent(principal.userId(), id, request)
                .map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse> deleteEvent(@AuthenticationPrincipal VCommPrincipal principal,
                                                    @PathVariable Long id) {
        if (eventService.deleteEvent(principal.userId(), id)) {
            return ResponseEntity.ok(new ApiResponse(true, "Event deleted successfully."));
        }
        return ResponseEntity.notFound().build();
    }
}
