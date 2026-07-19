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
    private UserRepository userRepository;

    @Autowired
    private MechanicRepository mechanicRepository;

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
    public Booking acceptBooking(Integer bookingId, Integer userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã đơn sửa chữa: " + bookingId));

        // Rule: Chỉ được nhận đơn của ngày hôm nay
        if (!booking.getSlot().getBookingDate().equals(LocalDate.now())) {
            throw new RuntimeException("Lỗi: Chỉ có thể nhận đơn được đặt cho ngày hôm nay.");
        }

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        if(!booking.getGarage().getId()
                .equals(mechanic.getGarage().getId())){

            throw new RuntimeException(
                    "Bạn không được nhận đơn của garage khác");
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

        return bookingRepository.save(booking);
    }

    public List<Booking> getWaitingBookings(Integer userId){

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        Integer garageId = mechanic.getGarage().getId();

        return bookingRepository.findWaitingBookingsByGarage(garageId);
    }

    public List<Booking> getConfirmedBookings(Integer userId){

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        return bookingRepository.findConfirmedBookings(mechanic.getId());
    }

    public List<Booking> getRepairingBookings(Integer userId){

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        return bookingRepository.findRepairingBookings(mechanic.getId());
    }

    public List<Booking> getMyBookings(Integer userId){

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        return bookingRepository
                .findByMechanic_IdOrderByCreatedAtDesc(mechanic.getId());
    }

    public Booking startRepair(Integer bookingId, Integer userId){

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() ->
                        new RuntimeException("Không tìm thấy đơn"));

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Không tìm thấy mechanic"));

        if(booking.getMechanic()==null){
            throw new RuntimeException("Đơn chưa có thợ nhận");
        }

        if(!booking.getMechanic().getId().equals(mechanic.getId())){
            throw new RuntimeException("Bạn không được sửa đơn này");
        }

        if(booking.getStatus()!=Booking.BookingStatus.CONFIRMED){
            throw new RuntimeException("Đơn chưa ở trạng thái CONFIRMED");
        }

        booking.setStatus(Booking.BookingStatus.IN_PROGRESS);

        return bookingRepository.save(booking);
    }

    public Booking rejectBooking(Integer bookingId,Integer userId){

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() ->
                        new RuntimeException("Không tìm thấy đơn"));

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        if(booking.getMechanic()==null){
            throw new RuntimeException("Đơn chưa có người nhận");
        }

        if(!booking.getMechanic().getId().equals(mechanic.getId())){
            throw new RuntimeException("Không phải đơn của bạn");
        }

        booking.setMechanic(null);
        booking.setStatus(Booking.BookingStatus.PENDING);

        mechanic.setStatus(Mechanic.MechanicStatus.AVAILABLE);

        mechanicRepository.save(mechanic);

        return bookingRepository.save(booking);
    }

    /**
     * Nghiệp vụ: Hoàn thành đơn, chốt phụ tùng và xuất hóa đơn
     */
    public Invoice completeBookingAndCalculateTotal(Integer bookingId,Integer userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn"));

        if(booking.getStatus()!=Booking.BookingStatus.IN_PROGRESS){
            throw new RuntimeException("Đơn chưa được sửa");
        }

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        if (booking.getMechanic() == null ||
                !booking.getMechanic().getId().equals(mechanic.getId())) {

            throw new RuntimeException("Bạn không được hoàn thành đơn này.");
        }

        // 1. Lấy giá dịch vụ cơ bản
        BigDecimal servicePrice = booking.getBookingItems().stream()
                .map(BookingItem::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 2. Tính tổng tiền phụ tùng thay thế
        List<BookingSparePart> parts = bookingSparePartRepository.findByBookingId(bookingId);
        BigDecimal partsTotal = parts.stream()
                .map(p -> p.getPrice().multiply(new BigDecimal(p.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 3. Tính tổng bill
        BigDecimal totalAmount = servicePrice.add(partsTotal);

        // 4. Tạo hoặc cập nhật hóa đơn
        Invoice invoice = invoiceRepository.findByBooking_Id(bookingId)
                .orElse(new Invoice());
        invoice.setBooking(booking);
        invoice.setTotalAmount(totalAmount);
        invoice.setStatus("UNPAID");

        // 5. Chuyển trạng thái đơn
        booking.setStatus(Booking.BookingStatus.COMPLETED);
        mechanic.setStatus(Mechanic.MechanicStatus.AVAILABLE);

        mechanicRepository.save(mechanic);

        bookingRepository.save(booking);

        return invoiceRepository.save(invoice);
    }

    /**
     * Nghiệp vụ: Chấm công (Check-in) cho thợ máy
     */
    public void checkIn(Integer userId) {

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        if(mechanic.getStatus()==Mechanic.MechanicStatus.OFF){
            throw new RuntimeException("Mechanic đang bị khóa.");
        }

        Integer mechanicId = mechanic.getId();

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

    public void checkOut(Integer userId){

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        MechanicAttendance attendance =
                attendanceRepository.findByMechanicIdAndWorkDate(
                                mechanic.getId(),
                                LocalDate.now())
                        .orElseThrow(() ->
                                new RuntimeException("Hôm nay chưa check-in"));

        if(attendance.getCheckOutTime()!=null){
            throw new RuntimeException("Đã check-out");
        }

        attendance.setCheckOutTime(LocalTime.now());

        attendanceRepository.save(attendance);
    }

    public List<MechanicAttendance> getAttendanceHistory(Integer userId){

        Mechanic mechanic = mechanicRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new RuntimeException("Mechanic not found"));

        return attendanceRepository
                .findByMechanicIdOrderByWorkDateDesc(mechanic.getId());
    }
}