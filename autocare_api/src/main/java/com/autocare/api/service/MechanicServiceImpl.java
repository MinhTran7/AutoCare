package com.autocare.api.service;

import com.autocare.api.dto.response.BookingResponse;
import com.autocare.api.entity.Mechanic;
import com.autocare.api.repository.MechanicRepository;
import com.autocare.api.service.MechanicService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class MechanicServiceImpl implements MechanicService {

    private final MechanicRepository mechanicRepository;

    // Lưu ý: Khi thành viên làm module TV2 hoàn thiện BookingRepository,
    // bạn hãy bỏ dấu comment (//) ở dưới ra để sử dụng nhé.
    // private final BookingRepository bookingRepository;

    @Override
    public void updateStatus(Integer userId, String status) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thợ máy có User ID: " + userId));

        try {
            // Chuyển đổi chuỗi chữ thường/chữ hoa từ Client thành Enum tương ứng trong Entity
            // Giả sử Enum nằm trong class Mechanic như: Mechanic.MechanicStatus
            // mechanic.setStatus(Mechanic.MechanicStatus.valueOf(status.toUpperCase()));
            mechanicRepository.save(mechanic);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Trạng thái không hợp lệ. Chỉ chấp nhận: AVAILABLE, BUSY, OFF");
        }
    }

    @Override
    public List<BookingResponse> getAssignedBookings(Integer userId) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thợ máy có User ID: " + userId));

        List<BookingResponse> responses = new ArrayList<>();

        // Mẫu Logic xử lý sau khi có BookingRepository từ module TV2:
        // List<Booking> bookings = bookingRepository.findByMechanicId(mechanic.getId());
        // Sau đó lặp qua list bookings để map dữ liệu vào DTO BookingResponse

        return responses;
    }

    @Override
    public void updateBookingStatus(Integer mechanicUserId, Integer bookingId, String newStatus) {
        Mechanic mechanic = mechanicRepository.findByUserId(mechanicUserId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thợ máy có User ID: " + mechanicUserId));

        // Mẫu Logic xử lý sau khi có BookingRepository từ module TV2:
        // Booking booking = bookingRepository.findById(bookingId)
        //        .orElseThrow(() -> new RuntimeException("Không tìm thấy lịch đặt"));
        //
        // Kiểm tra xem lịch đặt này có chính xác là giao cho thợ máy này không
        // if (!booking.getMechanicId().equals(mechanic.getId())) {
        //     throw new RuntimeException("Lịch đặt này không được phân công cho bạn!");
        // }
        //
        // booking.setStatus(newStatus);
        // bookingRepository.save(booking);
    }
}