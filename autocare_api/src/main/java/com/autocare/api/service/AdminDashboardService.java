package com.autocare.api.service;

import com.autocare.api.dto.admin.DashboardSummaryResponse;
import com.autocare.api.entity.SparePart;
import com.autocare.api.repository.BookingRepository;
import com.autocare.api.repository.InvoiceRepository;
import com.autocare.api.repository.SparePartRepository;
import com.autocare.api.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private static final List<String> BOOKING_STATUSES = List.of(
            "PENDING", "CONFIRMED", "IN_PROGRESS", "COMPLETED", "CANCELLED"
    );

    private final BookingRepository bookingRepository;
    private final InvoiceRepository invoiceRepository;
    private final UserRepository userRepository;
    private final SparePartRepository sparePartRepository;

    public DashboardSummaryResponse getSummary(LocalDate fromDate, LocalDate toDate) {
        LocalDate effectiveFrom = fromDate != null ? fromDate : LocalDate.now().minusDays(6);
        LocalDate effectiveTo = toDate != null ? toDate : LocalDate.now();

        if (effectiveTo.isBefore(effectiveFrom)) {
            LocalDate tmp = effectiveFrom;
            effectiveFrom = effectiveTo;
            effectiveTo = tmp;
        }

        LocalDateTime from = effectiveFrom.atStartOfDay();
        LocalDateTime to = effectiveTo.atTime(LocalTime.MAX);

        DashboardSummaryResponse response = new DashboardSummaryResponse();
        response.setTotalBookingsInRange(bookingRepository.countByCreatedAtBetween(from, to));

        Map<String, Long> byStatus = new LinkedHashMap<>();
        for (String status : BOOKING_STATUSES) {
            byStatus.put(status, bookingRepository.countByStatus(status));
        }
        response.setBookingsByStatus(byStatus);

        response.setHomeJobsInProgress(
                bookingRepository.countByBookingTypeAndStatusIn(
                        "HOME",
                        List.of("CONFIRMED", "IN_PROGRESS")
                )
        );

        BigDecimal revenue = invoiceRepository.sumPaidAmountBetween(from, to);
        response.setPaidRevenue(revenue != null ? revenue : BigDecimal.ZERO);

        response.setTotalCustomers(userRepository.findByRoleOrderByCreatedAtDesc("CUSTOMER").size());
        response.setTotalMechanics(userRepository.findByRoleOrderByCreatedAtDesc("MECHANIC").size());

        List<SparePart> lowStock = sparePartRepository.findLowStock();
        response.setLowStockCount(lowStock.size());
        response.setLowStockItems(
                lowStock.stream()
                        .limit(10)
                        .map(p -> new DashboardSummaryResponse.LowStockItem(
                                p.getId(),
                                p.getPartName(),
                                p.getQuantityInStock(),
                                p.getMinStockLevel()
                        ))
                        .collect(Collectors.toList())
        );

        return response;
    }
}
