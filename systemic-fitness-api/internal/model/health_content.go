package model

import "time"

// ════════════════════════════════════════════════════════════
//  Health Content Models (Health Articles & Doctor Videos)
// ════════════════════════════════════════════════════════════

type HealthArticle struct {
	ID          string    `json:"id"`
	Title       string    `json:"title"`
	Content     string    `json:"content"`
	ImageURL    string    `json:"image_url"`
	Source      string    `json:"source"`
	IsPublished bool      `json:"is_published"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	TitleEN     *string   `json:"title_en,omitempty"`
	ContentEN   *string   `json:"content_en,omitempty"`
}

type DoctorVideo struct {
	ID              string    `json:"id"`
	Title           string    `json:"title"`
	Description     string    `json:"description"`
	VideoURL        string    `json:"video_url"`
	ThumbnailURL    string    `json:"thumbnail_url"`
	DoctorName      string    `json:"doctor_name"`
	DoctorSpecialty string    `json:"doctor_specialty"`
	IsPublished     bool      `json:"is_published"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	TitleEN         *string   `json:"title_en,omitempty"`
	DescriptionEN   *string   `json:"description_en,omitempty"`
}
