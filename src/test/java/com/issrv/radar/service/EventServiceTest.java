package com.issrv.radar.service;

import com.issrv.radar.dto.EventDto;
import com.issrv.radar.entity.Event;
import com.issrv.radar.repository.EventImageRepository;
import com.issrv.radar.repository.EventRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import org.mockito.ArgumentCaptor;

class EventServiceTest {
    private EventRepository events;
    private EventImageRepository images;
    private EventService service;

    @BeforeEach
    void setUp() {
        events = mock(EventRepository.class);
        images = mock(EventImageRepository.class);
        service = new EventService(events, images);
    }

    @Test
    void listUsesInclusiveDateRangeAndReturnsEndTime() {
        LocalDateTime from = LocalDateTime.of(2026, 11, 10, 0, 0);
        LocalDateTime to = LocalDateTime.of(2026, 11, 21, 0, 0);
        LocalDateTime end = LocalDateTime.of(2026, 11, 20, 23, 59);
        Event event = event(1, end);
        when(events.findUpcoming(eq(from), eq(to), anyBoolean(), anyList(), anyLong(), isNull(), isNull()))
                .thenReturn(List.of(event));

        List<EventDto> result = service.list(null, null, 5, null, null,
                LocalDate.of(2026, 11, 10), LocalDate.of(2026, 11, 20), null, 50);

        assertEquals(end, result.get(0).endTime());
        verify(events).findUpcoming(eq(from), eq(to), eq(true), anyList(), eq(0L), isNull(), isNull());
    }

    @Test
    void nearbyUsesSameDateRangeAndReturnsNullEndTime() {
        LocalDateTime from = LocalDateTime.of(2026, 11, 10, 0, 0);
        LocalDateTime to = LocalDateTime.of(2026, 11, 21, 0, 0);
        when(events.findNearbyFiltered(eq(from), eq(to), anyDouble(), anyDouble(), anyDouble(), anyDouble(),
                anyDouble(), anyDouble(), anyDouble(), anyBoolean(), anyList(), anyLong(), isNull(), isNull()))
                .thenReturn(List.of(event(2, null)));

        List<EventDto> result = service.list(-74.6589, 40.3478, 5, null, null,
                LocalDate.of(2026, 11, 10), LocalDate.of(2026, 11, 20), null, 50);

        assertNull(result.get(0).endTime());
        verify(events).findNearbyFiltered(eq(from), eq(to), anyDouble(), anyDouble(), anyDouble(), anyDouble(),
                anyDouble(), anyDouble(), anyDouble(), eq(true), anyList(), eq(0L), isNull(), isNull());
    }

    @Test
    void detailReturnsEndTime() {
        LocalDateTime end = LocalDateTime.of(2026, 11, 11, 12, 0);
        when(events.findById(1)).thenReturn(Optional.of(event(1, end)));

        assertEquals(end, service.get(1).endTime());
    }

    @Test
    void missingStartDateUsesCurrentNewYorkTime() {
        LocalDateTime before = LocalDateTime.now(ZoneId.of("America/New_York"));
        service.list(null, null, 5, null, null, null, LocalDate.of(2026, 11, 20), null, 50);
        LocalDateTime after = LocalDateTime.now(ZoneId.of("America/New_York"));

        ArgumentCaptor<LocalDateTime> from = ArgumentCaptor.forClass(LocalDateTime.class);
        verify(events).findUpcoming(from.capture(), eq(LocalDateTime.of(2026, 11, 21, 0, 0)),
                eq(true), anyList(), eq(0L), isNull(), isNull());
        assertTrue(!from.getValue().isBefore(before) && !from.getValue().isAfter(after));
    }

    @Test
    void missingEndDateUsesExistingUpperBound() {
        service.list(null, null, 5, null, null, LocalDate.of(2026, 11, 10), null, null, 50);

        verify(events).findUpcoming(eq(LocalDateTime.of(2026, 11, 10, 0, 0)),
                eq(LocalDateTime.of(9999, 1, 1, 0, 0)), eq(true), anyList(), eq(0L), isNull(), isNull());
    }

    private Event event(int id, LocalDateTime end) {
        Event event = new Event();
        event.setId(id);
        event.setStartTime(LocalDateTime.of(2026, 11, 10, 10, 0));
        event.setEndTime(end);
        return event;
    }
}
