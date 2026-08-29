package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	path := "../systemic-fitness-api/internal/repository/trainer_card_repo.go"
	b, err := ioutil.ReadFile(path)
	if err != nil {
		panic(err)
	}
	content := string(b)

	// Fix the function signature first
	startStr := "func (r *TrainerCardRepository) UpsertCard(ctx context.Context, card *TrainerCard) error {"
	newStartStr := "func (r *TrainerCardRepository) UpsertCard(ctx context.Context, card *TrainerCard, updateSequences bool) error {"
	content = strings.Replace(content, startStr, newStartStr, 1)

	// Now replace the block
	patchBytes, err := ioutil.ReadFile("../../../../../../../../../Users/ITBDG/.gemini/antigravity/brain/057f67dd-e0b7-4e89-b2fa-b29d35c7c9bc/scratch/patch.txt")
	if err != nil {
		panic(err)
	}
	patchStr := string(patchBytes)

	deleteStart := "// 2. Delete existing nested data"
	endStart := "return tx.Commit(ctx)\n}"

	idx1 := strings.Index(content, deleteStart)
	if idx1 == -1 {
		panic("could not find deleteStart")
	}

	idx2 := strings.Index(content[idx1:], endStart)
	if idx2 == -1 {
		panic("could not find endStart")
	}
	idx2 += idx1 + len(endStart)

	newContent := content[:idx1] + patchStr + content[idx2:]

	err = ioutil.WriteFile(path, []byte(newContent), 0644)
	if err != nil {
		panic(err)
	}
	fmt.Println("success")
}
