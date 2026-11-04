-- Fresh unified V-COMM schema. Passwords are stored only as adaptive BCrypt hashes.
CREATE TABLE users (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'FACULTY',
    dept VARCHAR(100),
    custom_id VARCHAR(50),
    phone_number VARCHAR(20),
    photo_url VARCHAR(500),
    timetable_url TEXT,
    is_present BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_name ON users (name);
CREATE INDEX idx_users_dept ON users (dept);
CREATE INDEX idx_users_custom_id ON users (custom_id);

CREATE TABLE events (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    time VARCHAR(50) NOT NULL,
    event_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_events_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE INDEX idx_events_user_date ON events (user_id, event_date);

CREATE TABLE messages (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE INDEX idx_messages_sender_receiver_time ON messages (sender_id, receiver_id, sent_at);
CREATE INDEX idx_messages_receiver_read ON messages (receiver_id, is_read);

CREATE TABLE search_history (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    searched_user_id BIGINT NOT NULL,
    searched_user_name VARCHAR(100),
    searched_user_dept VARCHAR(100),
    searched_user_custom_id VARCHAR(50),
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_search_history_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_search_history_searched_user FOREIGN KEY (searched_user_id) REFERENCES users (id) ON DELETE CASCADE
);
CREATE INDEX idx_search_history_user_time ON search_history (user_id, searched_at);
