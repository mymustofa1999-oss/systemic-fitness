package main

import (
	"fmt"

	"github.com/xuri/excelize/v2"
)

func main() {
	filePath := `C:\Users\ITBDG\Documents\SystemicFitness-Handover\CLEAN\systemic-fitness-api\movment new\FEMALE-VIDEO LEVEL 1.xlsx`
	
	f, err := excelize.OpenFile(filePath)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer f.Close()

	sheets := f.GetSheetList()
	if len(sheets) == 0 {
		fmt.Println("No sheets found")
		return
	}
	sheet := sheets[0]
	fmt.Println("Sheet:", sheet)

	rows, err := f.GetRows(sheet)
	if err != nil {
		fmt.Println("Error reading rows:", err)
		return
	}

	for i, row := range rows {
		if i > 5 {
			break
		}
		fmt.Printf("Row %d: %v\n", i, row)
	}
}
