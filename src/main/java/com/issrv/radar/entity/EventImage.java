package com.issrv.radar.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "event_image")
public class EventImage {
    @Id
    @Column(name = "event_id")
    private Integer eventId;

    @Column(name = "image_id")
    private Long imageId;
}
