package com.autocare.api.service;

import com.autocare.api.dto.admin.CustomerAccountResponse;
import com.autocare.api.dto.admin.UpdateMechanicStatusRequest;
import com.autocare.api.entity.User;
import com.autocare.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminCustomerService {

    private final UserRepository userRepository;

    public List<CustomerAccountResponse> getAllCustomers() {
        return userRepository.findByRoleOrderByCreatedAtDesc("CUSTOMER")
                .stream()
                .map(CustomerAccountResponse::new)
                .collect(Collectors.toList());
    }

    public CustomerAccountResponse getCustomerDetail(Integer id) {
        return new CustomerAccountResponse(getCustomerById(id));
    }

    public CustomerAccountResponse lockCustomer(Integer id, UpdateMechanicStatusRequest request) {
        User customer = getCustomerById(id);
        customer.setStatus("LOCKED");
        if (request != null && request.getLockedReason() != null) {
            customer.setLockedReason(request.getLockedReason().trim());
        } else {
            customer.setLockedReason(null);
        }
        return new CustomerAccountResponse(userRepository.save(customer));
    }

    public CustomerAccountResponse unlockCustomer(Integer id) {
        User customer = getCustomerById(id);
        customer.setStatus("ACTIVE");
        customer.setLockedReason(null);
        return new CustomerAccountResponse(userRepository.save(customer));
    }

    private User getCustomerById(Integer id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Không tìm thấy khách hàng"
                ));

        if (!"CUSTOMER".equalsIgnoreCase(user.getRole())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Tài khoản này không phải khách hàng"
            );
        }

        return user;
    }
}
