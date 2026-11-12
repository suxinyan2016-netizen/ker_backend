package com.issrv.radar.repository;

import com.issrv.radar.entity.TagSuggestion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TagSuggestionRepository extends JpaRepository<TagSuggestion, Integer> {
    List<TagSuggestion> findByStatusOrderByCreatedAtAsc(String status);
}
