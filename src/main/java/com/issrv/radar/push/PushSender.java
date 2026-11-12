package com.issrv.radar.push;

import java.util.Collection;

public interface PushSender {
    void send(Collection<String> deviceTokens, String title, String body);
}