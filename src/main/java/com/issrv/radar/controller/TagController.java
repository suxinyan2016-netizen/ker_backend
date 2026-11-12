package com.issrv.radar.controller;

import com.issrv.radar.entity.Tag;
import com.issrv.radar.repository.TagRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/tags")
public class TagController {
    private final TagRepository repository;

    public TagController(TagRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<Tag> list(@RequestParam(required = false) String category) {
        return repository.findAll().stream()
                .filter(tag -> category == null || category.equalsIgnoreCase(tag.getTagCategory()))
                .toList();
    }

    @GetMapping("/{id}")
    public Tag get(@PathVariable Long id) {
        return find(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Tag create(@Valid @RequestBody TagRequest request) {
        Tag tag = new Tag();
        apply(tag, request);
        return repository.save(tag);
    }

    @PutMapping("/{id}")
    public Tag update(@PathVariable Long id, @Valid @RequestBody TagRequest request) {
        Tag tag = find(id);
        apply(tag, request);
        return repository.save(tag);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        repository.delete(find(id));
    }

    private Tag find(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Tag not found"));
    }

    private void apply(Tag tag, TagRequest request) {
        tag.setTagName(request.tagName());
        tag.setTagCategory(request.tagCategory());
        tag.setDescription(request.description());
        tag.setActive(request.active() == null ? true : request.active());
    }

    public record TagRequest(@NotBlank @Size(max = 100) String tagName,
                             @NotBlank @Size(max = 50) String tagCategory,
                             @Size(max = 255) String description,
                             Boolean active) {
    }
}
