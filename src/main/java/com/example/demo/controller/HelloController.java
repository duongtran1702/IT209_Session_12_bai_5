package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HelloController {

    @GetMapping("/")
    public Map<String, Object> index() {
        return Map.of(
            "status", "UP",
            "message", "Spring Boot Gradle CI/CD Pipeline with GitHub Actions",
            "student", "Trần Trí Dương",
            "studentId", "duongtran1702",
            "session", "Session 11 - Bài 5"
        );
    }

    @GetMapping("/api/health")
    public Map<String, String> health() {
        return Map.of("status", "healthy");
    }
}
