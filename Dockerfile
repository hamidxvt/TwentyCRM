FROM twentycrm/twenty:latest

ENV NODE_ENV=production

CMD ["npm", "run", "start:server"]

EXPOSE 3000
