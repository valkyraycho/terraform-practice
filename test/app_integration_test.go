package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

const (
	dbRelPath  = "stage/data-stores/mysql"
	appRelPath = "stage/services/app"
)

func TestAPPStage(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "live")
	dbTestFolder := testFolder + "/" + dbRelPath
	appTestFolder := testFolder + "/" + appRelPath

	uniqueID := random.UniqueId()

	defer test_structure.RunTestStage(t, "teardown_db", func() {
		teardownDB(t, dbTestFolder)
	})
	test_structure.RunTestStage(t, "deploy_db", func() {
		deployDB(t, dbTestFolder, uniqueID)
	})

	defer test_structure.RunTestStage(t, "teardown_app", func() {
		teardownAPP(t, appTestFolder)
	})
	test_structure.RunTestStage(t, "deploy_app", func() {
		deployAPP(t, dbTestFolder, appTestFolder)
	})

	test_structure.RunTestStage(t, "validate_app", func() {
		validateAPP(t, appTestFolder, dbTestFolder)
	})

}

func deployDB(t *testing.T, dbTestFolder string, uniqueID string) {
	dbOpts := createDBOpts(t, dbTestFolder, uniqueID)
	test_structure.SaveTerraformOptions(t, dbTestFolder, dbOpts)

	terraform.InitAndApply(t, dbOpts)
}

func teardownDB(t *testing.T, dbTestFolder string) {
	dbOpts := test_structure.LoadTerraformOptions(t, dbTestFolder)
	terraform.Destroy(t, dbOpts)
}

func deployAPP(t *testing.T, dbTestFolder, appTestFolder string) {
	dbOpts := test_structure.LoadTerraformOptions(t, dbTestFolder)
	appOpts := createAPPOpts(dbOpts, appTestFolder)
	test_structure.SaveTerraformOptions(t, appTestFolder, appOpts)

	terraform.InitAndApply(t, appOpts)
}

func teardownAPP(t *testing.T, testFolder string) {
	appOpts := test_structure.LoadTerraformOptions(t, testFolder)
	terraform.Destroy(t, appOpts)
}

func createDBOpts(t *testing.T, terraformDir string, uniqueID string) *terraform.Options {
	bucketForTestingStg := "terraform-up-and-running-state-stg-valkyray-187457215304"
	bucketRegion := "us-east-2"
	dbStateKey := fmt.Sprintf("%s/%s/terraform.tfstate", t.Name(), uniqueID)
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]any{
			"db_name":     fmt.Sprintf("test%s", uniqueID),
			"db_username": "admin",
			"db_password": "password",
		},
		BackendConfig: map[string]any{
			"bucket":  bucketForTestingStg,
			"key":     dbStateKey,
			"region":  bucketRegion,
			"encrypt": true,
		},
		Reconfigure: true,
		Upgrade:     true,
	}
}

func createAPPOpts(dbOpts *terraform.Options, terraformDir string) *terraform.Options {
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]any{
			"db_remote_state_bucket": dbOpts.BackendConfig["bucket"],
			"db_remote_state_key":    dbOpts.BackendConfig["key"],
			"environment":            dbOpts.Vars["db_name"],
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed": "Throttling issue?",
		},
		Reconfigure: true,
		Upgrade:     true,
	}
}

func validateAPP(t *testing.T, appTestFolder, dbTestFolder string) {
	appOpts := test_structure.LoadTerraformOptions(t, appTestFolder)
	dbOpts := test_structure.LoadTerraformOptions(t, dbTestFolder)

	albDnsName := terraform.OutputRequired(t, appOpts, "alb_dns_name")

	dbAddress := terraform.OutputRequired(t, dbOpts, "address")
	dbPort := terraform.OutputRequired(t, dbOpts, "port")
	url := "http://" + albDnsName

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 && strings.Contains(body, "Hello, World") && strings.Contains(body, dbAddress) && strings.Contains(body, dbPort)
		},
	)
}
