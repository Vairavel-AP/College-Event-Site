package com.college.techfest.model;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class Registration {

    private int id;

    @NotBlank(message = "Full name is required")
    private String fullName;

    @NotBlank(message = "College name is required")
    private String college;

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @NotBlank(message = "Event track is required")
    private String eventTrack;

    private String notes;

    public Registration() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getCollege() {
        return college;
    }

    public void setCollege(String college) {
        this.college = college;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getEventTrack() {
        return eventTrack;
    }

    public void setEventTrack(String eventTrack) {
        this.eventTrack = eventTrack;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
