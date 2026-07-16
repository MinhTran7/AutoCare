package com.autocare.api.controller;


import com.autocare.api.dto.service.SlotDTO;
import com.autocare.api.service.SlotService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/** Man hinh 4: "Chon ngay gio". */
@RestController
@RequestMapping("/api/garages/{garageId}/slots")
@RequiredArgsConstructor
public class SlotController {

    private final SlotService slotService;

    @GetMapping
    public List<SlotDTO> getSlots(
            @PathVariable Integer garageId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return slotService.getSlotsForDate(garageId, date);
    }
}

