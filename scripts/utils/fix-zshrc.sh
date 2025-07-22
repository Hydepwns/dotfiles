#!/bin/bash

# Fix zshrc template processing issues
echo "🔧 Fixing zshrc template processing..."

# Process the template and fix common formatting issues
chezmoi execute-template < home/dot_zshrc | \
    sed 's/# \([^#]*\)configuration/\n# \1configuration/g' | \
    sed 's/export \([^=]*\)=\([^#]*\)#/\nexport \1=\2\n#/g' | \
    sed 's/\([^;]\)$/\1\n/g' | \
    sed 's/^\([^#]\)/\n\1/g' | \
    sed 's/alias \([^=]*\)=\([^#]*\)#/\nalias \1=\2\n#/g' | \
    sed 's/test -e \([^&]*\) && source \([^#]*\)#/\ntest -e \1 \&\& source \2\n#/g' | \
    sed 's/source \([^#]*\)#/\nsource \1\n#/g' > ~/.zshrc

echo "✅ zshrc template processed and fixed"
