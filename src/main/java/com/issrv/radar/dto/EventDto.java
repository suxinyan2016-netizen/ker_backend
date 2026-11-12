package com.issrv.radar.dto;

import com.issrv.radar.entity.Event;

import java.time.LocalDateTime;

public record EventDto(
        Integer id,
        Integer sourceId,
        String title,
        LocalDateTime startTime,
        LocalDateTime endTime,
        String locationName,
        Double longitude,
        Double latitude,
        Event.IndoorOutdoor indoorOutdoor,
        String bookingUrl,
        String parentTips,
        String imageUrl,
        String tagNames) {

    public static EventDto from(Event e, String imageUrl, String tagNames) {
        return new EventDto(e.getId(), e.getSourceId(), e.getTitle(), e.getStartTime(), e.getEndTime(), e.getLocationName(),
                e.getLocationGeo() == null ? null : e.getLocationGeo().getX(),
                e.getLocationGeo() == null ? null : e.getLocationGeo().getY(),
                e.getIndoorOutdoor(), e.getBookingUrl(), e.getParentTips(), imageUrl, tagNames);
    }
}