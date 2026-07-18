package com.autocare.api.service;

import com.autocare.api.dto.request.BookingRequestDTO;
import com.autocare.api.dto.service.*;
import com.autocare.api.dto.response.BookingResponseDTO;
import com.autocare.api.entity.*;
import com.autocare.api.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.autocare.api.dto.service.BookingItemDTO;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final BookingItemRepository bookingItemRepository;
    private final BookingSlotRepository bookingSlotRepository;
    private final VehicleRepository vehicleRepository;
    private final GarageRepository garageRepository;
    private final RepairServiceRepository repairServiceRepository;
    private final GarageServiceLinkRepository garageServiceLinkRepository;

    @Transactional
    public BookingResponseDTO createBooking(BookingRequestDTO req) {

        Vehicle vehicle = vehicleRepository.findById(req.getVehicleId())
                .orElseThrow(() -> new RuntimeException("Khong tim thay xe id=" + req.getVehicleId()));

        Garage garage = garageRepository.findById(req.getGarageId())
                .orElseThrow(() -> new RuntimeException("Khong tim thay garage id=" + req.getGarageId()));

        BookingSlot slot = bookingSlotRepository.findById(req.getSlotId())
                .orElseThrow(() -> new RuntimeException("Khong tim thay khung gio id=" + req.getSlotId()));

        if (!slot.getGarage().getId().equals(garage.getId())) {
            throw new RuntimeException("Khung gio khong thuoc garage da chon");
        }
        if (slot.getStatus() != BookingSlot.SlotStatus.AVAILABLE) {
            throw new RuntimeException("Khung gio nay da duoc dat, vui long chon khung gio khac");
        }

        Booking.BookingType type;
        try {
            type = Booking.BookingType.valueOf(req.getBookingType());
        } catch (IllegalArgumentException ex) {
            throw new RuntimeException("bookingType khong hop le (GARAGE hoac HOME)");
        }

        if (type == Booking.BookingType.HOME
                && (req.getServiceAddress() == null || req.getServiceAddress().isBlank())) {
            throw new RuntimeException("Vui long chon dia chi sua chua tan noi");
        }

        List<RepairService> chosenServices = req.getServiceIds().stream()
                .map(serviceId -> {
                    RepairService s = repairServiceRepository.findById(serviceId)
                            .orElseThrow(() -> new RuntimeException("Khong tim thay dich vu id=" + serviceId));
                    if (!garageServiceLinkRepository.existsByGarage_IdAndService_Id(garage.getId(), serviceId)) {
                        throw new RuntimeException("Garage nay khong ho tro dich vu \"" + s.getName() + "\"");
                    }
                    return s;
                })
                .toList();

        slot.setStatus(BookingSlot.SlotStatus.BOOKED);
        bookingSlotRepository.save(slot);

        Booking booking = Booking.builder()
                .vehicle(vehicle)
                .garage(garage)
                .slot(slot)
                .bookingType(type)
                .serviceAddress(type == Booking.BookingType.HOME ? req.getServiceAddress() : null)
                .latitude(type == Booking.BookingType.HOME ? req.getLatitude() : null)
                .longitude(type == Booking.BookingType.HOME ? req.getLongitude() : null)
                .status(Booking.BookingStatus.CONFIRMED)
                .build();
        booking = bookingRepository.save(booking);

        for (RepairService s : chosenServices) {
            BookingItem item = BookingItem.builder()
                    .booking(booking)
                    .service(s)
                    .price(s.getPrice())
                    .build();
            bookingItemRepository.save(item);
        }

        return toDto(booking);
    }

    @Transactional(readOnly = true)
    public BookingResponseDTO getBooking(Integer bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Khong tim thay lich hen id=" + bookingId));
        return toDto(booking);
    }

    @Transactional(readOnly = true)
    public List<BookingResponseDTO> getBookingsOfUser(Integer userId) {
        return bookingRepository.findByVehicle_UserIdOrderByCreatedAtDesc(userId)
                .stream().map(this::toDto).toList();
    }

    private BookingResponseDTO toDto(Booking b) {
        List<BookingItem> items = bookingItemRepository.findByBooking_Id(b.getId());

        List<BookingItemDTO> itemDtos = items.stream()
                .map(i -> BookingItemDTO.builder()
                        .serviceId(i.getService().getId())
                        .serviceName(i.getService().getName())
                        .price(i.getPrice())
                        .build())
                .toList();

        BigDecimal total = itemDtos.stream()
                .map(BookingItemDTO::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        String garageAddress = b.getBookingType() == Booking.BookingType.HOME
                ? b.getServiceAddress()
                : b.getGarage().getAddress();

        return BookingResponseDTO.builder()
                .id(b.getId())
                .bookingCode(generateBookingCode(b))
                .bookingType(b.getBookingType().name())
                .status(b.getStatus().name())
                .items(itemDtos)
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
                .totalAmount(total)
                .createdAt(b.getCreatedAt())
                .build();
    }

    private String generateBookingCode(Booking b) {
        String datePart = b.getCreatedAt() != null
                ? b.getCreatedAt().format(DateTimeFormatter.ofPattern("ddMMyy"))
                : "000000";
        return "DL" + datePart + b.getId();
    }
}