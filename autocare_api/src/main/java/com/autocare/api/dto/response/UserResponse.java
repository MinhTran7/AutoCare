package com.autocare.api.dto.response;

import com.autocare.api.entity.User;

import java.time.LocalDateTime;

public record UserResponse(
        Integer id,
        String fullName,
        String email,
        String phone,
        String address,
        String avatarUrl,
        String role,
        String status,
        String lockedReason,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static UserResponse fromEntity(User user) {
        return new UserResponse(
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getAddress(),
                user.getAvatarUrl(),
                user.getRole(),
                user.getStatus(),
                user.getLockedReason(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}