package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAPPExample(t *testing.T) {
	t.Parallel()
	opts := &terraform.Options{
		TerraformDir: "../examples/app",
		Vars: map[string]any{
			"mysql_config": map[string]any{
				"address": "mock-value-for-test",
				"port":    3306,
			},
			"environment": fmt.Sprintf("test-%s", random.UniqueId()),
		},
	}

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	albDNSName := terraform.OutputRequired(t, opts, "alb_dns_name")
	url := "http://" + albDNSName

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 && strings.Contains(body, "Hello, World!")
		},
	)
}
