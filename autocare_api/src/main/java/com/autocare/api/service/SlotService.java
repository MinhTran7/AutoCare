package com.autocare.api.service;

import com.autocare.api.dto.service.SlotDTO;
import com.autocare.api.entity.BookingSlot;
import com.autocare.api.entity.Garage;
import com.autocare.api.exception.ResourceNotFoundException;
import com.autocare.api.repository.BookingSlotRepository;
import com.autocare.api.repository.GarageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SlotService {

    private final BookingSlotRepository bookingSlotRepository;
    private final GarageRepository garageRepository;

    // Khung gio lam viec mac dinh cua garage, khop voi mockup man hinh 4 (08:00 - 17:00)
    private static final LocalTime OPEN_TIME = LocalTime.of(8, 0);
    private static final LocalTime CLOSE_TIME = LocalTime.of(17, 0);

    /**
     * Man hinh 4: "Chon ngay gio".
     * Lay danh sach khung gio cua 1 garage trong 1 ngay. Neu ngay do chua co du lieu
     * trong booking_slots thi tu sinh cac khung gio moi 1 tieng (trang thai AVAILABLE).
     */
    @Transactional
    public List<SlotDTO> getSlotsForDate(Integer garageId, LocalDate date) {
        Garage garage = garageRepository.findById(garageId)
                .orElseThrow(() -> new ResourceNotFoundException("Khong tim thay garage id=" + garageId));

        List<BookingSlot> slots = bookingSlotRepository
                .findByGarage_IdAndBookingDateOrderByStartTimeAsc(garageId, date);

        if (slots.isEmpty()) {
            slots = generateDefaultSlots(garage, date);
        }

        return slots.stream().map(this::toDto).toList();
    }

    private List<BookingSlot> generateDefaultSlots(Garage garage, LocalDate date) {
        List<BookingSlot> generated = new ArrayList<>();
        LocalTime cursor = OPEN_TIME;
        while (cursor.isBefore(CLOSE_TIME)) {
            LocalTime end = cursor.plusHours(1);
            BookingSlot slot = BookingSlot.builder()
                    .garage(garage)
                    .bookingDate(date)
                    .startTime(cursor)
                    .endTime(end)
                    .status(BookingSlot.SlotStatus.AVAILABLE)
                    .build();
            generated.add(bookingSlotRepository.save(slot));
            cursor = end;
        }
        return generated;
    }

    private SlotDTO toDto(BookingSlot s) {
        return SlotDTO.builder()
                .id(s.getId())
                .startTime(s.getStartTime())
                .endTime(s.getEndTime())
                .status(s.getStatus().name())
                .build();
    }
}

