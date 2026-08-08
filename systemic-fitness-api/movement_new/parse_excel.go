package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/xuri/excelize/v2"
)

func main() {
	f, err := excelize.OpenFile("MALE-VIDEO LEVEL 1.xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	sheets := f.GetSheetList()
	if len(sheets) == 0 {
		log.Fatal("no sheets")
	}

	rows, err := f.GetRows(sheets[0])
	if err != nil {
		log.Fatal(err)
	}

	limit := 20
	if len(rows) < limit {
		limit = len(rows)
	}

	b, _ := json.MarshalIndent(rows[:limit], "", "  ")
	fmt.Println(string(b))
}
