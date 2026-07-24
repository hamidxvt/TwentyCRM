FROM twentycrm/twenty:latest

ENV NODE_ENV=production
ENV NODE_PORT=3000
# Ensure DB migrations always run on startup.
# This can be overridden per-deploy but defaults to enabled.
ENV DISABLE_DB_MIGRATIONS=false

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 3000
CMD ["/usr/local/bin/start.sh"]
