package com.college.techfest.model;

public class Announcement {

    private int id;
    private String date;
    private String title;
    private String message;

    public Announcement() {
    }

    public Announcement(int id, String date, String title, String message) {
        this.id = id;
        this.date = date;
        this.title = title;
        this.message = message;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
