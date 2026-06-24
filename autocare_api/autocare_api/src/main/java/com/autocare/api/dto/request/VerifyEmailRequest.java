package com.autocare.api.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VerifyEmailRequest {

    @NotBlank(message = "Email không được để trống")
    @Pattern(
            regexp = "^[A-Za-z0-9._%+-]+@gmail\\.com$",
            message = "Email phải đúng định dạng Gmail, ví dụ: example@gmail.com"
    )
    private String email;

    @NotBlank(message = "Mã xác thực không được để trống")
    @Pattern(
            regexp = "^[0-9]{6}$",
            message = "Mã xác thực phải gồm đúng 6 số"
    )
    private String verificationCode;
}