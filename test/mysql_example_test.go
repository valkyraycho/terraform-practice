package test

import (
	"fmt"
	"testing"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestMySqlExample(t *testing.T) {
	t.Parallel()

	dbName := fmt.Sprintf("test_%s", random.UniqueId())
	dbUsername := "admin"
	dbPassword := "password"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/mysql",
		Vars: map[string]any{
			"db_name":     dbName,
			"db_username": dbUsername,
			"db_password": dbPassword,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	address := terraform.OutputRequired(t, terraformOptions, "address")
	port := terraform.OutputRequired(t, terraformOptions, "port")

	if address == "" {
		t.Fatal("db_endpoint output should not be empty")
	}

	if port != "3306" {
		t.Fatalf("expected MySQL port 3306, got %s", port)
	}
}
