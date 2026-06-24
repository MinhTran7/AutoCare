package com.autocare.api.controller;

import com.autocare.api.dto.request.LoginRequest;
import com.autocare.api.dto.request.RegisterRequest;
import com.autocare.api.dto.request.VerifyEmailRequest;
import com.autocare.api.dto.response.AuthResponse;
import com.autocare.api.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.autocare.api.dto.request.ResendVerificationCodeRequest;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/verify-email")
    public ResponseEntity<AuthResponse> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
        return ResponseEntity.ok(authService.verifyEmail(request));
    }

    @PostMapping("/resend-verification-code")
    public ResponseEntity<AuthResponse> resendVerificationCode(
            @Valid @RequestBody ResendVerificationCodeRequest request
    ) {
        return ResponseEntity.ok(authService.resendVerificationCode(request));
    }
}