# -------------------------
# Day‑1 VPC Module
# -------------------------
module "vpc" {
  source = "./vpc"
}

# -------------------------
# Day‑2 Compute Module
# -------------------------
module "compute" {
  source = "./compute"

  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets
  private_app_subnets = module.vpc.private_app_subnets
}
