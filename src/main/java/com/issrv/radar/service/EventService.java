package com.issrv.radar.service;

import com.issrv.radar.dto.EventDto;
import com.issrv.radar.entity.Event;
import com.issrv.radar.repository.EventRepository;
import com.issrv.radar.repository.EventImageRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;

@Service
public class EventService {

    private static final double METERS_PER_MILE = 1609.34;

    private final EventRepository repository;
    private final EventImageRepository eventImageRepository;

    public EventService(EventRepository repository, EventImageRepository eventImageRepository) {
        this.repository = repository;
        this.eventImageRepository = eventImageRepository;
    }

    @Transactional(readOnly = true)
    public List<EventDto> list(Double lng, Double lat, double miles,
                               Event.IndoorOutdoor indoorOutdoor, List<Long> tagIds, LocalDate startDate, LocalDate endDate, String title, int limit) {
        // 标题关键字：忽略大小写（库排序规则 ci），转义 LIKE 通配符
        String titleKeyword = title == null || title.isBlank() ? null
                : title.trim().replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
        LocalDateTime now = LocalDateTime.now(ZoneId.of("America/New_York"));
        if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "startdate must not be after enddate");
        }
        // 指定 startdate 时从当天 0 点起（可含过去）；enddate 含当天，故取次日 0 点作开区间上界
        LocalDateTime from = startDate != null ? startDate.atStartOfDay() : now;
        LocalDateTime to = endDate != null ? endDate.plusDays(1).atStartOfDay() : LocalDateTime.of(9999, 1, 1, 0, 0);
        boolean noTags = tagIds == null || tagIds.isEmpty();
        // 空集合会让 IN () 语法出错，用占位值代替，实际由 noTags 短路
        List<Long> ids = noTags ? List.of(-1L) : tagIds.stream().distinct().toList();
        // 不同分类间 AND、同一分类内 OR：活动在每个所选分类下至少命中一个所选标签
        long categoryCount = noTags ? 0 : repository.countTagCategories(ids);
        if (!noTags && categoryCount == 0) {
            return List.of();
        }
        List<Event> events;
        if (lng != null && lat != null) {
            double latDelta = miles / 69.0;
            double lngDelta = miles / (69.0 * Math.cos(Math.toRadians(lat)));
            events = repository.findNearbyFiltered(from, to, lng, lat,
                    lng - lngDelta, lat - latDelta, lng + lngDelta, lat + latDelta,
                    miles * METERS_PER_MILE, noTags, ids, categoryCount, indoorOutdoor == null ? null : indoorOutdoor.name(), titleKeyword);
        } else {
            events = repository.findUpcoming(from, to, noTags, ids, categoryCount, indoorOutdoor == null ? null : indoorOutdoor.name(), titleKeyword);
        }
        List<Event> limited = events.stream()
                .limit(limit)
                .toList();
        List<Integer> eventIds = limited.stream().map(Event::getId).toList();
        Map<Integer, String> imageUrls = eventIds.isEmpty() ? Map.of() :
                eventImageRepository.findImageUrls(eventIds).stream()
                        .collect(Collectors.toMap(EventImageRepository.EventImageView::getEventId,
                                EventImageRepository.EventImageView::getImageUrl));
        Map<Integer, String> tagNames = tagNamesByEvent(eventIds);
        return limited.stream().map(e -> EventDto.from(e, imageUrls.get(e.getId()), tagNames.get(e.getId()))).toList();
    }

    @Transactional(readOnly = true)
    public EventDto get(Integer id) {
        Event event = repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found"));
        String imageUrl = eventImageRepository.findImageUrlByEventId(id).orElse(null);
        return EventDto.from(event, imageUrl, tagNamesByEvent(List.of(id)).get(id));
    }

    // 同一活动的全部标签名按 tags.id 顺序以逗号拼接；无标签时为 null
    private Map<Integer, String> tagNamesByEvent(List<Integer> eventIds) {
        if (eventIds.isEmpty()) {
            return Map.of();
        }
        return repository.findTagNames(eventIds).stream()
                .collect(Collectors.groupingBy(EventRepository.EventTagView::getEventId, LinkedHashMap::new,
                        Collectors.mapping(EventRepository.EventTagView::getTagName, Collectors.joining(","))));
    }
}