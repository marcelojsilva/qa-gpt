variable "app_name" {}

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.app_name}-api"
  description = "API Gateway for the Flask application"
}

resource "aws_api_gateway_resource" "process_file" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "process_file"
}

resource "aws_api_gateway_resource" "answer_question" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "answer_question"
}

resource "aws_api_gateway_resource" "healthcheck" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "healthcheck"
}

resource "aws_api_gateway_method" "process_file" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.process_file.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "answer_question" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.answer_question.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "healthcheck" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.healthcheck.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "process_file" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.process_file.id
  http_method = aws_api_gateway_method.process_file.http_method

  type                    = "HTTP_PROXY"
  uri                     = "${var.alb_dns_name}/process_file"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration" "answer_question" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.answer_question.id
  http_method = aws_api_gateway_method.answer_question.http_method

  type                    = "HTTP_PROXY"
  uri                     = "${var.alb_dns_name}/answer_question"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration" "healthcheck" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.healthcheck.id
  http_method = aws_api_gateway_method.healthcheck.http_method

  type                    = "HTTP_PROXY"
  uri                     = "${var.alb_dns_name}/healthcheck"
  integration_http_method = "GET"
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "prod"
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/prod/healthcheck"
}
