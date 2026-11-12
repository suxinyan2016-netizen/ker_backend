package com.issrv.radar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "exclude_rules")
public class ExcludeRule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 500)
    private String keyword;

    @Column(name = "match_type", nullable = false)
    private String matchType = "regex";

    @Column(name = "target_field", nullable = false)
    private String targetField = "title";

    @Column(length = 255)
    private String description;

    @Column(name = "is_active", nullable = false)
    private Boolean active = true;
}
