provider "aws" {
    region = "${var.region}"
}

terraform {
    backend "s3" {
      region = "us-east-1"
      bucket = "hashicorp-demo-state"
      key = "terraform/demo_service/terraform.tfstate"
    }
}

data "terraform_remote_state""aws_global" {
    backend = "s3"
    config {
            region = "us-east-1"
            bucket = "hashicorp-demo-state"
            key = "terraform/demo_service/terraform.tfstate"
    }
}

data "template_file" "function" {
        template = "${file("source/${var.function_name}.py")}"
}

data "archive_file" "zipit" {
        type = "zip"
        output_path = "${var.function_name}.zip"
        source {
                content = "${data.template_file.function.rendered}"
                filename = "${var.function_name}.py"
                }
}

resource "aws_lambda_function" "hashicorp_demo_function" {
        function_name = "${var.function_name}"
        role = "${var.lambda_role}"
        handler = "${var.function_name}.lambda_handler"
        filename = "${var.function_name}.zip"
        runtime = "python3.6"
        timeout = 10
        memory_size = 3008
        description = "Simple function using Vault to get credentials for data"

}
