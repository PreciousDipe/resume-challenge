resource "aws_apigatewayv2_api" "count-api" {
  name          = "count-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["GET"]
    allow_headers     = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "count-api" {
  api_id           = aws_apigatewayv2_api.count-api.id
  integration_type = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "Lambda example"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.myfunct.invoke_arn
}

resource "aws_apigatewayv2_route" "count-api" {
  api_id    = aws_apigatewayv2_api.count-api.id
  route_key = "GET /views"

  target = "integrations/${aws_apigatewayv2_integration.count-api.id}"
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "myfunct"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.count-api.execution_arn}/*"
}

# Output the API Gateway URL
output "api_gateway_url" {
  value = aws_apigatewayv2_api.count-api.api_endpoint
}

resource "aws_apigatewayv2_stage" "count-api" {
  api_id      = aws_apigatewayv2_api.count-api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.example.arn
    format          = "{\"requestId\":\"$context.requestId\",\"ip\":\"$context.identity.sourceIp\",\"requestTime\":\"$context.requestTime\",\"httpMethod\":\"$context.httpMethod\",\"resourcePath\":\"$context.routeKey\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"responseLength\":\"$context.responseLength\",\"userAgent\":\"$context.identity.userAgent\"}"
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/apigateway/count-api"
}
