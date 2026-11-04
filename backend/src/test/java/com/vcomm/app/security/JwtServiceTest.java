package com.vcomm.app.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.vcomm.app.model.User;
import com.vcomm.app.model.UserRole;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtServiceTest {
    private static final String TEST_ONLY_SECRET = "vcomm-unit-test-secret-never-used-in-deployments";

    private final JwtService jwtService = new JwtService(new ObjectMapper(), TEST_ONLY_SECRET, 3600);

    @Test
    void issuedTokenRetainsAuthenticatedIdentityAndRole() {
        User user = new User("Test Faculty", "faculty@example.invalid", "not-a-real-password-hash",
                "Testing", "TEST-1", null);
        user.setId(42L);
        user.setRole(UserRole.FACULTY);

        VCommPrincipal principal = jwtService.verifyToken(jwtService.issueToken(user));

        assertThat(principal.userId()).isEqualTo(42L);
        assertThat(principal.email()).isEqualTo("faculty@example.invalid");
        assertThat(principal.role()).isEqualTo(UserRole.FACULTY);
    }

    @Test
    void rejectsTokenWithTamperedSignature() {
        User user = new User("Test Faculty", "faculty@example.invalid", "not-a-real-password-hash",
                "Testing", "TEST-1", null);
        user.setId(42L);
        String[] parts = jwtService.issueToken(user).split("\\.");
        char first = parts[2].charAt(0);
        parts[2] = (first == 'A' ? "B" : "A") + parts[2].substring(1);

        assertThatThrownBy(() -> jwtService.verifyToken(String.join(".", parts)))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void rejectsSigningSecretShorterThanThirtyTwoBytes() {
        assertThatThrownBy(() -> new JwtService(new ObjectMapper(), "too-short", 3600))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("32 UTF-8 bytes");
    }

    @Test
    void rejectsExpirationOutsideConfiguredBounds() {
        assertThatThrownBy(() -> new JwtService(new ObjectMapper(), TEST_ONLY_SECRET, 299))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("between 300 and 604800");
    }
}
