package main

import (
	"fmt"
	"log"

	"github.com/xuri/excelize/v2"
)

func main() {
	files := []string{"FEMALE- VIDEO LEVEL 4.xlsx", "FEMALE-VIDEO LEVEL 5.xlsx", "MALE-VIDEO LEVEL 4.xlsx", "MALE-VIDEO LEVEL 5.xlsx"}
	for _, file := range files {
		fmt.Printf("\n--- File: %s ---\n", file)
		f, err := excelize.OpenFile(file)
		if err != nil {
			log.Printf("Error opening %s: %v", file, err)
			continue
		}
		rows, _ := f.GetRows(f.GetSheetList()[0])
		f.Close()
		
		for i := 1; i < len(rows) && i < 15; i++ {
			row := rows[i]
			for len(row) < 8 {
				row = append(row, "")
			}
			fName := row[4]
			if fName == "" {
				fName = row[5]
			}
			vid := row[6]
			fmt.Printf("Row %d | Name: %s | Video: %s\n", i, fName, vid)
		}
	}
}
