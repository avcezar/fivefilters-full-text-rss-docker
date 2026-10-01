variable "IMAGE" {
	default = "fivefilters-full-text-rss"
}

group "default" {
	targets = ["all"]
}

target "all" {
  tags = ["${IMAGE}:latest", "${IMAGE}:3.8.2"]
	platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7", "linux/arm/v6"]
}

target "amd64" {
	tags = ["${IMAGE}"]
	platforms = ["linux/amd64"]
}

target "arm64" {
	tags = ["${IMAGE}"]
	platforms = ["linux/arm64"]
}
