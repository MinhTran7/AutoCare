package com.autocare.api.dto.request;

public class ReviewRequest {

    private Integer garageId;
    private Integer rating;     // 1 đến 5
    private String comment;
    private String images;      // JSON string: ["url1","url2"]

    public ReviewRequest() {
    }

    public Integer getGarageId() { return garageId; }
    public void setGarageId(Integer garageId) { this.garageId = garageId; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public String getImages() { return images; }
    public void setImages(String images) { this.images = images; }
}