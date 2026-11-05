package com.vcomm.app.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalTime;

public class TimetableSlotRequest {
    @NotBlank private String dayOfWeek;
    @NotNull @JsonFormat(pattern="HH:mm") private LocalTime startTime;
    @NotNull @JsonFormat(pattern="HH:mm") private LocalTime endTime;
    @NotBlank @Size(max=160) private String courseName;
    @Size(max=500) private String activityDetails;
    @Size(max=120) private String location;
    public String getDayOfWeek(){return dayOfWeek;} public void setDayOfWeek(String value){dayOfWeek=value==null?null:value.trim().toUpperCase();}
    public LocalTime getStartTime(){return startTime;} public void setStartTime(LocalTime value){startTime=value;}
    public LocalTime getEndTime(){return endTime;} public void setEndTime(LocalTime value){endTime=value;}
    public String getCourseName(){return courseName;} public void setCourseName(String value){courseName=value==null?null:value.trim();}
    public String getActivityDetails(){return activityDetails;} public void setActivityDetails(String value){activityDetails=value==null?null:value.trim();}
    public String getLocation(){return location;} public void setLocation(String value){location=value==null?null:value.trim();}
}
