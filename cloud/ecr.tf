resource "aws_ecr_repository" "payvault_repo" {
  name = "payvault-app"
  image_tag_mutability = "MUTABLE"
  force_delete = true # in prod system should be kept as false, here if terraform destory happens, repo + images will also get deleted.

  image_scanning_configuration {
    scan_on_push = true # auto scan the image and check for vulnerabiliteis if any
  }
}