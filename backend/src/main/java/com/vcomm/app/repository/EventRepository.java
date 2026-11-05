package com.vcomm.app.repository;

import com.vcomm.app.model.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {

    List<Event> findByUserIdOrderByEventDateAsc(Long userId);
    List<Event> findByUserIdOrVisibilityOrderByEventDateAsc(Long userId, com.vcomm.app.model.EventVisibility visibility);

    List<Event> findByUserIdAndEventDateOrderByTimeAsc(Long userId, LocalDate eventDate);
    List<Event> findByEventDateAndVisibilityOrderByStartTimeAsc(LocalDate eventDate, com.vcomm.app.model.EventVisibility visibility);

    List<Event> findByUserIdAndEventDateGreaterThanEqualOrderByEventDateAsc(Long userId, LocalDate eventDate);
    List<Event> findByEventDateGreaterThanEqualAndVisibilityOrderByEventDateAscStartTimeAsc(LocalDate eventDate, com.vcomm.app.model.EventVisibility visibility);

    List<Event> findByUserIdAndEventDateLessThanOrderByEventDateDesc(Long userId, LocalDate eventDate);
}
