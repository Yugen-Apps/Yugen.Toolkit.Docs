FROM ubuntu:18.04

# LABEL "com.github.actions.name"="DocFX - Build and publish documentation"
# LABEL "com.github.actions.description"="Builds and publishes documentation to GitHub Pages."
# LABEL "com.github.actions.icon"="code"
# LABEL "com.github.actions.color"="red"

# LABEL "repository"="https://github.com/emiliano84/Toolkit.Docs"
# LABEL "homepage"="https://emiliano84.github.io/Toolkit.Docs/"
# LABEL "maintainer"="Emil <emiliano.magliocca@outlook.com>"

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]