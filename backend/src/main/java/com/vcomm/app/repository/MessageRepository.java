package com.vcomm.app.repository;

import com.vcomm.app.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    @Query("SELECT m FROM Message m WHERE " +
           "(m.senderId = :user1 AND m.receiverId = :user2) OR " +
           "(m.senderId = :user2 AND m.receiverId = :user1) " +
           "ORDER BY m.sentAt ASC")
    List<Message> findChatHistory(@Param("user1") Long user1, @Param("user2") Long user2);

    @Query("SELECT m FROM Message m WHERE m.senderId = :userId OR m.receiverId = :userId ORDER BY m.sentAt DESC")
    List<Message> findAllByUserId(@Param("userId") Long userId);

    @Query("SELECT COUNT(m) FROM Message m WHERE m.senderId = :senderId AND m.receiverId = :receiverId AND m.isRead = false")
    long countUnreadMessages(@Param("senderId") Long senderId, @Param("receiverId") Long receiverId);

    @Modifying
    @Transactional
    @Query("UPDATE Message m SET m.isRead = true WHERE m.senderId = :senderId AND m.receiverId = :receiverId AND m.isRead = false")
    void markMessagesAsRead(@Param("senderId") Long senderId, @Param("receiverId") Long receiverId);
}
