package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestALBExample(t *testing.T) {
	t.Parallel()
	opts := &terraform.Options{
		TerraformDir: "../examples/alb",
		Vars: map[string]any{
			"alb_name": fmt.Sprintf("test-%s", random.UniqueId()),
		},
	}
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	albDNSName := terraform.OutputRequired(t, opts, "alb_dns_name")
	url := "http://" + albDNSName

	expectedStatusCode := 404
	expectedBody := "404: page not found"
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry(t,
		url,
		nil,
		expectedStatusCode,
		expectedBody,
		maxRetries,
		timeBetweenRetries,
	)
}
