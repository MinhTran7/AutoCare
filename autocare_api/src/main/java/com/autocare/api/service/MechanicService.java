package com.autocare.api.service;

import com.autocare.api.entity.*;
import com.autocare.api.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Service
@Transactional // Đảm bảo tính toàn vẹn dữ liệu (Rollback nếu có lỗi)
public class MechanicService {

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private BookingSparePartRepository bookingSparePartRepository;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private MechanicAttendanceRepository attendanceRepository;

    /**
     * Nghiệp vụ: Thợ máy nhận đơn sửa chữa
     */
    public Booking acceptBooking(Integer bookingId, Integer mechanicId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã đơn sửa chữa: " + bookingId));

        // Rule: Chỉ được nhận đơn của ngày hôm nay
        if (!booking.getSlot().getBookingDate().equals(LocalDate.now())) {
            throw new RuntimeException("Lỗi: Chỉ có thể nhận đơn được đặt cho ngày hôm nay.");
        }

        Mechanic mechanic = new Mechanic();
        mechanic.setId(mechanicId);
        booking.setMechanic(mechanic);
        booking.setStatus(Booking.BookingStatus.IN_PROGRESS);

        return bookingRepository.save(booking);
    }

    /**
     * Nghiệp vụ: Hoàn thành đơn, chốt phụ tùng và xuất hóa đơn
     */
    public Invoice completeBookingAndCalculateTotal(Integer bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn"));

        // 1. Lấy giá dịch vụ cơ bản
        BigDecimal servicePrice = booking.getService().getPrice();

        // 2. Tính tổng tiền phụ tùng thay thế
        List<BookingSparePart> parts = bookingSparePartRepository.findByBookingId(bookingId);
        BigDecimal partsTotal = parts.stream()
                .map(p -> p.getPrice().multiply(new BigDecimal(p.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 3. Tính tổng bill
        BigDecimal totalAmount = servicePrice.add(partsTotal);

        // 4. Tạo hoặc cập nhật hóa đơn
        Invoice invoice = invoiceRepository.findByBookingId(bookingId)
                .orElse(new Invoice());
        invoice.setBooking(booking);
        invoice.setTotalAmount(totalAmount);
        invoice.setStatus("UNPAID");

        // 5. Chuyển trạng thái đơn
        booking.setStatus(Booking.BookingStatus.COMPLETED);
        bookingRepository.save(booking);

        return invoiceRepository.save(invoice);
    }

    /**
     * Nghiệp vụ: Chấm công (Check-in) cho thợ máy
     */
    public void checkIn(Integer mechanicId) {
        LocalDate today = LocalDate.now();

        // Kiểm tra xem hôm nay đã check-in chưa
        if (attendanceRepository.findByMechanicIdAndWorkDate(mechanicId, today).isPresent()) {
            throw new RuntimeException("Thợ máy đã check-in trong ngày hôm nay rồi.");
        }

        MechanicAttendance attendance = new MechanicAttendance();
        attendance.setMechanicId(mechanicId);
        attendance.setWorkDate(today);
        attendance.setCheckInTime(LocalTime.now());

        attendanceRepository.save(attendance);
    }
}