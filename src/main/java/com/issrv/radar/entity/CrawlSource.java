package com.issrv.radar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.locationtech.jts.geom.Point;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "crawl_sources")
public class CrawlSource {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "source_name", nullable = false, length = 100)
    private String sourceName;

    @Column(name = "target_url", nullable = false, columnDefinition = "TEXT")
    private String targetUrl;

    @Column(name = "region_name", nullable = false, length = 100)
    private String regionName;

    @Column(name = "location_geo", columnDefinition = "POINT")
    private Point locationGeo;

    @Column(name = "default_indoor_outdoor", nullable = false)
    private String defaultIndoorOutdoor = "Unknown";

    @Column(name = "county_name", length = 100)
    private String countyName;

    @Column(name = "source_type", length = 50)
    private String sourceType;

    @Column(name = "page_type", length = 50)
    private String pageType;

    @Column(name = "max_pages")
    private Integer maxPages;

    @Column(name = "next_selector", length = 255)
    private String nextSelector;

    @Column(name = "is_active")
    private Boolean active;

    @Column(name = "last_crawled_at")
    private LocalDateTime lastCrawledAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;
}
