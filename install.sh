#!/bin/bash

# District Zero FiveM - Installation Script
# This script automates the installation and setup process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCE_NAME="district-zero"
FIVEM_SERVER_DIR=""
DATABASE_HOST="localhost"
DATABASE_PORT="3306"
DATABASE_NAME="district_zero"
DATABASE_USER="root"
DATABASE_PASS=""

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    District Zero FiveM - Installer"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "This script is running as root. This is not recommended for security reasons."
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Check system requirements
check_requirements() {
    print_info "Checking system requirements..."
    
    # Check if running on Linux/Unix
    if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for Linux/Unix systems"
        exit 1
    fi
    
    # Check for required commands
    local required_commands=("mysql" "git" "curl" "wget")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_warning "$cmd is not installed. Please install it before continuing."
        else
            print_success "$cmd is available"
        fi
    done
    
    # Check for Node.js (for UI development)
    if command -v "node" &> /dev/null; then
        local node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [[ $node_version -ge 16 ]]; then
            print_success "Node.js version $(node --version) is available"
        else
            print_warning "Node.js version $(node --version) is available, but version 16+ is recommended"
        fi
    else
        print_warning "Node.js is not installed. It's required for UI development."
    fi
}

# Get FiveM server directory
get_fivem_directory() {
    print_info "Please provide the path to your FiveM server resources directory:"
    read -p "FiveM server directory: " FIVEM_SERVER_DIR
    
    if [[ ! -d "$FIVEM_SERVER_DIR" ]]; then
        print_error "Directory does not exist: $FIVEM_SERVER_DIR"
        exit 1
    fi
    
    if [[ ! -d "$FIVEM_SERVER_DIR/resources" ]]; then
        print_error "Resources directory not found. Please provide the correct FiveM server directory."
        exit 1
    fi
    
    print_success "FiveM server directory: $FIVEM_SERVER_DIR"
}

# Get database configuration
get_database_config() {
    print_info "Database Configuration"
    echo "Please provide your MySQL database configuration:"
    
    read -p "Database host [$DATABASE_HOST]: " input_host
    DATABASE_HOST=${input_host:-$DATABASE_HOST}
    
    read -p "Database port [$DATABASE_PORT]: " input_port
    DATABASE_PORT=${input_port:-$DATABASE_PORT}
    
    read -p "Database name [$DATABASE_NAME]: " input_name
    DATABASE_NAME=${input_name:-$DATABASE_NAME}
    
    read -p "Database user [$DATABASE_USER]: " input_user
    DATABASE_USER=${input_user:-$DATABASE_USER}
    
    read -s -p "Database password: " DATABASE_PASS
    echo
    
    print_success "Database configuration saved"
}

# Test database connection
test_database_connection() {
    print_info "Testing database connection..."
    
    if mysql -h "$DATABASE_HOST" -P "$DATABASE_PORT" -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "SELECT 1;" &> /dev/null; then
        print_success "Database connection successful"
    else
        print_error "Database connection failed. Please check your credentials."
        exit 1
    fi
}

# Create database and tables
setup_database() {
    print_info "Setting up database..."
    
    # Create database if it doesn't exist
    mysql -h "$DATABASE_HOST" -P "$DATABASE_PORT" -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DATABASE_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    
    # Create tables
    local sql_file="$SCRIPT_DIR/database/schema.sql"
    if [[ -f "$sql_file" ]]; then
        mysql -h "$DATABASE_HOST" -P "$DATABASE_PORT" -u "$DATABASE_USER" -p"$DATABASE_PASS" "$DATABASE_NAME" < "$sql_file"
        print_success "Database tables created"
    else
        print_warning "Database schema file not found: $sql_file"
        print_info "You may need to create the database tables manually"
    fi
}

# Copy resource files
copy_resource_files() {
    print_info "Copying resource files..."
    
    local target_dir="$FIVEM_SERVER_DIR/resources/$RESOURCE_NAME"
    
    # Remove existing installation if it exists
    if [[ -d "$target_dir" ]]; then
        print_warning "Existing installation found. Removing..."
        rm -rf "$target_dir"
    fi
    
    # Copy files
    cp -r "$SCRIPT_DIR" "$target_dir"
    
    # Remove installation files from target
    rm -f "$target_dir/install.sh"
    rm -f "$target_dir/README.md"
    rm -rf "$target_dir/.git"
    
    print_success "Resource files copied to: $target_dir"
}

# Create configuration files
create_config_files() {
    print_info "Creating configuration files..."
    
    local config_dir="$FIVEM_SERVER_DIR/resources/$RESOURCE_NAME/config"
    
    # Create database configuration
    cat > "$config_dir/database.json" << EOF
{
  "type": "mysql",
  "host": "$DATABASE_HOST",
  "port": $DATABASE_PORT,
  "database": "$DATABASE_NAME",
  "username": "$DATABASE_USER",
  "password": "$DATABASE_PASS",
  "connectionLimit": 10,
  "timeout": 5000
}
EOF
    
    # Create default configuration files
    local configs=("districts" "missions" "teams" "events" "achievements" "analytics" "security" "performance" "ui" "deployment" "release")
    
    for config in "${configs[@]}"; do
        if [[ ! -f "$config_dir/$config.json" ]]; then
            cp "$config_dir/$config.example.json" "$config_dir/$config.json" 2>/dev/null || {
                print_warning "Example configuration file not found for: $config"
            }
        fi
    done
    
    print_success "Configuration files created"
}

# Install dependencies
install_dependencies() {
    print_info "Installing dependencies..."
    
    local dependencies=("mysql-async" "oxmysql" "es_extended" "qb-core" "ox_lib")
    local missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        local dep_dir="$FIVEM_SERVER_DIR/resources/$dep"
        if [[ ! -d "$dep_dir" ]]; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        echo "Please install the following resources:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo
        echo "You can find these resources at:"
        echo "  - https://github.com/brouznouf/fivem-mysql-async"
        echo "  - https://github.com/overextended/oxmysql"
        echo "  - https://github.com/esx-framework/esx-legacy"
        echo "  - https://github.com/qbcore-framework/qb-core"
        echo "  - https://github.com/overextended/ox_lib"
    else
        print_success "All dependencies are installed"
    fi
}

# Update server configuration
update_server_config() {
    print_info "Updating server configuration..."
    
    local server_cfg="$FIVEM_SERVER_DIR/server.cfg"
    
    if [[ ! -f "$server_cfg" ]]; then
        print_warning "server.cfg not found. Please add the following lines to your server configuration:"
        echo "ensure $RESOURCE_NAME"
        echo "ensure mysql-async"
        echo "ensure oxmysql"
        return
    fi
    
    # Check if resource is already in server.cfg
    if grep -q "ensure $RESOURCE_NAME" "$server_cfg"; then
        print_success "Resource already configured in server.cfg"
    else
        # Add resource to server.cfg
        echo "" >> "$server_cfg"
        echo "# District Zero" >> "$server_cfg"
        echo "ensure $RESOURCE_NAME" >> "$server_cfg"
        print_success "Resource added to server.cfg"
    fi
}

# Set up permissions
setup_permissions() {
    print_info "Setting up file permissions..."
    
    local target_dir="$FIVEM_SERVER_DIR/resources/$RESOURCE_NAME"
    
    # Set appropriate permissions
    chmod -R 755 "$target_dir"
    chmod 644 "$target_dir"/*.json 2>/dev/null || true
    chmod 644 "$target_dir/config"/*.json 2>/dev/null || true
    
    print_success "File permissions set"
}

# Create startup script
create_startup_script() {
    print_info "Creating startup script..."
    
    local startup_script="$FIVEM_SERVER_DIR/start_district_zero.sh"
    
    cat > "$startup_script" << 'EOF'
#!/bin/bash

# District Zero FiveM - Startup Script
# This script starts the FiveM server with District Zero

echo "Starting FiveM server with District Zero..."

# Change to server directory
cd "$(dirname "$0")"

# Start FiveM server
./FXServer +set serverProfile district_zero +set sv_scriptHookAllowed 0 +set sv_autocleanup 1 +set sv_cleanupInterval 10 +set sv_maxClients 32 +set sv_licenseKey YOUR_LICENSE_KEY +exec server.cfg

echo "FiveM server stopped."
EOF
    
    chmod +x "$startup_script"
    print_success "Startup script created: $startup_script"
}

# Run post-installation checks
post_install_checks() {
    print_info "Running post-installation checks..."
    
    local target_dir="$FIVEM_SERVER_DIR/resources/$RESOURCE_NAME"
    
    # Check if all required files exist
    local required_files=("fxmanifest.lua" "server/" "client/" "shared/" "ui/")
    for file in "${required_files[@]}"; do
        if [[ -e "$target_dir/$file" ]]; then
            print_success "✓ $file"
        else
            print_error "✗ $file (missing)"
        fi
    done
    
    # Check configuration files
    local config_files=("config/database.json" "config/districts.json" "config/missions.json")
    for file in "${config_files[@]}"; do
        if [[ -f "$target_dir/$file" ]]; then
            print_success "✓ $file"
        else
            print_warning "⚠ $file (missing)"
        fi
    done
}

# Display installation summary
show_summary() {
    print_header
    echo "Installation completed successfully!"
    echo
    echo "Summary:"
    echo "  - Resource installed to: $FIVEM_SERVER_DIR/resources/$RESOURCE_NAME"
    echo "  - Database: $DATABASE_NAME on $DATABASE_HOST:$DATABASE_PORT"
    echo "  - Configuration files created in: config/"
    echo
    echo "Next steps:"
    echo "  1. Review and edit configuration files in config/"
    echo "  2. Install any missing dependencies"
    echo "  3. Add your FiveM license key to server.cfg"
    echo "  4. Start your FiveM server"
    echo "  5. Test the resource with: restart $RESOURCE_NAME"
    echo
    echo "Documentation:"
    echo "  - Read docs/README.md for detailed information"
    echo "  - Check docs/API.md for API reference"
    echo "  - Visit docs/TROUBLESHOOTING.md for help"
    echo
    echo "Support:"
    echo "  - GitHub: https://github.com/district-zero/fivem-mm"
    echo "  - Issues: https://github.com/district-zero/fivem-mm/issues"
    echo
}

# Main installation function
main() {
    print_header
    
    # Check if running as root
    check_root
    
    # Check system requirements
    check_requirements
    
    # Get FiveM server directory
    get_fivem_directory
    
    # Get database configuration
    get_database_config
    
    # Test database connection
    test_database_connection
    
    # Setup database
    setup_database
    
    # Copy resource files
    copy_resource_files
    
    # Create configuration files
    create_config_files
    
    # Install dependencies
    install_dependencies
    
    # Update server configuration
    update_server_config
    
    # Setup permissions
    setup_permissions
    
    # Create startup script
    create_startup_script
    
    # Run post-installation checks
    post_install_checks
    
    # Show summary
    show_summary
}

# Run main function
main "$@" 