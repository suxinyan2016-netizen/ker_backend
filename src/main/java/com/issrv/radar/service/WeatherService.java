package com.issrv.radar.service;

import com.fasterxml.jackson.databind.JsonNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;

@Service
public class WeatherService {

    private static final Logger log = LoggerFactory.getLogger(WeatherService.class);
    private static final ZoneId NY = ZoneId.of("America/New_York");
    private static final int RAIN_PROBABILITY_THRESHOLD = 50;

    // Princeton 中心坐标；Open-Meteo 免费、无需 API Key
    private final RestClient client = RestClient.create("https://api.open-meteo.com");

    /** 本周末（周六或周日）降水概率是否达到阈值；查询失败时返回 false，避免误报 */
    public boolean isWeekendRainy() {
        try {
            LocalDate today = LocalDate.now(NY);
            LocalDate sat = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SATURDAY));
            LocalDate sun = sat.plusDays(1);
            JsonNode daily = client.get()
                    .uri("/v1/forecast?latitude=40.3573&longitude=-74.6672"
                            + "&daily=precipitation_probability_max&timezone=America/New_York&forecast_days=7")
                    .retrieve().body(JsonNode.class).path("daily");
            JsonNode days = daily.path("time");
            JsonNode probs = daily.path("precipitation_probability_max");
            for (int i = 0; i < days.size(); i++) {
                LocalDate d = LocalDate.parse(days.get(i).asText());
                if ((d.equals(sat) || d.equals(sun)) && probs.get(i).asInt(0) >= RAIN_PROBABILITY_THRESHOLD) {
                    return true;
                }
            }
        } catch (Exception e) {
            log.warn("Weather lookup failed, skipping rain alert: {}", e.toString());
        }
        return false;
    }
}