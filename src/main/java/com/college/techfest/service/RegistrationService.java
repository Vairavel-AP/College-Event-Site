package com.college.techfest.service;

import com.college.techfest.model.Registration;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

@Service
public class RegistrationService {

    private final List<Registration> registrations = new ArrayList<>();
    private final AtomicInteger idCounter = new AtomicInteger(1);

    public Registration save(Registration registration) {
        registration.setId(idCounter.getAndIncrement());
        registrations.add(registration);
        return registration;
    }

    public List<Registration> getAll() {
        return registrations;
    }

    public int count() {
        return registrations.size();
    }
}
