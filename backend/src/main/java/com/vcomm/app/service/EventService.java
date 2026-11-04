package com.vcomm.app.service;

import com.vcomm.app.dto.EventRequest;
import com.vcomm.app.model.Event;
import com.vcomm.app.repository.EventRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class EventService {
    private final EventRepository eventRepository;

    public EventService(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    public List<Event> getEventsByUser(Long userId) {
        return eventRepository.findByUserIdOrderByEventDateAsc(userId);
    }

    public List<Event> getEventsByDate(Long userId, LocalDate date) {
        return eventRepository.findByUserIdAndEventDateOrderByTimeAsc(userId, date);
    }

    public List<Event> getTodayEvents(Long userId) {
        return eventRepository.findByUserIdAndEventDateOrderByTimeAsc(userId, LocalDate.now());
    }

    public List<Event> getUpcomingEvents(Long userId) {
        return eventRepository.findByUserIdAndEventDateGreaterThanEqualOrderByEventDateAsc(userId, LocalDate.now());
    }

    public Event createEvent(Long authenticatedUserId, EventRequest request) {
        Event event = new Event(authenticatedUserId, request.getTitle(), request.getTime(), request.getEventDate());
        return eventRepository.save(event);
    }

    @Transactional
    public Optional<Event> updateEvent(Long authenticatedUserId, Long eventId, EventRequest request) {
        return eventRepository.findById(eventId)
                .filter(event -> authenticatedUserId.equals(event.getUserId()))
                .map(event -> {
                    event.setTitle(request.getTitle());
                    event.setTime(request.getTime());
                    if (request.getEventDate() != null) event.setEventDate(request.getEventDate());
                    return eventRepository.save(event);
                });
    }

    @Transactional
    public boolean deleteEvent(Long authenticatedUserId, Long eventId) {
        Optional<Event> event = eventRepository.findById(eventId)
                .filter(existing -> authenticatedUserId.equals(existing.getUserId()));
        if (event.isEmpty()) return false;
        eventRepository.delete(event.get());
        return true;
    }
}
