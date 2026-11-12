package com.issrv.radar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.locationtech.jts.geom.Point;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "events")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "source_id")
    private Integer sourceId;

    @Column(nullable = false)
    private String title;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "location_name")
    private String locationName;

    // X=经度, Y=纬度；Hibernate Spatial 自动与 MySQL POINT 互转
    @Column(name = "location_geo", columnDefinition = "POINT")
    private Point locationGeo;

    @Enumerated(EnumType.STRING)
    @Column(name = "indoor_outdoor")
    private IndoorOutdoor indoorOutdoor;

    @Column(name = "booking_url", columnDefinition = "TEXT")
    private String bookingUrl;

    @Column(name = "parent_tips", columnDefinition = "TEXT")
    private String parentTips;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    public enum IndoorOutdoor { Indoor, Outdoor, Unknown }
}