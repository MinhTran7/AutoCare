package com.autocare.api.service;

import com.autocare.api.entity.Booking;
import com.autocare.api.entity.Invoice;
import com.autocare.api.entity.User;
import com.autocare.api.repository.BookingRepository;
import com.autocare.api.repository.InvoiceRepository;
import com.autocare.api.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;

    public InvoiceService(
            InvoiceRepository invoiceRepository,
            BookingRepository bookingRepository,
            UserRepository userRepository
    ) {
        this.invoiceRepository = invoiceRepository;
        this.bookingRepository = bookingRepository;
        this.userRepository = userRepository;
    }

    // ── Lấy hoá đơn theo bookingId ───────────────────────────────────────────
    public Invoice getByBookingId(Integer bookingId) {
        return invoiceRepository
                .findByBooking_Id(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy hoá đơn"));
    }

    // ── Lấy hoá đơn theo mã hoá đơn ─────────────────────────────────────────
    public Invoice getByInvoiceCode(String invoiceCode) {
        return invoiceRepository
                .findByInvoiceCode(invoiceCode)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy hoá đơn: " + invoiceCode));
    }

    // ── Tạo hoá đơn mới ──────────────────────────────────────────────────────
    public Invoice createInvoice(Integer bookingId, BigDecimal subtotal,
                                 BigDecimal discount, BigDecimal taxAmount,
                                 String paymentMethod) {
        // Kiểm tra booking tồn tại
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy booking #" + bookingId));

        // Kiểm tra booking đã có hoá đơn chưa
        if (invoiceRepository.existsByBooking_Id(bookingId)) {
            throw new RuntimeException("Booking này đã có hoá đơn");
        }

        BigDecimal safeSubtotal  = subtotal  != null ? subtotal  : BigDecimal.ZERO;
        BigDecimal safeDiscount  = discount  != null ? discount  : BigDecimal.ZERO;
        BigDecimal safeTaxAmount = taxAmount != null ? taxAmount : BigDecimal.ZERO;
        BigDecimal totalAmount   = safeSubtotal.subtract(safeDiscount).add(safeTaxAmount);

        Invoice invoice = Invoice.builder()
                .booking(booking)
                .subtotal(safeSubtotal)
                .discount(safeDiscount)
                .taxAmount(safeTaxAmount)
                .totalAmount(totalAmount)
                .paymentMethod(paymentMethod)
                .status("UNPAID")
                .build();

        Invoice saved = invoiceRepository.save(invoice);

        // Sinh invoice_code đúng định dạng INV-YYYYMMDD-{id}
        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        saved.setInvoiceCode(String.format("INV-%s-%04d", date, saved.getId()));

        return invoiceRepository.save(saved);
    }

    // ── Đánh dấu đã thanh toán ───────────────────────────────────────────────
    public Invoice markAsPaid(Integer bookingId, String paymentMethod) {
        Invoice invoice = getByBookingId(bookingId);

        if ("PAID".equals(invoice.getStatus())) {
            throw new RuntimeException("Hoá đơn này đã được thanh toán");
        }

        invoice.setStatus("PAID");
        invoice.setPaymentMethod(paymentMethod);
        invoice.setPaidAt(LocalDateTime.now());
        invoice.setPaymentDate(LocalDateTime.now());

        return invoiceRepository.save(invoice);
    }

    // ── Huỷ hoá đơn ─────────────────────────────────────────────────────────
    public Invoice cancelInvoice(Integer bookingId) {
        Invoice invoice = getByBookingId(bookingId);

        if ("PAID".equals(invoice.getStatus())) {
            throw new RuntimeException("Không thể huỷ hoá đơn đã thanh toán");
        }

        invoice.setStatus("CANCELLED");
        return invoiceRepository.save(invoice);
    }

    // ── Helper ───────────────────────────────────────────────────────────────
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder
                .getContext().getAuthentication();

        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("Bạn chưa đăng nhập");
        }

        return userRepository
                .findByEmailOrPhone(authentication.getName(), authentication.getName())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }
}