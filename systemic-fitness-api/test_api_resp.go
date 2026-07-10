package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func main() {
	resp, err := http.Get("http://localhost:8080/api/medicines")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	var result struct {
		Data []map[string]interface{} `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		log.Fatal(err)
	}

	for _, med := range result.Data {
		if med["name"] == "Allopurinol" {
			b, _ := json.MarshalIndent(med, "", "  ")
			fmt.Println(string(b))
			break
		}
	}
}
