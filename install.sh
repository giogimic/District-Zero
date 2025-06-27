#!/bin/bash

# District Zero FiveM Installation Script
# QBox Framework Compatible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_NAME="district-zero"
RESOURCE_PATH="resources/$RESOURCE_NAME"
BACKUP_PATH="backups/$RESOURCE_NAME-$(date +%Y%m%d_%H%M%S)"

# QBox Framework Dependencies
local dependencies=("qbx_core" "oxmysql" "ox_lib")

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if directory exists
directory_exists() {
    [ -d "$1" ]
}

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# Function to create backup
create_backup() {
    if directory_exists "$RESOURCE_PATH"; then
        print_status "Creating backup of existing installation..."
        mkdir -p backups
        cp -r "$RESOURCE_PATH" "$BACKUP_PATH"
        print_success "Backup created at $BACKUP_PATH"
    fi
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking QBox Framework dependencies..."
    
    for dep in "${dependencies[@]}"; do
        if ! directory_exists "resources/$dep"; then
            print_warning "Dependency $dep not found in resources directory"
            print_warning "Please ensure QBox Framework is properly installed"
            print_warning "Visit: https://docs.qbox.re/installation"
        else
            print_success "Dependency $dep found"
        fi
    done
}

# Function to install resource
install_resource() {
    print_status "Installing District Zero..."
    
    # Create resources directory if it doesn't exist
    mkdir -p resources
    
    # Remove existing installation if it exists
    if directory_exists "$RESOURCE_PATH"; then
        print_status "Removing existing installation..."
        rm -rf "$RESOURCE_PATH"
    fi
    
    # Copy current directory to resources
    print_status "Copying files to resources directory..."
    cp -r . "$RESOURCE_PATH"
    
    # Remove unnecessary files from resource directory
    cd "$RESOURCE_PATH"
    rm -f install.sh
    rm -f README.md
    rm -f package.json
    rm -f QBOX_INSTALLATION.md
    rm -f PROJECT_AUDIT.md
    rm -f IMPLEMENTATION_PLAN.md
    rm -f UI-Plan.md
    rm -f AGENT.md
    rm -f API.md
    rm -f EVENTS.md
    rm -f CHANGELOG.md
    rm -f LICENSE
    rm -f TROUBLESHOOTING.md
    rm -f AI-Comprehension.md
    rm -rf .git
    rm -rf .cursor
    rm -rf backups
    
    print_success "Resource installed to $RESOURCE_PATH"
}

# Function to setup database
setup_database() {
    print_status "Setting up database..."
    
    if file_exists "server/database/migrations/001_initial_schema.sql"; then
        print_status "Database schema found"
        print_warning "Please manually import the database schema:"
        print_warning "mysql -u root -p qbox < server/database/migrations/001_initial_schema.sql"
    else
        print_warning "Database schema not found"
    fi
}

# Function to update server.cfg
update_server_cfg() {
    print_status "Checking server.cfg configuration..."
    
    if file_exists "server.cfg"; then
        # Check if resource is already in server.cfg
        if grep -q "ensure $RESOURCE_NAME" server.cfg; then
            print_success "Resource already configured in server.cfg"
        else
            print_warning "Please add the following to your server.cfg:"
            echo ""
            echo "# QBox Framework (must be loaded first)"
            echo "ensure qbx_core"
            echo "ensure oxmysql"
            echo "ensure ox_lib"
            echo ""
            echo "# District Zero"
            echo "ensure $RESOURCE_NAME"
            echo ""
        fi
    else
        print_warning "server.cfg not found in current directory"
        print_warning "Please add the following to your server.cfg:"
        echo ""
        echo "# QBox Framework (must be loaded first)"
        echo "ensure qbx_core"
        echo "ensure oxmysql"
        echo "ensure ox_lib"
        echo ""
        echo "# District Zero"
        echo "ensure $RESOURCE_NAME"
        echo ""
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    if directory_exists "$RESOURCE_PATH"; then
        if file_exists "$RESOURCE_PATH/fxmanifest.lua"; then
            print_success "Resource manifest found"
        else
            print_error "Resource manifest not found"
            return 1
        fi
        
        if file_exists "$RESOURCE_PATH/shared/config.lua"; then
            print_success "Configuration file found"
        else
            print_error "Configuration file not found"
            return 1
        fi
        
        if file_exists "$RESOURCE_PATH/shared/qbox_integration.lua"; then
            print_success "QBox integration file found"
        else
            print_error "QBox integration file not found"
            return 1
        fi
        
        print_success "Installation verified successfully"
    else
        print_error "Resource directory not found"
        return 1
    fi
}

# Function to display post-installation instructions
post_installation_instructions() {
    echo ""
    print_success "Installation completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Configure your database settings in $RESOURCE_PATH/shared/config.lua"
    echo "2. Import the database schema: mysql -u root -p qbox < $RESOURCE_PATH/server/database/migrations/001_initial_schema.sql"
    echo "3. Add the resource to your server.cfg"
    echo "4. Restart your FiveM server"
    echo "5. Test the resource in-game"
    echo ""
    print_status "For detailed instructions, see: $RESOURCE_PATH/QBOX_INSTALLATION.md"
    echo ""
}

# Main installation function
main() {
    echo "=========================================="
    echo "District Zero FiveM - QBox Framework"
    echo "Installation Script"
    echo "=========================================="
    echo ""
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root is not recommended"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Create backup
    create_backup
    
    # Check dependencies
    check_dependencies
    
    # Install resource
    install_resource
    
    # Setup database
    setup_database
    
    # Update server.cfg
    update_server_cfg
    
    # Verify installation
    if verify_installation; then
        post_installation_instructions
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

# Run main function
main "$@" 