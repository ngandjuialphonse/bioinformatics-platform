# =============================================================================
# Terraform VPC Module
# =============================================================================
#
# PURPOSE:
# This module creates a Virtual Private Cloud (VPC) with public and private
# subnets. A VPC is a fundamental AWS networking component that provides
# isolation for your resources.
#
# WHY A DEDICATED MODULE?
# - Reusability: Use this module to create consistent VPCs for different
#   environments (dev, prod, staging).
# - Best Practices: Encapsulates best practices for VPC design, such as
#   multi-AZ subnets and proper routing.
#
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Resource
# -----------------------------------------------------------------------------
# WHAT: The main VPC resource.
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

# -----------------------------------------------------------------------------
# Public Subnets
# -----------------------------------------------------------------------------
# WHAT: Subnets that have a direct route to the internet.
# WHY: For resources that need to be publicly accessible, like load balancers.
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-${count.index + 1}"
    }
  )
}

# -----------------------------------------------------------------------------
# Private Subnets
# -----------------------------------------------------------------------------
# WHAT: Subnets that do not have a direct route to the internet.
# WHY: For resources that should not be publicly accessible, like EKS nodes.
# -----------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-${count.index + 1}"
    }
  )
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------
# WHAT: Allows communication between the VPC and the internet.
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

# -----------------------------------------------------------------------------
# Public Route Table
# -----------------------------------------------------------------------------
# WHAT: Defines routing rules for the public subnets.
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-rtb"
    }
  )
}

# -----------------------------------------------------------------------------
# Public Route Table Association
# -----------------------------------------------------------------------------
# WHAT: Associates the public route table with the public subnets.
# -----------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# NAT Gateway
# -----------------------------------------------------------------------------
# WHAT: Allows resources in private subnets to access the internet, but
#       prevents the internet from initiating connections with those resources.
# WHY: For EKS nodes to pull container images from ECR.
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-gw"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# -----------------------------------------------------------------------------
# Private Route Table
# -----------------------------------------------------------------------------
# WHAT: Defines routing rules for the private subnets.
# -----------------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-rtb"
    }
  )
}

# -----------------------------------------------------------------------------
# Private Route Table Association
# -----------------------------------------------------------------------------
# WHAT: Associates the private route table with the private subnets.
# -----------------------------------------------------------------------------
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
