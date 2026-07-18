package com.autocare.api.service;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import com.autocare.api.dto.request.BookingRequestDTO;
import com.autocare.api.dto.response.BookingResponseDTO;
import com.autocare.api.entity.*;
import com.autocare.api.exception.BusinessException;
import com.autocare.api.exception.ResourceNotFoundException;
import com.autocare.api.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final BookingSlotRepository bookingSlotRepository;
    private final VehicleRepository vehicleRepository;
    private final GarageRepository garageRepository;
    private final RepairServiceRepository repairServiceRepository;
    private final GarageServiceLinkRepository garageServiceLinkRepository;
    // THÊM:UserRepository để tìm thông tin khách hàng từ token đăng nhập
    private final UserRepository userRepository;

    /**
     * Man hinh 6 -> 7: "Xac nhan dat lich" -> "Dat lich thanh cong".
     * - Kiem tra garage co ho tro dich vu duoc chon khong.
     * - Kiem tra slot con AVAILABLE khong (tranh 2 nguoi dat trung gio).
     * - Neu bookingType = HOME thi bat buoc phai co dia chi.
     * - Danh dau slot la BOOKED va tao Booking voi trang thai CONFIRMED.
     */
    @Transactional
    public BookingResponseDTO createBooking(BookingRequestDTO req) {

        Vehicle vehicle = vehicleRepository.findById(req.getVehicleId())
                .orElseThrow(() -> new ResourceNotFoundException("Khong tim thay xe id=" + req.getVehicleId()));

        Garage garage = garageRepository.findById(req.getGarageId())
                .orElseThrow(() -> new ResourceNotFoundException("Khong tim thay garage id=" + req.getGarageId()));

        RepairService service = repairServiceRepository.findById(req.getServiceId())
                .orElseThrow(() -> new ResourceNotFoundException("Khong tim thay dich vu id=" + req.getServiceId()));

        if (!garageServiceLinkRepository.existsByGarage_IdAndService_Id(garage.getId(), service.getId())) {
            throw new BusinessException("Garage nay khong ho tro dich vu \"" + service.getName() + "\"");
        }

        BookingSlot slot = bookingSlotRepository.findById(req.getSlotId())
                .orElseThrow(() -> new ResourceNotFoundException("Khong tim thay khung gio id=" + req.getSlotId()));

        if (!slot.getGarage().getId().equals(garage.getId())) {
            throw new BusinessException("Khung gio khong thuoc garage da chon");
        }
        if (slot.getStatus() != BookingSlot.SlotStatus.AVAILABLE) {
            throw new BusinessException("Khung gio nay da duoc dat, vui long chon khung gio khac");
        }

        Booking.BookingType type;
        try {
            type = Booking.BookingType.valueOf(req.getBookingType());
        } catch (IllegalArgumentException ex) {
            throw new BusinessException("bookingType khong hop le (GARAGE hoac HOME)");
        }

        if (type == Booking.BookingType.HOME
                && (req.getServiceAddress() == null || req.getServiceAddress().isBlank())) {
            throw new BusinessException("Vui long chon dia chi sua chua tan noi");
        }

        // Giu cho slot
        slot.setStatus(BookingSlot.SlotStatus.BOOKED);
        bookingSlotRepository.save(slot);

        Booking booking = Booking.builder()
                .vehicle(vehicle)
                .garage(garage)
                .service(service)
                .slot(slot)
                .bookingType(type)
                .serviceAddress(type == Booking.BookingType.HOME ? req.getServiceAddress() : null)
                .latitude(type == Booking.BookingType.HOME ? req.getLatitude() : null)
                .longitude(type == Booking.BookingType.HOME ? req.getLongitude() : null)
                .status(Booking.BookingStatus.CONFIRMED)
                .build();

        booking = bookingRepository.save(booking);

        return toDto(booking);
    }

    @Transactional(readOnly = true)
    public BookingResponseDTO getBooking(Integer bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Khong tim thay lich hen id=" + bookingId));
        return toDto(booking);
    }

    @Transactional(readOnly = true)
    public List<BookingResponseDTO> getBookingsOfUser(Integer userId) {
        return bookingRepository.findByVehicle_UserIdOrderByCreatedAtDesc(userId)
                .stream().map(this::toDto).toList();
    }

    // THÊM: Logic xử lý lấy lịch hẹn tự động theo Token cho tính năng của TV3
    @Transactional(readOnly = true)
    public List<BookingResponseDTO> getMyBookings() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new RuntimeException("Bạn chưa đăng nhập hoặc Token không hợp lệ");
        }

        User currentUser = userRepository.findByEmailOrPhone(auth.getName(), auth.getName())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        List<Booking> bookings = bookingRepository.findByVehicle_UserIdOrderByCreatedAtDesc(currentUser.getId());

        // Sử dụng hàm toDto có sẵn ở dưới để dọn sạch lỗi constructor
        return bookings.stream()
                .map(this::toDto)
                .toList();
    }

    private BookingResponseDTO toDto(Booking b) {
        String garageAddress = b.getBookingType() == Booking.BookingType.HOME
                ? b.getServiceAddress()
                : b.getGarage().getAddress();

        return BookingResponseDTO.builder()
                .id(b.getId())
                .bookingCode(generateBookingCode(b))
                .bookingType(b.getBookingType().name())
                .status(b.getStatus().name())
                .serviceName(b.getService().getName())
                .servicePrice(b.getService().getPrice())
                .garageName(b.getGarage().getName())
                .garageAddress(b.getGarage().getAddress())
                .vehicleInfo(b.getVehicle().getBrand() + " " + b.getVehicle().getModel()
                        + " - " + b.getVehicle().getLicensePlate())
                .bookingDate(b.getSlot().getBookingDate())
                .startTime(b.getSlot().getStartTime())
                .endTime(b.getSlot().getEndTime())
                .displayAddress(garageAddress)
                .latitude(b.getLatitude())
                .longitude(b.getLongitude())
                .totalAmount(b.getService().getPrice())
                .createdAt(b.getCreatedAt())
                .build();
    }

    /** Sinh ma dat lich dang #DL2406289 (DL + ddMMyy + id), giong mockup man hinh 7. */
    private String generateBookingCode(Booking b) {
        String datePart = b.getCreatedAt() != null
                ? b.getCreatedAt().format(DateTimeFormatter.ofPattern("ddMMyy"))
                : "000000";
        return "DL" + datePart + b.getId();
    }

}