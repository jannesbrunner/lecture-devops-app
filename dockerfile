FROM node:lts-alpine3.9 as todo-app-client-build
LABEL MAINTAINER="Jannes Brunner"

## Client Part

WORKDIR /client

# copy both 'package.json' and 'package-lock.json' (if available)
COPY ./app/client/package*.json ./

# install project dependencies
RUN npm install

COPY ./app/client .

# build app for production
RUN npm run build

## Server Part

FROM node:lts-alpine3.9

LABEL MAINTAINER="Jannes Brunner"

# copy both 'package.json' and 'package-lock.json' (if available)
COPY ./app/server/package*.json ./

# install project dependencies
RUN npm install

# copy project files and folders to the current working directory (i.e. 'app' folder)
COPY ./app/server .

# copy build artifact of client into public
COPY --from=todo-app-client-build /client/build /src/public

EXPOSE 3000

CMD [ "npm", "run", "start:container-dev" ]
