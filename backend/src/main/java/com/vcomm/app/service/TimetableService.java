package com.vcomm.app.service;

import com.vcomm.app.dto.TimetableSlotRequest;
import com.vcomm.app.model.TimetableSlot;
import com.vcomm.app.repository.TimetableSlotRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class TimetableService {
    private final TimetableSlotRepository repository;
    public TimetableService(TimetableSlotRepository repository) { this.repository = repository; }
    public List<TimetableSlot> getSlots(Long userId) { return repository.findByUserIdOrderByDayOfWeekAscStartTimeAsc(userId); }

    @Transactional
    public TimetableSlot create(Long userId, TimetableSlotRequest request) {
        validate(request, null, userId);
        TimetableSlot slot = new TimetableSlot();
        slot.setUserId(userId);
        apply(slot, request);
        return repository.save(slot);
    }

    @Transactional
    public Optional<TimetableSlot> update(Long userId, Long slotId, TimetableSlotRequest request) {
        Optional<TimetableSlot> current = repository.findByIdAndUserId(slotId, userId);
        if (current.isEmpty()) return Optional.empty();
        validate(request, slotId, userId);
        TimetableSlot slot = current.get();
        apply(slot, request);
        return Optional.of(repository.save(slot));
    }

    @Transactional
    public boolean delete(Long userId, Long slotId) {
        Optional<TimetableSlot> slot = repository.findByIdAndUserId(slotId, userId);
        if (slot.isEmpty()) return false;
        repository.delete(slot.get());
        return true;
    }

    private void validate(TimetableSlotRequest request, Long excludeId, Long userId) {
        DayOfWeek day;
        try { day = DayOfWeek.valueOf(request.getDayOfWeek()); }
        catch (Exception ex) { throw new IllegalArgumentException("Choose a valid weekday."); }
        if (!request.getEndTime().isAfter(request.getStartTime())) throw new IllegalArgumentException("End time must be after start time.");
        boolean overlaps = repository.findByUserIdOrderByDayOfWeekAscStartTimeAsc(userId).stream()
                .filter(slot -> !slot.getId().equals(excludeId) && slot.getDayOfWeek().equals(day.name()))
                .anyMatch(slot -> request.getStartTime().isBefore(slot.getEndTime()) && request.getEndTime().isAfter(slot.getStartTime()));
        if (overlaps) throw new IllegalArgumentException("This timetable slot overlaps another activity on the same day.");
    }

    private void apply(TimetableSlot slot, TimetableSlotRequest request) {
        slot.setDayOfWeek(DayOfWeek.valueOf(request.getDayOfWeek()).name());
        slot.setStartTime(request.getStartTime());
        slot.setEndTime(request.getEndTime());
        slot.setCourseName(request.getCourseName());
        slot.setActivityDetails(request.getActivityDetails());
        slot.setLocation(request.getLocation());
        slot.setUpdatedAt(LocalDateTime.now());
    }
}
