package com.issrv.radar.repository;

import com.issrv.radar.entity.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

public interface EventRepository extends JpaRepository<Event, Integer> {

    @Query(value = "SELECT COUNT(DISTINCT tag_category) FROM tags WHERE id IN (:tagIds)", nativeQuery = true)
    long countTagCategories(@Param("tagIds") Collection<Long> tagIds);

    @Query(value = """
            SELECT et.event_id AS eventId, t.tag_name AS tagName
            FROM event_tags et JOIN tags t ON t.id = et.tag_id
            WHERE et.event_id IN (:eventIds)
            ORDER BY et.event_id, t.id
            """, nativeQuery = true)
    List<EventTagView> findTagNames(@Param("eventIds") Collection<Integer> eventIds);

    interface EventTagView {
        Integer getEventId();
        String getTagName();
    }

    @Query(value = """
            SELECT e.* FROM events e
            WHERE e.start_time < :to
              AND COALESCE(e.end_time, e.start_time) >= :from
              AND (:noTags = TRUE OR (
                  SELECT COUNT(DISTINCT t.tag_category) FROM event_tags et JOIN tags t ON t.id = et.tag_id
                  WHERE et.event_id = e.id AND et.tag_id IN (:tagIds)
              ) = :tagCategoryCount)
              AND (:indoorOutdoor IS NULL OR e.indoor_outdoor = :indoorOutdoor)
              AND (:title IS NULL OR e.title LIKE CONCAT('%', :title, '%'))
            ORDER BY e.start_time ASC
            """, nativeQuery = true)
    List<Event> findUpcoming(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to,
                             @Param("noTags") boolean noTags, @Param("tagIds") Collection<Long> tagIds,
                             @Param("tagCategoryCount") long tagCategoryCount,
                             @Param("indoorOutdoor") String indoorOutdoor,
                             @Param("title") String title);

    @Query(value = """
            SELECT e.* FROM events e
            WHERE e.start_time < :to
              AND COALESCE(e.end_time, e.start_time) >= :from
              AND MBRContains(ST_MakeEnvelope(POINT(:minLng, :minLat), POINT(:maxLng, :maxLat)), e.location_geo)
              AND ST_Distance_Sphere(e.location_geo, POINT(:lng, :lat)) <= :meters
              AND (:noTags = TRUE OR (
                  SELECT COUNT(DISTINCT t.tag_category) FROM event_tags et JOIN tags t ON t.id = et.tag_id
                  WHERE et.event_id = e.id AND et.tag_id IN (:tagIds)
              ) = :tagCategoryCount)
              AND (:indoorOutdoor IS NULL OR e.indoor_outdoor = :indoorOutdoor)
              AND (:title IS NULL OR e.title LIKE CONCAT('%', :title, '%'))
            ORDER BY e.start_time ASC
            """, nativeQuery = true)
    List<Event> findNearbyFiltered(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to,
                                   @Param("lng") double lng, @Param("lat") double lat,
                                   @Param("minLng") double minLng, @Param("minLat") double minLat,
                                   @Param("maxLng") double maxLng, @Param("maxLat") double maxLat,
                                   @Param("meters") double meters, @Param("noTags") boolean noTags, @Param("tagIds") Collection<Long> tagIds,
                             @Param("tagCategoryCount") long tagCategoryCount,
                                   @Param("indoorOutdoor") String indoorOutdoor,
                             @Param("title") String title);

}