package com.vcomm.app.repository;
import com.vcomm.app.model.GroupMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.time.LocalDateTime;
public interface GroupMessageRepository extends JpaRepository<GroupMessage, Long> {
    List<GroupMessage> findTop100ByGroupIdOrderBySentAtDesc(Long groupId);
    long countByGroupIdAndSenderIdNot(Long groupId, Long senderId);
    long countByGroupIdAndSenderIdNotAndSentAtAfter(Long groupId, Long senderId, LocalDateTime sentAt);
}
