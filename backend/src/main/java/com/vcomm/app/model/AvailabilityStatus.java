package com.vcomm.app.model;

import java.util.Arrays;

/** Only the labels named in the capstone report and supporting presentation. */
public enum AvailabilityStatus {
    PRESENT("Present"), ABSENT("Absent"), AVAILABLE("Available"), BUSY("Busy"), IN_CLASS("In Class");

    private final String label;

    AvailabilityStatus(String label) { this.label = label; }

    public String getLabel() { return label; }

    public static AvailabilityStatus fromLabel(String value) {
        if (value == null || value.isBlank()) throw new IllegalArgumentException("Availability status is required.");
        return Arrays.stream(values())
                .filter(status -> status.name().equalsIgnoreCase(value.trim().replace(' ', '_'))
                        || status.label.equalsIgnoreCase(value.trim()))
                .findFirst().orElseThrow(() -> new IllegalArgumentException("Unsupported availability status."));
    }
}
