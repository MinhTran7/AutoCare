package com.autocare.api.service;

import com.autocare.api.entity.*;
import com.autocare.api.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Service
@Transactional
public class MechanicService {


    @Autowired private UserRepository userRepository;
    @Autowired private MechanicRepository mechanicRepository;
    @Autowired private BookingRepository bookingRepository;
    @Autowired private BookingSparePartRepository bookingSparePartRepository;
    @Autowired private InvoiceRepository invoiceRepository;
    @Autowired private MechanicAttendanceRepository attendanceRepository;
    @Autowired
    private SparePartRepository sparePartRepository;


    // ── TV3: ghi log trạng thái ───────────────────────────────────────────────
    @Autowired @Lazy
    private BookingStatusLogService bookingStatusLogService;

    // ── Thợ nhận đơn → CONFIRMED ─────────────────────────────────────────────
    public Booking acceptBooking(Integer bookingId, Integer userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã đơn: " + bookingId));

        if (!booking.getSlot().getBookingDate().equals(LocalDate.now())) {
            throw new RuntimeException("Lỗi: Chỉ có thể nhận đơn được đặt cho ngày hôm nay.");
        }

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));

        if (!booking.getGarage().getId().equals(mechanic.getGarage().getId())) {
            throw new RuntimeException("Bạn không được nhận đơn của garage khác");
        }

        if (booking.getMechanic() != null) {
            throw new RuntimeException("Đơn đã có thợ nhận.");
        }

        if (booking.getStatus() != Booking.BookingStatus.PENDING) {
            throw new RuntimeException("Chỉ có thể nhận đơn đang chờ.");
        }

        if (mechanic.getStatus() == Mechanic.MechanicStatus.BUSY) {
            throw new RuntimeException("Bạn đang xử lý đơn khác.");
        }

        booking.setMechanic(mechanic);
        booking.setStatus(Booking.BookingStatus.CONFIRMED);
        mechanic.setStatus(Mechanic.MechanicStatus.BUSY);
        mechanicRepository.save(mechanic);
        Booking saved = bookingRepository.save(booking);

        // ── TV3: Ghi log CONFIRMED + gửi thông báo khách ─────────────────────
        try {
            bookingStatusLogService.logStatusChange(
                    bookingId, null, "CONFIRMED",
                    "Thợ " + mechanic.getUser().getFullName() + " đã nhận đơn", null);
        } catch (Exception ignored) {}

        return saved;
    }

    // ── Thợ từ chối → quay về PENDING ────────────────────────────────────────
    public Booking rejectBooking(Integer bookingId, Integer userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn"));

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));

        if (booking.getMechanic() == null) {
            throw new RuntimeException("Đơn chưa có người nhận");
        }

        if (!booking.getMechanic().getId().equals(mechanic.getId())) {
            throw new RuntimeException("Không phải đơn của bạn");
        }

        booking.setMechanic(null);
        booking.setStatus(Booking.BookingStatus.PENDING);
        mechanic.setStatus(Mechanic.MechanicStatus.AVAILABLE);
        mechanicRepository.save(mechanic);
        Booking saved = bookingRepository.save(booking);

        // ── TV3: Ghi log quay về PENDING ─────────────────────────────────────
        try {
            bookingStatusLogService.logStatusChange(
                    bookingId, null, "PENDING",
                    "Thợ đã trả lại đơn, chờ thợ khác nhận", null);
        } catch (Exception ignored) {}

        return saved;
    }

    // ── Thợ bắt đầu sửa → IN_PROGRESS ────────────────────────────────────────
    public Booking startRepair(Integer bookingId, Integer userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn"));

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mechanic"));

        if (booking.getMechanic() == null) {
            throw new RuntimeException("Đơn chưa có thợ nhận");
        }

        if (!booking.getMechanic().getId().equals(mechanic.getId())) {
            throw new RuntimeException("Bạn không được sửa đơn này");
        }

        if (booking.getStatus() != Booking.BookingStatus.CONFIRMED) {
            throw new RuntimeException("Đơn chưa ở trạng thái CONFIRMED");
        }

        booking.setStatus(Booking.BookingStatus.IN_PROGRESS);
        Booking saved = bookingRepository.save(booking);

        // ── TV3: Ghi log IN_PROGRESS + gửi thông báo khách ───────────────────
        try {
            bookingStatusLogService.logStatusChange(
                    bookingId, null, "IN_PROGRESS",
                    "Thợ đã bắt đầu sửa chữa", null);
        } catch (Exception ignored) {}

        return saved;
    }
      
    public void addSparePart(
            Integer bookingId,
            Integer sparePartId,
            Integer quantity,
            Integer userId){

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() ->
                        new RuntimeException("Booking not found"));

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        if(booking.getMechanic()==null
                || !booking.getMechanic().getId().equals(mechanic.getId())){

            throw new RuntimeException("Không phải đơn của bạn");
        }

        if(booking.getStatus()!=Booking.BookingStatus.IN_PROGRESS){

            throw new RuntimeException("Đơn chưa bắt đầu sửa");
        }

        SparePart sparePart = sparePartRepository.findById(sparePartId)
                .orElseThrow(() ->
                        new RuntimeException("Không tìm thấy phụ tùng"));

        if(sparePart.getUnitPrice()==null){

            throw new RuntimeException(
                    "Phụ tùng \"" + sparePart.getPartName()
                            + "\" chưa có giá bán, vui lòng cập nhật giá trong phần Quản lý kho trước khi sử dụng");
        }

        if(sparePart.getQuantityInStock()<quantity){

            throw new RuntimeException("Không đủ tồn kho");
        }

        BookingSparePart item =
                BookingSparePart.builder()
                        .booking(booking)
                        .sparePart(sparePart)
                        .quantity(quantity)
                        .price(sparePart.getUnitPrice())
                        .build();

        bookingSparePartRepository.save(item);

        sparePart.setQuantityInStock(
                sparePart.getQuantityInStock()-quantity);

        sparePartRepository.save(sparePart);
    }

    /**
     * Nghiệp vụ: Hoàn thành đơn, chốt phụ tùng và xuất hóa đơn
     */
    public Invoice completeBookingAndCalculateTotal(Integer bookingId,Integer userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn"));

        if (booking.getStatus() != Booking.BookingStatus.IN_PROGRESS) {
            throw new RuntimeException("Đơn chưa được sửa");
        }

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));

        if (booking.getMechanic() == null ||
                !booking.getMechanic().getId().equals(mechanic.getId())) {
            throw new RuntimeException("Bạn không được hoàn thành đơn này.");
        }

        // Tính tổng tiền
        BigDecimal servicePrice = booking.getBookingItems().stream()
                .map(BookingItem::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        List<BookingSparePart> parts = bookingSparePartRepository.findByBookingId(bookingId);
        BigDecimal partsTotal = parts.stream()
                .map(p -> p.getPrice().multiply(new BigDecimal(p.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalAmount = servicePrice.add(partsTotal);

        // Tạo hoặc cập nhật hoá đơn
        Invoice invoice = invoiceRepository.findByBooking_Id(bookingId)
                .orElse(new Invoice());
        invoice.setBooking(booking);
        invoice.setTotalAmount(totalAmount);
        invoice.setStatus("UNPAID");

        // 5. Chuyển trạng thái đơn
        booking.setStatus(Booking.BookingStatus.WAITING_PAYMENT);
        mechanic.setStatus(Mechanic.MechanicStatus.AVAILABLE);
        mechanicRepository.save(mechanic);
        bookingRepository.save(booking);
        Invoice savedInvoice = invoiceRepository.save(invoice);

        // ── TV3: Ghi log COMPLETED + gửi thông báo khách ─────────────────────
        try {
            bookingStatusLogService.logStatusChange(
                    bookingId, null, "COMPLETED",
                    "Dịch vụ hoàn thành. Hoá đơn đã được tạo.", null);
        } catch (Exception ignored) {}

        return savedInvoice;
    }

    // ── Các method không thay đổi ─────────────────────────────────────────────
    public List<Booking> getWaitingBookings(Integer userId) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));
        return bookingRepository.findWaitingBookingsByGarage(mechanic.getGarage().getId());
    }

    public List<Booking> getConfirmedBookings(Integer userId) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));
        return bookingRepository.findConfirmedBookings(mechanic.getId());
    }

    public List<Booking> getRepairingBookings(Integer userId) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));
        return bookingRepository.findRepairingBookings(mechanic.getId());
    }

    public List<Booking> getMyBookings(Integer userId) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));
        return bookingRepository.findByMechanic_IdOrderByCreatedAtDesc(mechanic.getId());
    }

    public void checkIn(Integer userId) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));

        if (mechanic.getStatus() == Mechanic.MechanicStatus.OFF) {
            throw new RuntimeException("Mechanic đang bị khóa.");
        }

        LocalDate today = LocalDate.now();
        if (attendanceRepository.findByMechanicIdAndWorkDate(mechanic.getId(), today).isPresent()) {
            throw new RuntimeException("Thợ máy đã check-in trong ngày hôm nay rồi.");
        }

        MechanicAttendance attendance = new MechanicAttendance();
        attendance.setMechanicId(mechanic.getId());
        attendance.setWorkDate(today);
        attendance.setCheckInTime(LocalTime.now());
        attendanceRepository.save(attendance);
    }

    public void checkOut(Integer userId) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));

        MechanicAttendance attendance = attendanceRepository
                .findByMechanicIdAndWorkDate(mechanic.getId(), LocalDate.now())
                .orElseThrow(() -> new RuntimeException("Hôm nay chưa check-in"));

        if (attendance.getCheckOutTime() != null) {
            throw new RuntimeException("Đã check-out");
        }

        attendance.setCheckOutTime(LocalTime.now());
        attendanceRepository.save(attendance);
    }

    public List<MechanicAttendance> getAttendanceHistory(Integer userId) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));
        return attendanceRepository.findByMechanicIdOrderByWorkDateDesc(mechanic.getId());
    }
}