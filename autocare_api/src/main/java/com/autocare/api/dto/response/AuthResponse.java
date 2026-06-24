package com.autocare.api.dto.response;

public record AuthResponse(
        String token,
        UserResponse user
) {
}