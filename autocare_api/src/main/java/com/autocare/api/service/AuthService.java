package com.autocare.api.service;

import com.autocare.api.dto.request.LoginRequest;
import com.autocare.api.dto.request.RegisterRequest;
import com.autocare.api.dto.request.ResendVerificationCodeRequest;
import com.autocare.api.dto.request.VerifyEmailRequest;
import com.autocare.api.dto.response.AuthResponse;
import com.autocare.api.dto.response.UserResponse;
import com.autocare.api.entity.User;
import com.autocare.api.repository.UserRepository;
import com.autocare.api.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@RequiredArgsConstructor
@Service
public class AuthService {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        String phone = request.getPhone().trim();

        if (userRepository.existsByEmail(email)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Email đã được sử dụng"
            );
        }

        if (userRepository.existsByPhone(phone)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Số điện thoại đã được sử dụng"
            );
        }

        String verificationCode = generateVerificationCode();

        User user = User.builder()
                .fullName(request.getFullName().trim())
                .email(email)
                .phone(phone)
                .password(passwordEncoder.encode(request.getPassword()))
                .role("CUSTOMER")
                .status("PENDING_VERIFY")
                .emailVerificationCode(verificationCode)
                .emailVerificationExpiresAt(LocalDateTime.now().plusMinutes(10))
                .build();

        User savedUser = userRepository.save(user);

        emailService.sendVerificationCode(email, verificationCode);

        return new AuthResponse(
                "",
                UserResponse.fromEntity(savedUser)
        );
    }

    public AuthResponse login(LoginRequest request) {
        String emailOrPhone = request.getEmailOrPhone().trim().toLowerCase();

        User user = userRepository.findByEmailOrPhone(emailOrPhone, emailOrPhone)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Email/số điện thoại hoặc mật khẩu không đúng"
                ));

        if ("LOCKED".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    user.getLockedReason() == null || user.getLockedReason().isBlank()
                            ? "Tài khoản của bạn đã bị khóa"
                            : "Tài khoản của bạn đã bị khóa: " + user.getLockedReason()
            );
        }

        if ("PENDING_VERIFY".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Tài khoản chưa được xác thực email. Vui lòng kiểm tra email để xác thực tài khoản"
            );
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Email/số điện thoại hoặc mật khẩu không đúng"
            );
        }

        String token = generateTokenForUser(user);

        return new AuthResponse(
                token,
                UserResponse.fromEntity(user)
        );
    }

    @Transactional
    public AuthResponse verifyEmail(VerifyEmailRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        String verificationCode = request.getVerificationCode().trim();

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Không tìm thấy tài khoản với email này"
                ));

        if ("ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Tài khoản này đã được xác thực"
            );
        }

        if (!"PENDING_VERIFY".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Tài khoản không ở trạng thái chờ xác thực"
            );
        }

        if (user.getEmailVerificationCode() == null ||
                user.getEmailVerificationCode().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Tài khoản chưa có mã xác thực. Vui lòng yêu cầu gửi lại mã"
            );
        }

        if (!user.getEmailVerificationCode().equals(verificationCode)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Mã xác thực không đúng"
            );
        }

        if (user.getEmailVerificationExpiresAt() == null ||
                user.getEmailVerificationExpiresAt().isBefore(LocalDateTime.now())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Mã xác thực đã hết hạn. Vui lòng yêu cầu gửi lại mã"
            );
        }

        user.setStatus("ACTIVE");
        user.setEmailVerificationCode(null);
        user.setEmailVerificationExpiresAt(null);

        User savedUser = userRepository.save(user);

        String token = generateTokenForUser(savedUser);

        return new AuthResponse(
                token,
                UserResponse.fromEntity(savedUser)
        );
    }

    @Transactional
    public AuthResponse resendVerificationCode(ResendVerificationCodeRequest request) {
        String email = request.getEmail().trim().toLowerCase();

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Không tìm thấy tài khoản với email này"
                ));

        if ("ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Tài khoản này đã được xác thực, không cần gửi lại mã"
            );
        }

        if (!"PENDING_VERIFY".equalsIgnoreCase(user.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Tài khoản không ở trạng thái chờ xác thực"
            );
        }

        String newVerificationCode = generateVerificationCode();

        user.setEmailVerificationCode(newVerificationCode);
        user.setEmailVerificationExpiresAt(LocalDateTime.now().plusMinutes(10));

        User savedUser = userRepository.save(user);

        try {
            emailService.sendVerificationCode(email, newVerificationCode);
        } catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Không gửi được email xác thực: " + e.getMessage()
            );
        }

        return new AuthResponse(
                "",
                UserResponse.fromEntity(savedUser)
        );
    }

    private String generateVerificationCode() {
        return String.format("%06d", SECURE_RANDOM.nextInt(1_000_000));
    }

    private String generateTokenForUser(User user) {
        UserDetails userDetails = org.springframework.security.core.userdetails.User
                .builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .authorities("ROLE_" + user.getRole())
                .build();

        return jwtService.generateToken(userDetails);
    }
}