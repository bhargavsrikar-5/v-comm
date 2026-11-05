package com.vcomm.app.service;

import com.vcomm.app.dto.*;
import com.vcomm.app.model.SearchHistory;
import com.vcomm.app.model.User;
import com.vcomm.app.model.UserRole;
import com.vcomm.app.repository.SearchHistoryRepository;
import com.vcomm.app.repository.UserRepository;
import com.vcomm.app.security.JwtService;
import com.vcomm.app.security.InstitutionalEmailPolicy;
import com.vcomm.app.model.AvailabilityStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.net.URI;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final SearchHistoryRepository searchHistoryRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final InstitutionalEmailPolicy emailPolicy;

    public UserService(UserRepository userRepository,
                       SearchHistoryRepository searchHistoryRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       InstitutionalEmailPolicy emailPolicy) {
        this.userRepository = userRepository;
        this.searchHistoryRepository = searchHistoryRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.emailPolicy = emailPolicy;
    }

    public AuthResponse login(LoginRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        if (!emailPolicy.isAllowed(email)) return new AuthResponse(false, "Invalid email or password");
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty() || !passwordEncoder.matches(request.getPassword(), userOpt.get().getPasswordHash())) {
            // Keep the same response for unknown email and wrong password.
            return new AuthResponse(false, "Invalid email or password");
        }

        User user = userOpt.get();
        String token = jwtService.issueToken(user);
        return new AuthResponse(true, "Login successful", UserResponse.from(user), token, jwtService.getExpirationSeconds());
    }

    @Transactional
    public UserResponse createFaculty(RegisterRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        emailPolicy.requireAllowed(email);
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email is already registered.");
        }

        User user = new User(
                request.getName().trim(),
                email,
                passwordEncoder.encode(request.getPassword()),
                request.getDept().trim(),
                request.getCustomId().trim(),
                request.getPhoneNumber());
        user.setRole(UserRole.FACULTY);
        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public ApiResponse changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User account was not found."));
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            return new ApiResponse(false, "Current password is incorrect.");
        }
        if (passwordEncoder.matches(request.getNewPassword(), user.getPasswordHash())) {
            return new ApiResponse(false, "Choose a new password that is different from the current password.");
        }
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        user.setTokenVersion(user.getTokenVersion() + 1);
        userRepository.save(user);
        return new ApiResponse(true, "Password changed successfully.");
    }

    @Transactional
    public void logout(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User account was not found."));
        user.setTokenVersion(user.getTokenVersion() + 1);
        userRepository.save(user);
    }

    public List<UserResponse> searchUsers(String query) {
        List<User> users = query == null || query.isBlank()
                ? userRepository.findAll()
                : userRepository.searchUsers(query.trim());
        return users.stream().map(UserResponse::from).toList();
    }

    public Optional<UserResponse> getUserById(Long id) {
        return userRepository.findById(id).map(UserResponse::from);
    }

    @Transactional
    public Optional<UserResponse> updateUser(Long id, UserUpdateRequest updatedInfo) {
        return userRepository.findById(id).map(user -> {
            if (updatedInfo.getName() != null && !updatedInfo.getName().isBlank()) {
                user.setName(updatedInfo.getName().trim());
            }
            if (updatedInfo.getDept() != null && !updatedInfo.getDept().isBlank()) {
                user.setDept(updatedInfo.getDept().trim());
            }
            if (updatedInfo.getPhoneNumber() != null) {
                user.setPhoneNumber(updatedInfo.getPhoneNumber().trim());
            }
            if (updatedInfo.getCustomId() != null && !updatedInfo.getCustomId().isBlank()) {
                user.setCustomId(updatedInfo.getCustomId().trim());
            }
            return UserResponse.from(userRepository.save(user));
        });
    }

    @Transactional
    public Optional<UserResponse> updateStatus(Long id, Boolean isPresent) {
        return userRepository.findById(id).map(user -> {
            user.setIsPresent(isPresent != null ? isPresent : !user.getIsPresent());
            return UserResponse.from(userRepository.save(user));
        });
    }

    @Transactional
    public Optional<UserResponse> updateAvailability(Long id, AvailabilityStatus status) {
        return userRepository.findById(id).map(user -> {
            user.setAvailabilityStatus(status);
            return UserResponse.from(userRepository.save(user));
        });
    }

    @Transactional
    public Optional<UserResponse> updateTimetableUrl(Long id, String timetableUrl) {
        if (timetableUrl == null || timetableUrl.isBlank() || timetableUrl.length() > 2000) {
            throw new IllegalArgumentException("A valid timetable URL is required.");
        }
        URI uri;
        try {
            uri = URI.create(timetableUrl.trim());
        } catch (IllegalArgumentException exception) {
            throw new IllegalArgumentException("Timetable URL is invalid.");
        }
        if (!"https".equalsIgnoreCase(uri.getScheme())) {
            throw new IllegalArgumentException("Timetable URL must use HTTPS.");
        }
        if (uri.getHost() == null) {
            throw new IllegalArgumentException("Timetable URL must contain a host name.");
        }
        return userRepository.findById(id).map(user -> {
            user.setTimetableUrl(uri.toString());
            return UserResponse.from(userRepository.save(user));
        });
    }

    public List<SearchHistory> getSearchHistory(Long userId) {
        return searchHistoryRepository.findTop15ByUserIdOrderBySearchedAtDesc(userId);
    }

    @Transactional
    public SearchHistory saveSearchHistory(Long userId, Long searchedUserId) {
        if (userId.equals(searchedUserId)) {
            throw new IllegalArgumentException("You cannot add your own profile to recent searches.");
        }
        User searchedUser = userRepository.findById(searchedUserId)
                .orElseThrow(() -> new IllegalArgumentException("The selected faculty member was not found."));
        searchHistoryRepository.deleteByUserIdAndSearchedUserId(userId, searchedUserId);
        SearchHistory history = new SearchHistory(
                userId, searchedUserId, searchedUser.getName(), searchedUser.getDept(), searchedUser.getCustomId());
        return searchHistoryRepository.save(history);
    }

    @Transactional
    public void deleteSearchHistoryItem(Long userId, Long searchedUserId) {
        searchHistoryRepository.deleteByUserIdAndSearchedUserId(userId, searchedUserId);
    }

    @Transactional
    public void clearSearchHistory(Long userId) {
        searchHistoryRepository.deleteAllByUserId(userId);
    }
}
