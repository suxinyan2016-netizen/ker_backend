package com.issrv.radar.dto;

import com.issrv.radar.entity.CrawlSource;

import java.time.LocalDateTime;

public record CrawlSourceDto(
        Integer id,
        String sourceName,
        String targetUrl,
        String regionName,
        Double longitude,
        Double latitude,
        String defaultIndoorOutdoor,
        String countyName,
        String sourceType,
        String pageType,
        Integer maxPages,
        String nextSelector,
        Boolean active,
        LocalDateTime lastCrawledAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt) {
    public static CrawlSourceDto from(CrawlSource source) {
        return new CrawlSourceDto(source.getId(), source.getSourceName(), source.getTargetUrl(),
                source.getRegionName(),
                source.getLocationGeo() == null ? null : source.getLocationGeo().getX(),
                source.getLocationGeo() == null ? null : source.getLocationGeo().getY(),
                source.getDefaultIndoorOutdoor(), source.getCountyName(), source.getSourceType(),
                source.getPageType(), source.getMaxPages(), source.getNextSelector(), source.getActive(),
                source.getLastCrawledAt(), source.getCreatedAt(), source.getUpdatedAt());
    }
}
