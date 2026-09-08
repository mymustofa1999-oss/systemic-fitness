package main

import (
	"fmt"
	"github.com/go-playground/validator/v10"
)

type CreateMovementInput struct {
	Name           string   json:"name"             validate:"required,min=1,max=150"
	BodyPart       string   json:"body_part"        validate:"required,oneof=upper lower core 'whole body'"
	VideoURLMale   *string  json:"video_url_male,omitempty"   validate:"omitempty,url"
	VideoURLFemale *string  json:"video_url_female,omitempty" validate:"omitempty,url"
	ImageURL       *string  json:"image_url,omitempty"     validate:"omitempty,url"
	Instructions   []string json:"instructions,omitempty"
	Categories     []string json:"categories"       validate:"required,min=1"
	Type           *string  json:"type,omitempty"         validate:"omitempty,oneof=sit stand mat"
	Pattern        *string  json:"pattern,omitempty"
	Level          *int     json:"level,omitempty"        validate:"omitempty,min=1,max=6"
	NameEN         *string  json:"name_en,omitempty"      validate:"omitempty,max=150"
	InstructionsEN []string json:"instructions_en,omitempty"
	DescriptionEN  *string  json:"description_en,omitempty"
	IsActive       bool     json:"is_active"
	TargetGender   *string  json:"target_gender,omitempty" validate:"omitempty,oneof=male female universal"
}

func main() {
	v := validator.New()
	url := "https://www.youtube.com/watch?v=C2AFd1PLsF8i"
	tg := "universal"
	input := CreateMovementInput{
		Name:         "test",
		BodyPart:     "upper",
		Categories:   []string{"FC"},
		VideoURLMale: &url,
		TargetGender: &tg,
	}

	err := v.Struct(input)
	if err != nil {
		fmt.Println("Validation error:", err)
	} else {
		fmt.Println("Validation passed!")
	}
}
