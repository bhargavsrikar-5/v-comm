package com.vcomm.app.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

/** Uses institution-supplied domains; deliberately does not guess a university domain. */
@Component
public class InstitutionalEmailPolicy {
    private final Set<String> allowedDomains;

    public InstitutionalEmailPolicy(@Value("${vcomm.security.allowed-email-domains:}") String configuredDomains) {
        allowedDomains = Arrays.stream(configuredDomains == null ? new String[0] : configuredDomains.split(","))
                .map(String::trim).map(String::toLowerCase).filter(domain -> !domain.isBlank())
                .collect(Collectors.toUnmodifiableSet());
    }

    public boolean isAllowed(String email) {
        if (allowedDomains.isEmpty()) return true;
        if (email == null) return false;
        int separator = email.lastIndexOf('@');
        return separator > 0 && allowedDomains.contains(email.substring(separator + 1).toLowerCase());
    }

    public void requireAllowed(String email) {
        if (!isAllowed(email)) throw new IllegalArgumentException("Use an email address from an institutionally configured domain.");
    }

    public boolean isConfigured() { return !allowedDomains.isEmpty(); }
}
