package com.autocare.api.controller;

import com.autocare.api.dto.request.ChangePasswordRequest;
import com.autocare.api.dto.request.UpdateProfileRequest;
import com.autocare.api.dto.response.UserResponse;
import com.autocare.api.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public UserResponse getMe(Authentication authentication) {
        return userService.getMe(authentication);
    }

    @PutMapping("/me")
    public UserResponse updateMe(
            Authentication authentication,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        return userService.updateMe(authentication, request);
    }

    @PutMapping("/me/password")
    public Map<String, String> changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request
    ) {
        userService.changePassword(authentication, request);

        return Map.of("message", "Đổi mật khẩu thành công");
    }
}