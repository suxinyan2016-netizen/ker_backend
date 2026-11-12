package com.issrv.radar.push;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Component;

import java.util.Collection;

// 占位实现：仅打日志。接入 Firebase / Cloudflare 等推送时，提供另一个 PushSender Bean 即可替换
@Component
@ConditionalOnMissingBean(value = PushSender.class, ignored = LogPushSender.class)
public class LogPushSender implements PushSender {

    private static final Logger log = LoggerFactory.getLogger(LogPushSender.class);

    @Override
    public void send(Collection<String> deviceTokens, String title, String body) {
        log.info("PUSH to {} devices: [{}] {}", deviceTokens.size(), title, body);
    }
}