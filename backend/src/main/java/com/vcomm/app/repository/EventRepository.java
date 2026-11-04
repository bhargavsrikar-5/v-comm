package com.vcomm.app.repository;

import com.vcomm.app.model.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {

    List<Event> findByUserIdOrderByEventDateAsc(Long userId);

    List<Event> findByUserIdAndEventDateOrderByTimeAsc(Long userId, LocalDate eventDate);

    List<Event> findByUserIdAndEventDateGreaterThanEqualOrderByEventDateAsc(Long userId, LocalDate eventDate);

    List<Event> findByUserIdAndEventDateLessThanOrderByEventDateDesc(Long userId, LocalDate eventDate);
}
