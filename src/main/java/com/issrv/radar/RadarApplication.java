package com.issrv.radar;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class RadarApplication {
    public static void main(String[] args) {
        SpringApplication.run(RadarApplication.class, args);
    }
}