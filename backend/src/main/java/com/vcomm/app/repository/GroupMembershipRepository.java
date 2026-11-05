package com.vcomm.app.repository;
import com.vcomm.app.model.GroupMembership;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
public interface GroupMembershipRepository extends JpaRepository<GroupMembership, Long> {
    List<GroupMembership> findByUserIdOrderByJoinedAtDesc(Long userId);
    List<GroupMembership> findByGroupIdOrderByJoinedAtAsc(Long groupId);
    Optional<GroupMembership> findByGroupIdAndUserId(Long groupId, Long userId);
    boolean existsByGroupIdAndUserId(Long groupId, Long userId);
}
