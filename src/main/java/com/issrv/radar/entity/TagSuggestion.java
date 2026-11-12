package com.issrv.radar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "tag_suggestions")
public class TagSuggestion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "suggested_tag_name", nullable = false, length = 100)
    private String suggestedTagName;

    @Column(name = "tag_category", nullable = false, length = 50)
    private String tagCategory;

    @Column(name = "is_new_tag", nullable = false)
    private Boolean newTag = true;

    @Column(nullable = false, length = 100)
    private String keyword;

    @Column(name = "match_type", nullable = false, length = 20)
    private String matchType = "contains";

    @Column(name = "target_field", nullable = false, length = 20)
    private String targetField = "title";

    @Column(name = "source_event_id")
    private Integer sourceEventId;

    @Column(columnDefinition = "TEXT")
    private String evidence;

    @Column(precision = 3, scale = 2)
    private BigDecimal confidence;

    @Column(nullable = false)
    private String status = "pending";

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "reviewed_at")
    private LocalDateTime reviewedAt;
}
