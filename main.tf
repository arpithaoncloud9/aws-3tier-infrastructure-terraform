module "vpc" {
  source       = "./vpc"
  project_name = var.project_name
}

module "compute" {
  source           = "./compute"
  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  instance_type    = var.instance_type
  ami_id           = var.ami_id
  
}
