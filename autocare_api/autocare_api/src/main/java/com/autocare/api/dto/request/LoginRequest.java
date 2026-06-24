package com.autocare.api.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginRequest {

        @NotBlank(message = "Email hoặc số điện thoại không được để trống")
        @Pattern(
                regexp = "^([A-Za-z0-9._%+-]+@gmail\\.com|[0-9]{10})$",
                message = "Email phải là Gmail hoặc số điện thoại phải gồm đúng 10 số"
        )
        private String emailOrPhone;

        @NotBlank(message = "Mật khẩu không được để trống")
        @Size(min = 6, message = "Mật khẩu phải có tối thiểu 6 ký tự")
        private String password;
}