resource "aws_ecr_repository" "spring" {
  name                 = "spring-ecr"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "agent" {
  name                 = "agent-ecr"
  image_tag_mutability = "MUTABLE"
}