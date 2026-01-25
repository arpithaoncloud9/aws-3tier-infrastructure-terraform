module "vpc" {
  source       = "./vpc"
  project_name = var.project_name
}

module "compute" {
  source           = "./compute"
  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids

  instance_type    = var.instance_type
  ami_id           = var.ami_id
  
}

module "database" {
  source = "./database"
  project_name = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.compute.app_sg_id

  db_username = var.db_username
  db_password = var.db_password
  db_name = var.db_name
}
