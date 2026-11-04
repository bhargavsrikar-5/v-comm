package com.vcomm.app.bootstrap;

import com.vcomm.app.model.User;
import com.vcomm.app.model.UserRole;
import com.vcomm.app.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class AdminBootstrapper implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(AdminBootstrapper.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final String email;
    private final String password;
    private final String name;

    public AdminBootstrapper(UserRepository userRepository,
                             PasswordEncoder passwordEncoder,
                             @Value("${vcomm.bootstrap.admin-email:}") String email,
                             @Value("${vcomm.bootstrap.admin-password:}") String password,
                             @Value("${vcomm.bootstrap.admin-name:V-COMM Administrator}") String name) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.email = email == null ? "" : email.trim().toLowerCase();
        this.password = password == null ? "" : password;
        this.name = name == null || name.isBlank() ? "V-COMM Administrator" : name.trim();
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (email.isBlank() && password.isBlank()) {
            log.info("No bootstrap administrator configured. Set VCOMM_ADMIN_EMAIL and VCOMM_ADMIN_PASSWORD to provision one.");
            return;
        }
        if (email.isBlank() || password.length() < 14) {
            throw new IllegalStateException("Configure both VCOMM_ADMIN_EMAIL and a VCOMM_ADMIN_PASSWORD of at least 14 characters.");
        }
        if (userRepository.existsByEmail(email)) {
            log.info("Configured bootstrap administrator already exists; no account changes were made.");
            return;
        }

        User admin = new User(name, email, passwordEncoder.encode(password), "Administration", "ADMIN", null);
        admin.setRole(UserRole.ADMIN);
        userRepository.save(admin);
        log.info("Initial V-COMM administrator account provisioned for the configured email address.");
    }
}
