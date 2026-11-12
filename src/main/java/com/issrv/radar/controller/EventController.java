package com.issrv.radar.controller;

import com.issrv.radar.dto.EventDto;
import com.issrv.radar.entity.Event;
import com.issrv.radar.service.EventService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/events")
public class EventController {

    private final EventService service;

    public EventController(EventService service) {
        this.service = service;
    }

    @GetMapping
    public List<EventDto> list(@RequestParam(required = false) Double lng,
                               @RequestParam(required = false) Double lat,
                               @RequestParam(defaultValue = "5") double radius,
                               @RequestParam(required = false) Event.IndoorOutdoor indoor,
                               @RequestParam(name = "tag_id", required = false) List<Long> tagIds,
                               @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startdate,
                               @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate enddate,
                               @RequestParam(required = false) String title,
                               @RequestParam(defaultValue = "50") int limit) {
        return service.list(lng, lat, Math.min(Math.max(radius, 0.1), 50), indoor, tagIds, startdate, enddate, title,
                Math.min(Math.max(limit, 1), 200));
    }

    @GetMapping("/{id}")
    public EventDto get(@PathVariable Integer id) {
        return service.get(id);
    }
}