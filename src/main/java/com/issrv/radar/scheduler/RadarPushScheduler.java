package com.issrv.radar.scheduler;

import com.issrv.radar.push.PushSender;
import com.issrv.radar.repository.AnonymousProfileRepository;
import com.issrv.radar.service.WeatherService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class RadarPushScheduler {

    private static final Logger log = LoggerFactory.getLogger(RadarPushScheduler.class);
    private static final String ZONE = "America/New_York";

    private final AnonymousProfileRepository subscriptions;
    private final WeatherService weather;
    private final PushSender pushSender;

    public RadarPushScheduler(AnonymousProfileRepository subscriptions,
                              WeatherService weather, PushSender pushSender) {
        this.subscriptions = subscriptions;
        this.weather = weather;
        this.pushSender = pushSender;
    }

    // 周四 19:00：周末有雨时，提醒关注户外活动的用户
    @Scheduled(cron = "0 0 19 * * THU", zone = ZONE)
    public void pushThursdayWeatherRadar() {
        if (!weather.isWeekendRainy()) {
            log.info("Thursday radar: no rain expected this weekend, nothing sent");
            return;
        }
        List<String> tokens = subscriptions.findTokensByTag("outdoor");
        send(tokens, "雷达提醒",
                "本周末普林斯顿有雨，您关注的户外活动可能变更，请留意最新室内行程！");
    }

    // 周五 19:00：周末活动抢位提醒
    @Scheduled(cron = "0 0 19 * * FRI", zone = ZONE)
    public void pushFridayBookingReminder() {
        send(subscriptions.findAllTokens(), "抢位提醒",
                "本周末的亲子活动即将开始，热门场次名额有限，快来查看并预约！");
    }

    private void send(List<String> tokens, String title, String body) {
        if (tokens.isEmpty()) {
            log.info("[{}] no subscribers", title);
            return;
        }
        pushSender.send(tokens, title, body);
    }
}