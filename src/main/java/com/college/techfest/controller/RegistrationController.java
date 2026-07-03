package com.college.techfest.controller;

import com.college.techfest.model.Registration;
import com.college.techfest.service.RegistrationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/registrations")
public class RegistrationController {

    private final RegistrationService registrationService;

    public RegistrationController(RegistrationService registrationService) {
        this.registrationService = registrationService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Registration register(@Valid @RequestBody Registration registration) {
        return registrationService.save(registration);
    }

    @GetMapping("/count")
    public Map<String, Integer> count() {
        Map<String, Integer> body = new HashMap<>();
        body.put("totalRegistrations", registrationService.count());
        return body;
    }
}
