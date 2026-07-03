package com.college.techfest.service;

import com.college.techfest.model.Announcement;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

@Service
public class AnnouncementService {

    private final List<Announcement> announcements = new ArrayList<>();
    private final AtomicInteger idCounter = new AtomicInteger(1);

    public AnnouncementService() {
        announcements.add(new Announcement(idCounter.getAndIncrement(),
                "2026-06-28", "Registration Deadline Extended",
                "The last date for team registration has been extended to September 5, 2026."));
        announcements.add(new Announcement(idCounter.getAndIncrement(),
                "2026-06-20", "Venue Confirmed for Workshops",
                "All hands-on workshops will be held in Lab 1 and Lab 3 in the CS block."));
        announcements.add(new Announcement(idCounter.getAndIncrement(),
                "2026-06-10", "Keynote Speaker List Released",
                "Check the Speakers page for the full list of keynote speakers and panelists."));
        announcements.add(new Announcement(idCounter.getAndIncrement(),
                "2026-05-30", "Sponsorship Applications Open",
                "Companies interested in sponsoring TechFest 2026 can contact the organizing committee."));
    }

    public List<Announcement> getAll() {
        return announcements;
    }

    public Announcement add(Announcement announcement) {
        announcement.setId(idCounter.getAndIncrement());
        announcements.add(0, announcement);
        return announcement;
    }
}
