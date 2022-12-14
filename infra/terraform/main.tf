module "networking" {
  source = "./modules/networking"
  cidr_block = var.cidr_block
  public_subnets = var.public_subnets
}

module "s3" {
  source = "./modules/s3"
  s3_bucket_name = "artifacts-demo-bucket"
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.networking.vpc_id
  allowed_ports = ["80", "443"]
  prometheus_sg_id = module.jenkins.prometheus_sg_public_subnet_id
  my_ip = var.my_ip
}

module "compute" {
  source = "./modules/compute"
  region = var.region
  web_instance_profile = module.iam.ec2_instance_profile
  public_subnets = module.networking.public_subnets_info
  instance_type = "t2.micro"
  web_security_groups = [module.security_groups.ec2_sg_public_subnet_id]
  web_staging_security_groups = [module.security_groups.ec2_sg_staging_public_subnet_id]
  bucket_name = module.s3.artifacts_s3_bucket_name
}

module "iam" {
  source = "./modules/iam"
  s3_bucket_name = module.s3.artifacts_s3_bucket_name
  region = var.region
}
  
module "codedeploy" {
  source = "./modules/codedeploy" 
  application_name = var.application_name
  # deployment_group_name = "${var.application_name}_deployment_group"
  web_server_name_tag = module.compute.web_server_name_tag
  web_server_staging_name_tag = module.compute.web_server_staging_name_tag
  codedeploy_role_arn = module.iam.codedeploy_role_arn

}

module "app_load_balancer" {
  source = "./modules/app_load_balancer"
  application_name = var.application_name
  app_port = 80
  subnets = module.networking.public_subnets_info[*].id
  load_balancer_sg = [module.security_groups.app_lb_sg_id]
  vpc_id = module.networking.vpc_id
  web_servers_info = module.compute.web_servers_info
}

module "ecr" {
  source = "./modules/ecr"
  repository_name_frontend = "${var.application_name}_frontend_repo"
  repository_name_backend = "${var.application_name}_backend_repo"
}

module "jenkins" {
  source = "./modules/jenkins"
  vpc_id = module.networking.vpc_id
  subnet_id =  module.networking.public_subnets_info[0].id
  bucket_name = module.s3.artifacts_s3_bucket_name
  my_ip = var.my_ip
}