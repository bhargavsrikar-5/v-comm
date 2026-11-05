package com.vcomm.app.repository;
import com.vcomm.app.model.TimetableSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
public interface TimetableSlotRepository extends JpaRepository<TimetableSlot, Long> {
    List<TimetableSlot> findByUserIdOrderByDayOfWeekAscStartTimeAsc(Long userId);
    Optional<TimetableSlot> findByIdAndUserId(Long id, Long userId);
}
