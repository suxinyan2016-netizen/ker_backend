package com.issrv.radar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "anonymous_profile_tags")
public class AnonymousProfileTag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "profile_id", nullable = false)
    private Integer profileId;

    @Column(name = "tag_name", nullable = false, length = 50)
    private String tagName;

    @Column(name = "tag_category", nullable = false, length = 50)
    private String tagCategory;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}
