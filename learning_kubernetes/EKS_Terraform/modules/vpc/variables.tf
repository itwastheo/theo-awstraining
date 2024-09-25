variable "vpc_cidr" {}
variable "access_ip" {}
variable "public_sn_count" {}
variable "public_cidrs" {
  type = list(any)
}
variable "instance_tenancy" {

}
variable "tags" {

}
variable "map_public_ip_on_launch" {

}
variable "rt_route_cidr_block" {

}
variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
