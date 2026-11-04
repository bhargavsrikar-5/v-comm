package com.vcomm.app.security;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vcomm.app.model.User;
import com.vcomm.app.model.Event;
import com.vcomm.app.model.UserRole;
import com.vcomm.app.repository.EventRepository;
import com.vcomm.app.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
        "vcomm.security.jwt-secret=test-only-secret-that-is-longer-than-thirty-two-bytes",
        "spring.datasource.url=jdbc:h2:mem:vcomm-auth-test;MODE=MySQL;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE",
        "vcomm.bootstrap.admin-email=",
        "vcomm.bootstrap.admin-password="
})
@AutoConfigureMockMvc
class ApiAuthorizationIntegrationTest {
    private static final String PASSWORD = "faculty-password-123";

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private UserRepository userRepository;
    @Autowired private EventRepository eventRepository;
    @Autowired private PasswordEncoder passwordEncoder;
    @Autowired private JwtService jwtService;

    @Test
    void protectedDirectoryRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void loginIssuesBearerTokenAndNeverSerializesPasswordHash() throws Exception {
        User faculty = createUser(UserRole.FACULTY);
        String body = objectMapper.writeValueAsString(
                java.util.Map.of("email", faculty.getEmail(), "password", PASSWORD));

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andReturn();

        JsonNode response = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(response.path("user").has("passwordHash")).isFalse();
    }

    @Test
    void invalidPasswordDoesNotAuthenticate() throws Exception {
        User faculty = createUser(UserRole.FACULTY);
        String body = objectMapper.writeValueAsString(
                java.util.Map.of("email", faculty.getEmail(), "password", "wrong-password"));

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void passwordChangeReplacesTheCredentialUsedForLogin() throws Exception {
        User faculty = createUser(UserRole.FACULTY);
        String token = jwtService.issueToken(faculty);
        String changeRequest = objectMapper.writeValueAsString(java.util.Map.of(
                "oldPassword", PASSWORD, "newPassword", "new-faculty-password-456"));

        mockMvc.perform(post("/api/auth/change-password")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(changeRequest))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(java.util.Map.of(
                                "email", faculty.getEmail(), "password", PASSWORD))))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(java.util.Map.of(
                                "email", faculty.getEmail(), "password", "new-faculty-password-456"))))
                .andExpect(status().isOk());
    }
    @Test
    void facultyCannotAccessAdminProvisioningButAdminCan() throws Exception {
        User faculty = createUser(UserRole.FACULTY);
        User admin = createUser(UserRole.ADMIN);
        String facultyToken = jwtService.issueToken(faculty);
        String adminToken = jwtService.issueToken(admin);

        mockMvc.perform(get("/api/admin/users").header("Authorization", "Bearer " + facultyToken))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/api/admin/users").header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk());
    }

    @Test
    void facultyCannotModifyOrReadAnotherUsersPrivateData() throws Exception {
        User actor = createUser(UserRole.FACULTY);
        User other = createUser(UserRole.FACULTY);
        String token = jwtService.issueToken(actor);
        String profileUpdate = objectMapper.writeValueAsString(java.util.Map.of("name", "Unauthorized change"));

        mockMvc.perform(put("/api/users/{id}", other.getId())
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(profileUpdate))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/api/users/{id}/search-history", other.getId())
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    @Test
    void facultyCanModifyOwnProfile() throws Exception {
        User actor = createUser(UserRole.FACULTY);
        String token = jwtService.issueToken(actor);
        String profileUpdate = objectMapper.writeValueAsString(java.util.Map.of("name", "Updated Name"));

        mockMvc.perform(put("/api/users/{id}", actor.getId())
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(profileUpdate))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Updated Name"));
    }

    @Test
    void facultyCannotReadOrModifyAnotherUsersEvents() throws Exception {
        User actor = createUser(UserRole.FACULTY);
        User other = createUser(UserRole.FACULTY);
        Event otherEvent = eventRepository.save(new Event(other.getId(), "Private event", "09:00",
                java.time.LocalDate.now().plusDays(1)));
        String token = jwtService.issueToken(actor);
        String update = objectMapper.writeValueAsString(java.util.Map.of(
                "title", "Unauthorized change", "time", "10:00",
                "eventDate", java.time.LocalDate.now().plusDays(2).toString()));

        mockMvc.perform(get("/api/events").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isEmpty());
        mockMvc.perform(put("/api/events/{id}", otherEvent.getId())
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(update))
                .andExpect(status().isNotFound());
    }

    private User createUser(UserRole role) {
        String email = UUID.randomUUID() + "@example.edu";
        User user = new User("Test Faculty", email, passwordEncoder.encode(PASSWORD),
                "Computer Science", UUID.randomUUID().toString().substring(0, 8), null);
        user.setRole(role);
        return userRepository.save(user);
    }
}
