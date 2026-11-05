package com.vcomm.app.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.time.LocalTime;
import com.vcomm.app.model.EventVisibility;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;

public class EventRequest {
    @NotBlank(message = "Title is required")
    @Size(max = 200)
    private String title;

    @Size(max = 50) private String time;

    @Size(max = 1000) private String description;
    @JsonFormat(pattern = "HH:mm") private LocalTime startTime;
    @JsonFormat(pattern = "HH:mm") private LocalTime endTime;
    private EventVisibility visibility = EventVisibility.PRIVATE;
    @Min(0) @Max(10080) private Integer reminderMinutesBefore;

    @NotNull(message = "Event date is required")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate eventDate;

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title == null ? null : title.trim(); }
    public String getTime() { return time; }
    public void setTime(String time) { this.time = time == null ? null : time.trim(); }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description == null ? null : description.trim(); }
    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }
    public LocalTime getEndTime() { return endTime; }
    public void setEndTime(LocalTime endTime) { this.endTime = endTime; }
    public EventVisibility getVisibility() { return visibility == null ? EventVisibility.PRIVATE : visibility; }
    public void setVisibility(EventVisibility visibility) { this.visibility = visibility; }
    public Integer getReminderMinutesBefore() { return reminderMinutesBefore; }
    public void setReminderMinutesBefore(Integer reminderMinutesBefore) { this.reminderMinutesBefore = reminderMinutesBefore; }
    public LocalDate getEventDate() { return eventDate; }
    public void setEventDate(LocalDate eventDate) { this.eventDate = eventDate; }
}
