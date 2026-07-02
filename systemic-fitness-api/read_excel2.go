package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
	"log"
)

func main() {
	f, err := excelize.OpenFile("movment/LEVEL 1.xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	sheets := f.GetSheetList()
	rows, err := f.GetRows(sheets[0])
	if err != nil {
		log.Fatal(err)
	}

	for i, row := range rows {
		if i == 0 || len(row) < 9 {
			continue
		}
		femaleUpper := row[4]
		femaleLower := row[5]
		if femaleUpper != "" && femaleLower != "" && femaleUpper != "waitlist" && femaleLower != "waitlist" {
			fmt.Printf("Row %d HAS BOTH: Upper=%s, Lower=%s\n", i, femaleUpper, femaleLower)
		}
	}
	fmt.Println("Done checking.")
}
