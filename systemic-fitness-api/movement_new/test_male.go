package main

import (
	"fmt"
	"log"
	"github.com/xuri/excelize/v2"
)

func main() {
	files := []string{"MALE-VIDEO LEVEL 4.xlsx", "MALE-VIDEO LEVEL 5.xlsx"}
	for _, file := range files {
		f, err := excelize.OpenFile(file)
		if err != nil {
			log.Fatal(err)
		}
		rows, _ := f.GetRows(f.GetSheetList()[0])
		f.Close()
		
		fmt.Printf("--- File: %s ---\n", file)
		for i := 0; i < len(rows) && i < 15; i++ {
			row := rows[i]
			fmt.Printf("Row %d: ", i)
			for j, col := range row {
				fmt.Printf("[%d: %s] ", j, col)
			}
			fmt.Println()
		}
	}
}
