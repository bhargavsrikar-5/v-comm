package com.vcomm.app.service;

import com.vcomm.app.dto.EventRequest;
import com.vcomm.app.model.Event;
import com.vcomm.app.repository.EventRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EventServiceTest {
    @Mock
    private EventRepository eventRepository;

    private EventService eventService;

    @BeforeEach
    void setUp() {
        eventService = new EventService(eventRepository);
    }

    @Test
    void createEventUsesAuthenticatedOwnerId() {
        EventRequest request = request();
        when(eventRepository.save(any(Event.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Event created = eventService.createEvent(41L, request);

        assertThat(created.getUserId()).isEqualTo(41L);
        verify(eventRepository).save(any(Event.class));
    }

    @Test
    void updateDoesNotChangeAnotherUsersEvent() {
        Event existing = new Event(7L, "Original", "09:00", LocalDate.of(2026, 11, 5));
        when(eventRepository.findById(12L)).thenReturn(Optional.of(existing));

        assertThat(eventService.updateEvent(41L, 12L, request())).isEmpty();

        assertThat(existing.getTitle()).isEqualTo("Original");
        verify(eventRepository, never()).save(any(Event.class));
    }

    @Test
    void deleteDoesNotRemoveAnotherUsersEvent() {
        Event existing = new Event(7L, "Original", "09:00", LocalDate.of(2026, 11, 5));
        when(eventRepository.findById(12L)).thenReturn(Optional.of(existing));

        assertThat(eventService.deleteEvent(41L, 12L)).isFalse();

        verify(eventRepository, never()).delete(any(Event.class));
    }

    private EventRequest request() {
        EventRequest request = new EventRequest();
        request.setTitle("Updated");
        request.setTime("10:30");
        request.setEventDate(LocalDate.of(2026, 11, 6));
        return request;
    }
}
