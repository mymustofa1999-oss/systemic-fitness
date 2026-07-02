package main

import (
	"fmt"
	"path/filepath"
	"github.com/xuri/excelize/v2"
)

func checkSheets(filename string) {
	f, err := excelize.OpenFile(filename)
	if err != nil {
		fmt.Println("Error opening:", filename, err)
		return
	}
	defer f.Close()
	fmt.Printf("%s sheets: %v\n", filename, f.GetSheetList())
}

func main() {
	files, _ := filepath.Glob("movment/LEVEL *.xlsx")
	for _, f := range files {
		checkSheets(f)
	}
}
