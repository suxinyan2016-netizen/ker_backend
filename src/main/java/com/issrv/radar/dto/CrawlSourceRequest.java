package com.issrv.radar.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Pattern;

import java.time.LocalDateTime;

public record CrawlSourceRequest(
        @NotBlank String sourceName,
        @NotBlank String targetUrl,
        @NotBlank String regionName,
        @DecimalMin("-180.0") @DecimalMax("180.0") Double longitude,
        @DecimalMin("-90.0") @DecimalMax("90.0") Double latitude,
        @Pattern(regexp = "Indoor|Outdoor|Unknown") String defaultIndoorOutdoor,
        String countyName,
        @Pattern(regexp = "Library|Farm|Township|Park|Commercial|Other") String sourceType,
        String pageType,
        Integer maxPages,
        String nextSelector,
        Boolean active,
        LocalDateTime lastCrawledAt) {
}
