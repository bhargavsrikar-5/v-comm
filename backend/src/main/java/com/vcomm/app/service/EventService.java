package com.vcomm.app.service;

import com.vcomm.app.dto.EventRequest;
import com.vcomm.app.model.Event;
import com.vcomm.app.repository.EventRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import com.vcomm.app.model.EventVisibility;

@Service
public class EventService {
    private final EventRepository eventRepository;

    public EventService(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    public List<Event> getEventsByUser(Long userId) {
        return eventRepository.findByUserIdOrVisibilityOrderByEventDateAsc(userId, EventVisibility.FACULTY);
    }

    public List<Event> getEventsByDate(Long userId, LocalDate date) {
        return java.util.stream.Stream.concat(
                eventRepository.findByUserIdAndEventDateOrderByTimeAsc(userId, date).stream(),
                eventRepository.findByEventDateAndVisibilityOrderByStartTimeAsc(date, EventVisibility.FACULTY).stream())
                .distinct().sorted(java.util.Comparator.comparing(Event::getStartTime, java.util.Comparator.nullsLast(java.util.Comparator.naturalOrder()))).toList();
    }

    public List<Event> getTodayEvents(Long userId) {
        return getEventsByDate(userId, LocalDate.now());
    }

    public List<Event> getUpcomingEvents(Long userId) {
        return java.util.stream.Stream.concat(
                eventRepository.findByUserIdAndEventDateGreaterThanEqualOrderByEventDateAsc(userId, LocalDate.now()).stream(),
                eventRepository.findByEventDateGreaterThanEqualAndVisibilityOrderByEventDateAscStartTimeAsc(LocalDate.now(), EventVisibility.FACULTY).stream())
                .distinct().sorted(java.util.Comparator.comparing(Event::getEventDate).thenComparing(Event::getStartTime, java.util.Comparator.nullsLast(java.util.Comparator.naturalOrder()))).toList();
    }

    public Event createEvent(Long authenticatedUserId, EventRequest request) {
        LocalTime start = request.getStartTime() != null ? request.getStartTime() : parseLegacyTime(request.getTime());
        validateTimes(start, request.getEndTime());
        Event event = new Event(authenticatedUserId, request.getTitle(), request.getTime() == null ? start.toString() : request.getTime(), request.getEventDate());
        applyDetails(event, request, start);
        return eventRepository.save(event);
    }

    @Transactional
    public Optional<Event> updateEvent(Long authenticatedUserId, Long eventId, EventRequest request) {
        return eventRepository.findById(eventId)
                .filter(event -> authenticatedUserId.equals(event.getUserId()))
                .map(event -> {
                    LocalTime start = request.getStartTime() != null ? request.getStartTime() : (request.getTime() == null ? event.getStartTime() : parseLegacyTime(request.getTime()));
                    validateTimes(start, request.getEndTime());
                    event.setTitle(request.getTitle());
                    event.setTime(request.getTime() == null ? start.toString() : request.getTime());
                    if (request.getEventDate() != null) event.setEventDate(request.getEventDate());
                    applyDetails(event, request, start);
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

    private void applyDetails(Event event, EventRequest request, LocalTime start) {
        event.setDescription(request.getDescription());
        event.setStartTime(start);
        event.setEndTime(request.getEndTime());
        event.setVisibility(request.getVisibility());
        event.setReminderMinutesBefore(request.getReminderMinutesBefore());
    }

    private LocalTime parseLegacyTime(String value) {
        if (value == null || value.isBlank()) throw new IllegalArgumentException("Event start time is required.");
        String start = value.trim().split("-", 2)[0].trim();
        try { return LocalTime.parse(start); }
        catch (Exception ignored) {
            try { return LocalTime.parse(start.toUpperCase(Locale.ROOT), DateTimeFormatter.ofPattern("h:mm a", Locale.ENGLISH)); }
            catch (Exception invalid) { throw new IllegalArgumentException("Event start time must use HH:mm or h:mm AM/PM format."); }
        }
    }

    private void validateTimes(LocalTime start, LocalTime end) {
        if (end != null && !end.isAfter(start)) throw new IllegalArgumentException("Event end time must be after start time.");
    }
}
