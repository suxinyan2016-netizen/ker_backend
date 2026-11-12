package com.issrv.radar.controller;

import com.issrv.radar.entity.Tag;
import com.issrv.radar.entity.TagSuggestion;
import com.issrv.radar.repository.TagRepository;
import com.issrv.radar.repository.TagSuggestionRepository;
import jakarta.transaction.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/tag-suggestions")
public class TagSuggestionController {
    private final TagSuggestionRepository suggestionRepository;
    private final TagRepository tagRepository;

    public TagSuggestionController(TagSuggestionRepository suggestionRepository, TagRepository tagRepository) {
        this.suggestionRepository = suggestionRepository;
        this.tagRepository = tagRepository;
    }

    @GetMapping
    public List<TagSuggestion> list(@RequestParam(defaultValue = "pending") String status) {
        return suggestionRepository.findByStatusOrderByCreatedAtAsc(status);
    }

    @GetMapping("/{id}")
    public TagSuggestion get(@PathVariable Integer id) {
        return find(id);
    }

    @PostMapping("/{id}/approve")
    @Transactional
    public TagSuggestion approve(@PathVariable Integer id) {
        TagSuggestion suggestion = pending(id);
        tagRepository.findByTagNameIgnoreCaseAndTagCategoryIgnoreCase(
                        suggestion.getSuggestedTagName(), suggestion.getTagCategory())
                .orElseGet(() -> {
                    Tag newTag = new Tag();
                    newTag.setTagName(suggestion.getSuggestedTagName());
                    newTag.setTagCategory(suggestion.getTagCategory());
                    newTag.setActive(true);
                    return tagRepository.save(newTag);
                });
        suggestion.setStatus("approved");
        suggestion.setReviewedAt(LocalDateTime.now());
        return suggestionRepository.save(suggestion);
    }

    @PostMapping("/{id}/reject")
    @Transactional
    public TagSuggestion reject(@PathVariable Integer id) {
        TagSuggestion suggestion = pending(id);
        suggestion.setStatus("rejected");
        suggestion.setReviewedAt(LocalDateTime.now());
        return suggestionRepository.save(suggestion);
    }

    private TagSuggestion pending(Integer id) {
        TagSuggestion suggestion = find(id);
        if (!"pending".equals(suggestion.getStatus())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Suggestion has already been reviewed");
        }
        return suggestion;
    }

    private TagSuggestion find(Integer id) {
        return suggestionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Tag suggestion not found"));
    }
}
