# Use a lightweight Nginx image as the base.
FROM nginx:alpine

# Copy your local project files into the Nginx web root directory inside the container.
# The `.` represents the current directory.
# `/usr/share/nginx/html` is where Nginx serves files from.
COPY . /usr/share/nginx/html

# Expose port 80. This is the default port for web servers.
EXPOSE 80