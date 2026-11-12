package com.issrv.radar.controller;

import com.issrv.radar.entity.ExcludeRule;
import com.issrv.radar.repository.ExcludeRuleRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/exclude-rules")
public class ExcludeRuleController {
    private final ExcludeRuleRepository repository;

    public ExcludeRuleController(ExcludeRuleRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<ExcludeRule> list() {
        return repository.findAll();
    }

    @GetMapping("/{id}")
    public ExcludeRule get(@PathVariable Integer id) {
        return find(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ExcludeRule create(@Valid @RequestBody RuleRequest request) {
        ExcludeRule rule = new ExcludeRule();
        apply(rule, request);
        return repository.save(rule);
    }

    @PutMapping("/{id}")
    public ExcludeRule update(@PathVariable Integer id, @Valid @RequestBody RuleRequest request) {
        ExcludeRule rule = find(id);
        apply(rule, request);
        return repository.save(rule);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Integer id) {
        repository.delete(find(id));
    }

    private ExcludeRule find(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Exclude rule not found"));
    }

    private void apply(ExcludeRule rule, RuleRequest request) {
        rule.setKeyword(request.keyword());
        rule.setMatchType(request.matchType() == null ? "regex" : request.matchType());
        rule.setTargetField(request.targetField() == null ? "title" : request.targetField());
        rule.setDescription(request.description());
        rule.setActive(request.active() == null ? true : request.active());
    }

    public record RuleRequest(@NotBlank @Size(max = 500) String keyword,
                              @Pattern(regexp = "contains|exact|regex") String matchType,
                              @Pattern(regexp = "title|all") String targetField,
                              @Size(max = 255) String description,
                              Boolean active) {
    }
}
