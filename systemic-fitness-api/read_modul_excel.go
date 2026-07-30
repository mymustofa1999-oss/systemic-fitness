package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func printRows(file string) {
	fmt.Println("---", file, "---")
	f, err := excelize.OpenFile(file)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer f.Close()

	sheets := f.GetSheetList()
	rows, _ := f.GetRows(sheets[0])
	for i := 0; i < len(rows) && i < 20; i++ {
		fmt.Println(rows[i])
	}
}

func main() {
	printRows(`C:\Users\ITBDG\Documents\SystemicFitness-Handover\CLEAN\systemic-fitness-api\movment new\FEMALE-VIDEO LEVEL 1.xlsx`)
	printRows(`C:\Users\ITBDG\Documents\SystemicFitness-Handover\CLEAN\systemic-fitness-api\movment new\MALE-VIDEO LEVEL 1.xlsx`)
}
