FROM twentycrm/twenty:latest

ENV NODE_ENV=production
ENV NODE_PORT=3000
# Ensure DB migrations always run on startup.
# This can be overridden per-deploy but defaults to enabled.
ENV DISABLE_DB_MIGRATIONS=false

COPY --chmod=755 start.sh /start.sh

EXPOSE 3000
CMD ["/start.sh"]
