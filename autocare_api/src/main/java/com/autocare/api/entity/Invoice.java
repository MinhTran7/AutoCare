package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "invoices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // ── Quan hệ với Booking (TV2 đã có Booking entity) ───────────────────────
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false, unique = true)
    private Booking booking;

    // Giữ lại để tiện dùng khi chỉ cần ID
    public Integer getBookingId() {
        return booking != null ? booking.getId() : null;
    }

    @Column(name = "invoice_code", length = 30, unique = true)
    private String invoiceCode;

    @Builder.Default
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal subtotal = BigDecimal.ZERO;

    @Builder.Default
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal discount = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "tax_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal taxAmount = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "payment_method", length = 50)
    private String paymentMethod;

    @Column(name = "payment_date")
    private LocalDateTime paymentDate;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "pdf_url", length = 500)
    private String pdfUrl;

    @Builder.Default
    @Column(nullable = false, length = 20)
    private String status = "UNPAID";

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null || status.isBlank()) status = "UNPAID";
        if (subtotal  == null) subtotal  = BigDecimal.ZERO;
        if (discount  == null) discount  = BigDecimal.ZERO;
        if (taxAmount == null) taxAmount = BigDecimal.ZERO;
//        if (invoiceCode == null || invoiceCode.isBlank()) {
//            String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
//            invoiceCode = "INV-" + date + "-TEMP";
//        }
        // Không sinh invoiceCode tại đây.
        // InvoiceService sẽ tạo sau khi save.
    }

    @PreUpdate
    public void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}