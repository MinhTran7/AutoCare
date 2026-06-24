package com.autocare.api.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    public void sendVerificationCode(String toEmail, String verificationCode) {
        SimpleMailMessage message = new SimpleMailMessage();

        message.setFrom(fromEmail);
        message.setTo(toEmail);
        message.setSubject("Mã xác thực tài khoản PRM AutoCare");
        message.setText(
                "Xin chào,\n\n" +
                        "Mã xác thực tài khoản PRM AutoCare của bạn là: " + verificationCode + "\n\n" +
                        "Mã này có hiệu lực trong 10 phút.\n\n" +
                        "Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email.\n\n" +
                        "Trân trọng,\n" +
                        "PRM AutoCare"
        );

        mailSender.send(message);
    }
}