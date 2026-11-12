package com.issrv.radar.controller;

import com.issrv.radar.dto.CrawlSourceDto;
import com.issrv.radar.dto.CrawlSourceRequest;
import com.issrv.radar.entity.CrawlSource;
import com.issrv.radar.repository.CrawlSourceRepository;
import com.issrv.radar.util.GeometryUtils;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/crawl-sources")
public class CrawlSourceController {
    private final CrawlSourceRepository repository;

    public CrawlSourceController(CrawlSourceRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<CrawlSourceDto> list() {
        return repository.findAll().stream().map(CrawlSourceDto::from).toList();
    }

    @GetMapping("/{id}")
    public CrawlSourceDto get(@PathVariable Integer id) {
        return CrawlSourceDto.from(find(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CrawlSourceDto create(@Valid @RequestBody CrawlSourceRequest request) {
        return CrawlSourceDto.from(repository.save(apply(new CrawlSource(), request)));
    }

    @PutMapping("/{id}")
    public CrawlSourceDto update(@PathVariable Integer id, @Valid @RequestBody CrawlSourceRequest request) {
        return CrawlSourceDto.from(repository.save(apply(find(id), request)));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Integer id) {
        repository.delete(find(id));
    }

    private CrawlSource find(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Crawl source not found"));
    }

    private CrawlSource apply(CrawlSource source, CrawlSourceRequest request) {
        if ((request.longitude() == null) != (request.latitude() == null)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "longitude and latitude must be provided together");
        }
        source.setSourceName(request.sourceName());
        source.setTargetUrl(request.targetUrl());
        source.setRegionName(request.regionName());
        source.setLocationGeo(request.longitude() == null ? null :
                GeometryUtils.createPoint(request.longitude(), request.latitude()));
        source.setDefaultIndoorOutdoor(request.defaultIndoorOutdoor() == null ? "Unknown" : request.defaultIndoorOutdoor());
        source.setCountyName(request.countyName());
        source.setSourceType(request.sourceType());
        source.setPageType(request.pageType());
        source.setMaxPages(request.maxPages());
        source.setNextSelector(request.nextSelector());
        source.setActive(request.active() == null ? true : request.active());
        source.setLastCrawledAt(request.lastCrawledAt());
        return source;
    }
}
