# build from httpd for apache
FROM httpd:2.4

# copies all content from the web folder into default web directory in apache
COPY web-content/ /usr/local/apache2/htdocs/
