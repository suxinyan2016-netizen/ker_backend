package com.issrv.radar.controller;

import com.issrv.radar.entity.Image;
import com.issrv.radar.repository.ImageRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/images")
public class ImageController {
    private final ImageRepository repository;

    public ImageController(ImageRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<Image> list() {
        return repository.findAll();
    }

    @GetMapping("/{id}")
    public Image get(@PathVariable Long id) {
        return find(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Image create(@Valid @RequestBody ImageRequest request) {
        Image image = new Image();
        apply(image, request);
        return repository.save(image);
    }

    @PutMapping("/{id}")
    public Image update(@PathVariable Long id, @Valid @RequestBody ImageRequest request) {
        Image image = find(id);
        apply(image, request);
        return repository.save(image);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        repository.delete(find(id));
    }

    private Image find(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Image not found"));
    }

    private void apply(Image image, ImageRequest request) {
        image.setImageUrl(request.imageUrl());
        image.setFileName(request.fileName());
        image.setMimeType(request.mimeType());
        image.setWidth(request.width());
        image.setHeight(request.height());
    }

    public record ImageRequest(@NotBlank @Size(max = 1000) String imageUrl,
                               @Size(max = 255) String fileName,
                               @Size(max = 50) String mimeType,
                               Integer width,
                               Integer height) {
    }
}
