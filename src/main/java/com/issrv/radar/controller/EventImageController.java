package com.issrv.radar.controller;

import com.issrv.radar.entity.EventImage;
import com.issrv.radar.repository.EventImageRepository;
import com.issrv.radar.repository.EventRepository;
import com.issrv.radar.repository.ImageRepository;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/event-images")
public class EventImageController {
    private final EventImageRepository repository;
    private final EventRepository eventRepository;
    private final ImageRepository imageRepository;

    public EventImageController(EventImageRepository repository, EventRepository eventRepository,
                                ImageRepository imageRepository) {
        this.repository = repository;
        this.eventRepository = eventRepository;
        this.imageRepository = imageRepository;
    }

    @GetMapping("/{eventId}")
    public EventImage get(@PathVariable Integer eventId) {
        return find(eventId);
    }

    @PutMapping("/{eventId}")
    public EventImage assign(@PathVariable Integer eventId, @RequestBody EventImageInput input) {
        if (!eventRepository.existsById(eventId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found");
        }
        if (input.imageId() != null && !imageRepository.existsById(input.imageId())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Image not found");
        }
        EventImage association = repository.findById(eventId).orElseGet(EventImage::new);
        association.setEventId(eventId);
        association.setImageId(input.imageId());
        return repository.save(association);
    }

    @DeleteMapping("/{eventId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Integer eventId) {
        repository.delete(find(eventId));
    }

    private EventImage find(Integer eventId) {
        return repository.findById(eventId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Event image not found"));
    }

    public record EventImageInput(Long imageId) {
    }
}
