package com.example.auth.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {
    @Value("${server.port}")
    private String serverPort;

    @GetMapping("/")
    public String home() {
        return "queue-auth-service is running on port " + serverPort + "...";
    }
}
