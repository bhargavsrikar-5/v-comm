ALTER TABLE users ADD COLUMN token_version BIGINT NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN availability_status VARCHAR(20) NOT NULL DEFAULT 'ABSENT';
UPDATE users SET availability_status = CASE WHEN is_present = TRUE THEN 'PRESENT' ELSE 'ABSENT' END;

ALTER TABLE events ADD COLUMN description VARCHAR(1000);
ALTER TABLE events ADD COLUMN start_time TIME;
ALTER TABLE events ADD COLUMN end_time TIME;
ALTER TABLE events ADD COLUMN visibility VARCHAR(20) NOT NULL DEFAULT 'PRIVATE';
ALTER TABLE events ADD COLUMN reminder_minutes_before INTEGER;

CREATE TABLE timetable_slots (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    day_of_week VARCHAR(9) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    course_name VARCHAR(160) NOT NULL,
    activity_details VARCHAR(500),
    location VARCHAR(120),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_timetable_slots_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX idx_timetable_owner_day_start ON timetable_slots(user_id, day_of_week, start_time);

CREATE TABLE group_chats (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    description VARCHAR(500),
    owner_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_group_chats_owner FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE TABLE group_memberships (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    group_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role VARCHAR(10) NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP NULL,
    CONSTRAINT uq_group_member UNIQUE(group_id, user_id),
    CONSTRAINT fk_group_membership_group FOREIGN KEY (group_id) REFERENCES group_chats(id) ON DELETE CASCADE,
    CONSTRAINT fk_group_membership_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX idx_group_membership_user ON group_memberships(user_id, group_id);
CREATE TABLE group_messages (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    group_id BIGINT NOT NULL,
    sender_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_group_messages_group FOREIGN KEY (group_id) REFERENCES group_chats(id) ON DELETE CASCADE,
    CONSTRAINT fk_group_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX idx_group_messages_group_time ON group_messages(group_id, sent_at);
