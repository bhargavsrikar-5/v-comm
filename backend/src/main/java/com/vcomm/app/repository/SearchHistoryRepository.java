package com.vcomm.app.repository;

import com.vcomm.app.model.SearchHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface SearchHistoryRepository extends JpaRepository<SearchHistory, Long> {

    List<SearchHistory> findTop15ByUserIdOrderBySearchedAtDesc(Long userId);

    @Modifying
    @Transactional
    @Query("DELETE FROM SearchHistory sh WHERE sh.userId = :userId AND sh.searchedUserId = :searchedUserId")
    void deleteByUserIdAndSearchedUserId(@Param("userId") Long userId, @Param("searchedUserId") Long searchedUserId);

    @Modifying
    @Transactional
    @Query("DELETE FROM SearchHistory sh WHERE sh.userId = :userId")
    void deleteAllByUserId(@Param("userId") Long userId);
}
