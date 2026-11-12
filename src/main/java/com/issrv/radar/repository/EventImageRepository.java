package com.issrv.radar.repository;

import com.issrv.radar.entity.EventImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface EventImageRepository extends JpaRepository<EventImage, Integer> {
    @Query(value = """
            SELECT ei.event_id AS eventId, i.image_url AS imageUrl
            FROM event_image ei JOIN images i ON i.id = ei.image_id
            WHERE ei.event_id IN (:eventIds)
            """, nativeQuery = true)
    List<EventImageView> findImageUrls(@Param("eventIds") List<Integer> eventIds);

    @Query(value = """
            SELECT i.image_url FROM event_image ei JOIN images i ON i.id = ei.image_id
            WHERE ei.event_id = :eventId
            """, nativeQuery = true)
    Optional<String> findImageUrlByEventId(@Param("eventId") Integer eventId);

    interface EventImageView {
        Integer getEventId();
        String getImageUrl();
    }
}
