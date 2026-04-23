package com.example.auth.controller;

import com.example.auth.entity.User;
import com.example.auth.service.AuthService;
import com.example.auth.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    private final JwtUtil jwtUtil;

    @PostMapping("/register")
    public ResponseEntity<User> register(@RequestBody User user) {
        return ResponseEntity.ok(authService.register(user));
    }

    @PostMapping("/token")
    public ResponseEntity<String> getToken(@RequestBody User user) {
        // Simple token generation for testing
        // In real app, verify password first!
        return ResponseEntity.ok(jwtUtil.generateToken(user.getEmail()));
    }
}
