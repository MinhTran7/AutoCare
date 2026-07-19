package com.autocare.api.service;

import com.autocare.api.dto.admin.CreateMechanicRequest;
import com.autocare.api.dto.admin.MechanicAccountResponse;
import com.autocare.api.dto.admin.UpdateMechanicRequest;
import com.autocare.api.dto.admin.UpdateMechanicStatusRequest;
import com.autocare.api.entity.Garage;
import com.autocare.api.entity.Mechanic;
import com.autocare.api.entity.User;
import com.autocare.api.repository.GarageRepository;
import com.autocare.api.repository.MechanicRepository;
import com.autocare.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminMechanicService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final GarageRepository garageRepository;
    private final MechanicRepository mechanicRepository;

    @Transactional
    public MechanicAccountResponse createMechanic(CreateMechanicRequest request) {
        validateCreateMechanicRequest(request);

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

        // Resolve garage trước khi lưu user — tránh user được tạo rồi mới lỗi id null
        Garage garage = resolveGarage(request.getGarageId());

        User mechanic = User.builder()
                .fullName(request.getFullName().trim())
                .email(email)
                .phone(phone)
                .password(passwordEncoder.encode(request.getPassword()))
                .address(normalizeNullable(request.getAddress()))
                .avatarUrl(normalizeNullable(request.getAvatarUrl()))
                .role("MECHANIC")
                .status("ACTIVE")
                .lockedReason(null)
                .build();

        User savedMechanic = userRepository.save(mechanic);
      
        Mechanic mechanicEntity = Mechanic.builder()
                .user(savedMechanic)
                .garage(garage)
                .status(Mechanic.MechanicStatus.AVAILABLE)
                .build();

        mechanicRepository.save(mechanicEntity);

        return new MechanicAccountResponse(savedMechanic);
    }

    public List<MechanicAccountResponse> getAllMechanics() {
        return userRepository.findByRoleOrderByCreatedAtDesc("MECHANIC")
                .stream()
                .map(MechanicAccountResponse::new)
                .collect(Collectors.toList());
    }

    public MechanicAccountResponse getMechanicDetail(Integer id) {
        User mechanic = getMechanicById(id);

        return new MechanicAccountResponse(mechanic);
    }

    public MechanicAccountResponse updateMechanic(
            Integer id,
            UpdateMechanicRequest request
    ) {
        validateUpdateMechanicRequest(request);

        User mechanic = getMechanicById(id);

        String newPhone = request.getPhone().trim();

        if (!mechanic.getPhone().equals(newPhone)
                && userRepository.existsByPhone(newPhone)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Số điện thoại đã được sử dụng"
            );
        }

        mechanic.setFullName(request.getFullName().trim());
        mechanic.setPhone(newPhone);
        mechanic.setAddress(normalizeNullable(request.getAddress()));
        mechanic.setAvatarUrl(normalizeNullable(request.getAvatarUrl()));

        User savedMechanic = userRepository.save(mechanic);

        return new MechanicAccountResponse(savedMechanic);
    }

    public MechanicAccountResponse lockMechanic(
            Integer id,
            UpdateMechanicStatusRequest request
    ) {
        User mechanic = getMechanicById(id);

        mechanic.setStatus("LOCKED");

        if (request != null && request.getLockedReason() != null) {
            mechanic.setLockedReason(request.getLockedReason().trim());
        } else {
            mechanic.setLockedReason(null);
        }

        User savedMechanic = userRepository.save(mechanic);

        return new MechanicAccountResponse(savedMechanic);
    }

    public MechanicAccountResponse unlockMechanic(Integer id) {
        User mechanic = getMechanicById(id);

        mechanic.setStatus("ACTIVE");
        mechanic.setLockedReason(null);

        User savedMechanic = userRepository.save(mechanic);

        return new MechanicAccountResponse(savedMechanic);
    }

    private Garage resolveGarage(Integer garageId) {
        if (garageId == null) {
            // Form Admin hiện chưa chọn garage — gắn garage ACTIVE đầu tiên nếu có
            return garageRepository.findByStatusOrderByNameAsc(Garage.GarageStatus.ACTIVE)
                    .stream()
                    .findFirst()
                    .orElse(null);
        }

        return garageRepository.findById(garageId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Không tìm thấy garage"
                ));
    }

    private User getMechanicById(Integer id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Không tìm thấy tài khoản thợ"
                ));

        if (!"MECHANIC".equalsIgnoreCase(user.getRole())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Tài khoản này không phải thợ sửa"
            );
        }

        return user;
    }

    private void validateCreateMechanicRequest(CreateMechanicRequest request) {
        if (request == null) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Dữ liệu thợ không hợp lệ"
            );
        }

        if (isBlank(request.getFullName())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Họ tên không được để trống"
            );
        }

        if (isBlank(request.getEmail())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Email không được để trống"
            );
        }

        if (isBlank(request.getPhone())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Số điện thoại không được để trống"
            );
        }

        if (request.getPhone().trim().length() != 10) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Số điện thoại phải có 10 số"
            );
        }

        if (isBlank(request.getPassword())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Mật khẩu không được để trống"
            );
        }

        if (request.getPassword().length() < 6) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Mật khẩu phải có ít nhất 6 ký tự"
            );
        }
    }

    private void validateUpdateMechanicRequest(UpdateMechanicRequest request) {
        if (request == null) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Dữ liệu cập nhật không hợp lệ"
            );
        }

        if (isBlank(request.getFullName())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Họ tên không được để trống"
            );
        }

        if (isBlank(request.getPhone())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Số điện thoại không được để trống"
            );
        }

        if (request.getPhone().trim().length() != 10) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Số điện thoại phải có 10 số"
            );
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String normalizeNullable(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        return value.trim();
    }
}