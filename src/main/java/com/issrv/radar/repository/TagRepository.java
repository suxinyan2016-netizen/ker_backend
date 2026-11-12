package com.issrv.radar.repository;

import com.issrv.radar.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TagRepository extends JpaRepository<Tag, Long> {
    Optional<Tag> findByTagNameIgnoreCaseAndTagCategoryIgnoreCase(String tagName, String tagCategory);
}
